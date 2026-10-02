import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { createReadStream, readFileSync, statSync } from 'node:fs';
import { basename, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import {
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';

const APK_CONTENT_TYPE = 'application/vnd.android.package-archive';
const IMMUTABLE_CACHE = 'public, max-age=31536000, immutable';

export function parseArguments(argv) {
  const values = {};
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith('--') || value === undefined) {
      throw new Error('上传工具参数必须使用 --key value');
    }
    values[key.slice(2)] = value;
  }
  for (const required of ['apk', 'sha256-file', 'manifest', 'version', 'build']) {
    if (!values[required]) throw new Error(`缺少 --${required}`);
  }
  if (!/^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$/.test(values.version)) {
    throw new Error('版本名格式不合法');
  }
  if (!/^[1-9][0-9]*$/.test(values.build)) throw new Error('构建号格式不合法');
  return values;
}

export function releaseConfig(env) {
  const config = {
    endpoint: env.WENYOU_RELEASE_S3_ENDPOINT || 'https://cn-nb1.rains3.com',
    region: env.WENYOU_RELEASE_S3_REGION || 'auto',
    bucket: env.WENYOU_RELEASE_S3_BUCKET || 'wenyou-apk',
    accessKeyId: env.WENYOU_RELEASE_S3_ACCESS_KEY_ID,
    secretAccessKey: env.WENYOU_RELEASE_S3_SECRET_ACCESS_KEY,
    publicBaseUrl:
      env.WENYOU_RELEASE_PUBLIC_BASE_URL ||
      'https://wenyou-apk.cn-nb1.rains3.com',
    prefix: (env.WENYOU_RELEASE_S3_PREFIX || 'mobile/android').replace(/^\/+|\/+$/g, ''),
  };
  if (!config.accessKeyId || !config.secretAccessKey) {
    throw new Error('缺少 RainS3 发布专用 AccessKey');
  }
  for (const field of ['endpoint', 'publicBaseUrl']) {
    const url = new URL(config[field]);
    if (url.protocol !== 'https:') throw new Error(`${field} 必须使用 HTTPS`);
    if (url.username || url.password || url.search || url.hash) {
      throw new Error(`${field} 不得包含凭据、查询参数或 fragment`);
    }
  }
  if (config.bucket !== 'wenyou-apk' || config.prefix !== 'mobile/android') {
    throw new Error('发布工具只允许 wenyou-apk 桶的 mobile/android 目录');
  }
  return config;
}

export function parseSha256Sidecar(content, expectedFile) {
  const match = content.trim().match(/^([0-9a-fA-F]{64})\s+\*?(.+)$/);
  if (!match || match[2] !== expectedFile) throw new Error('SHA-256 sidecar 格式或文件名不匹配');
  return match[1].toLowerCase();
}

export function releaseObjectPlan({ version, build, apkPath, shaPath, manifestPath, manifest }) {
  const base = `wenyou-${version}-${build}`;
  const expectedApk = `${base}.apk`;
  if (basename(apkPath) !== expectedApk) throw new Error('APK 文件名与版本参数不一致');
  if (basename(shaPath) !== `${expectedApk}.sha256`) throw new Error('SHA sidecar 文件名不一致');
  if (basename(manifestPath) !== `${base}.json`) throw new Error('构建摘要文件名不一致');
  if (
    manifest.applicationId !== 'site.wenyou.app' ||
    manifest.versionName !== version ||
    Number(manifest.versionCode) !== Number(build) ||
    manifest.apkFile !== expectedApk
  ) {
    throw new Error('构建摘要与发布参数不一致');
  }
  return [
    { path: shaPath, fileName: basename(shaPath), contentType: 'text/plain; charset=utf-8' },
    { path: manifestPath, fileName: basename(manifestPath), contentType: 'application/json; charset=utf-8' },
    { path: apkPath, fileName: expectedApk, contentType: APK_CONTENT_TYPE, attachment: true },
  ];
}

export function assertPublicApkHeaders(headers, expected) {
  const contentType = headers.get('content-type')?.split(';', 1)[0]?.trim().toLowerCase();
  if (contentType !== APK_CONTENT_TYPE) throw new Error('公网 APK Content-Type 不正确');
  if (Number(headers.get('content-length')) !== expected.size) throw new Error('公网 APK 大小不一致');
  const cache = headers.get('cache-control')?.toLowerCase() || '';
  for (const directive of ['public', 'max-age=31536000', 'immutable']) {
    if (!cache.includes(directive)) throw new Error(`公网 APK 缺少缓存指令 ${directive}`);
  }
  const disposition = headers.get('content-disposition') || '';
  if (!disposition.toLowerCase().includes('attachment') || !disposition.includes(expected.fileName)) {
    throw new Error('公网 APK Content-Disposition 不正确');
  }
  if (headers.get('x-amz-meta-apk-sha256')?.toLowerCase() !== expected.sha256) {
    throw new Error('公网 APK SHA-256 metadata 不一致');
  }
  if (headers.get('x-amz-meta-application-id') !== 'site.wenyou.app') {
    throw new Error('公网 APK applicationId metadata 不一致');
  }
  if (headers.get('x-amz-meta-version-name') !== expected.version) {
    throw new Error('公网 APK versionName metadata 不一致');
  }
  if (headers.get('x-amz-meta-version-code') !== String(expected.build)) {
    throw new Error('公网 APK versionCode metadata 不一致');
  }
}

function sha256File(file) {
  const hash = createHash('sha256');
  hash.update(readFileSync(file));
  return hash.digest('hex');
}

function isMissingObject(error) {
  return error?.$metadata?.httpStatusCode === 404 || error?.name === 'NotFound' || error?.name === 'NoSuchKey';
}

function normalizeContentType(value) {
  return value?.split(';', 1)[0]?.trim().toLowerCase();
}

async function headObject(client, bucket, key) {
  try {
    return await client.send(new HeadObjectCommand({ Bucket: bucket, Key: key }));
  } catch (error) {
    if (isMissingObject(error)) return null;
    throw storageFailure(error);
  }
}

function storageFailure(error) {
  const status = error?.$metadata?.httpStatusCode;
  // SDK/对象存储错误正文可能回显签名请求；不输出原始 message、headers 或凭据。
  return new Error(`鉴权对象存储请求失败${Number.isInteger(status) ? ` (HTTP ${status})` : ''}`);
}

async function sendStorage(client, command) {
  try { return await client.send(command); }
  catch (error) { throw storageFailure(error); }
}

export function assertStoredObject(head, artifact) {
  if (Number(head.ContentLength) !== artifact.size) throw new Error(`已有对象大小不一致: ${artifact.key}`);
  if (normalizeContentType(head.ContentType) !== normalizeContentType(artifact.contentType)) {
    throw new Error(`已有对象 Content-Type 不一致: ${artifact.key}`);
  }
  if (head.CacheControl !== IMMUTABLE_CACHE) throw new Error(`已有对象缓存策略不一致: ${artifact.key}`);
  if (head.Metadata?.['artifact-sha256']?.toLowerCase() !== artifact.artifactSha256) {
    throw new Error(`已有对象内容摘要不一致，禁止覆盖: ${artifact.key}`);
  }
  if (head.Metadata?.['apk-sha256']?.toLowerCase() !== artifact.apkSha256) {
    throw new Error(`已有对象 APK 摘要不一致，禁止覆盖: ${artifact.key}`);
  }
  for (const [name, value] of Object.entries(artifact.metadata)) {
    if (head.Metadata?.[name] !== value) {
      throw new Error(`对象发布身份不一致 (${name}): ${artifact.key}`);
    }
  }
  if (artifact.attachment && head.ContentDisposition !== `attachment; filename="${artifact.fileName}"`) {
    throw new Error(`对象 Content-Disposition 不正确: ${artifact.key}`);
  }
}

export async function ensureUploaded(client, config, artifact) {
  const existing = await headObject(client, config.bucket, artifact.key);
  if (existing) {
    assertStoredObject(existing, artifact);
    process.stderr.write(`对象已存在且内容一致，跳过: ${artifact.key}\n`);
    return;
  }
  await sendStorage(client,
    new PutObjectCommand({
      Bucket: config.bucket,
      Key: artifact.key,
      Body: createReadStream(artifact.path),
      ContentLength: artifact.size,
      ContentType: artifact.contentType,
      CacheControl: IMMUTABLE_CACHE,
      ...(artifact.attachment
        ? { ContentDisposition: `attachment; filename="${artifact.fileName}"` }
        : {}),
      Metadata: artifact.metadata,
      IfNoneMatch: '*',
    }),
  );
  const uploaded = await headObject(client, config.bucket, artifact.key);
  if (!uploaded) throw new Error(`上传后对象不存在: ${artifact.key}`);
  assertStoredObject(uploaded, artifact);
}

export async function verifyPrivateArtifacts(client, config, artifacts) {
  for (const artifact of artifacts) {
    const head = await headObject(client, config.bucket, artifact.key);
    if (!head) throw new Error(`待核验对象不存在: ${artifact.key}`);
    assertStoredObject(head, artifact);
    // APK 由本地验签/摘要和上传后 HEAD 固定身份；只读回两个小附件，避免再次下载 APK。
    if (artifact.attachment) continue;
    if (artifact.size > 64 * 1024) throw new Error('发布附件超过 64 KiB');
    const response = await sendStorage(client, new GetObjectCommand({
      Bucket: config.bucket, Key: artifact.key, IfMatch: head.ETag,
    }));
    try {
      assertStoredObject(response, artifact);
      if (!response.Body) throw new Error('发布附件缺少正文');
      const hash = createHash('sha256');
      let length = 0;
      for await (const chunk of response.Body) {
        length += chunk.length;
        if (length > artifact.size) throw new Error('发布附件正文超过已核验大小');
        hash.update(chunk);
      }
      if (length !== artifact.size || hash.digest('hex') !== artifact.artifactSha256) {
        throw new Error(`发布附件正文摘要或大小不一致: ${artifact.key}`);
      }
    } finally {
      response.Body?.destroy();
    }
  }
}

async function main() {
  const args = parseArguments(process.argv.slice(2));
  const config = releaseConfig(process.env);
  const apkPath = resolve(args.apk);
  // Validate existing artifacts too, before any network write.
  execFileSync('pwsh', [
    '-NoProfile', '-File',
    fileURLToPath(new URL('./windows/Test-WenyouReleaseApk.ps1', import.meta.url)),
    '-ApkPath', apkPath,
  ], { stdio: ['ignore', 'ignore', 'pipe'] });
  const shaPath = resolve(args['sha256-file']);
  const manifestPath = resolve(args.manifest);
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  const apkFileName = basename(apkPath);
  const sidecarSha = parseSha256Sidecar(readFileSync(shaPath, 'utf8'), apkFileName);
  const actualApkSha = sha256File(apkPath);
  if (sidecarSha !== actualApkSha || manifest.apkSha256?.toLowerCase() !== actualApkSha) {
    throw new Error('本地 APK、sidecar 与构建摘要的 SHA-256 不一致');
  }
  const apkSize = statSync(apkPath).size;
  if (Number(manifest.apkSize) !== apkSize) throw new Error('构建摘要中的 APK 大小不一致');

  const plan = releaseObjectPlan({
    version: args.version,
    build: args.build,
    apkPath,
    shaPath,
    manifestPath,
    manifest,
  });
  const prefix = `${config.prefix}/`;
  const commonMetadata = {
    'apk-sha256': actualApkSha,
    'certificate-sha256': String(manifest.certificateSha256).toLowerCase(),
    'application-id': 'site.wenyou.app',
    'version-name': args.version,
    'version-code': String(args.build),
    'source-commit': String(manifest.sourceCommit || 'unknown'),
  };
  const artifacts = plan.map((artifact) => ({
    ...artifact,
    key: `${prefix}${artifact.fileName}`,
    size: statSync(artifact.path).size,
    artifactSha256: sha256File(artifact.path),
    apkSha256: actualApkSha,
    metadata: {
      ...commonMetadata,
      'artifact-sha256': sha256File(artifact.path),
    },
  }));

  const client = new S3Client({
    endpoint: config.endpoint,
    region: config.region,
    credentials: { accessKeyId: config.accessKeyId, secretAccessKey: config.secretAccessKey },
    forcePathStyle: true,
    maxAttempts: 2,
    requestHandler: { connectionTimeout: 10_000, requestTimeout: 60_000 },
  });
  for (const artifact of artifacts) await ensureUploaded(client, config, artifact);

  const publicUrl = `${config.publicBaseUrl.replace(/\/$/, '')}/${prefix}${apkFileName}`;
  await verifyPrivateArtifacts(client, config, artifacts);
  process.stdout.write(`${JSON.stringify({ url: publicUrl, size: apkSize, sha256: actualApkSha })}\n`);
}

const invokedDirectly = process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href;
if (invokedDirectly) {
  main().catch((error) => {
    process.stderr.write(`Android 发布对象上传失败: ${error.message}\n`);
    process.exitCode = 1;
  });
}
