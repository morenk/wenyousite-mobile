import { spawn, execFileSync } from 'node:child_process';
import { createHash, randomBytes } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import net from 'node:net';
import { fileURLToPath } from 'node:url';

export const PACKAGE = 'site.wenyou.app.debug';
export const hash = value => createHash('sha256').update(value).digest('hex');
export const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
export function run(file, args, options = {}) {
  return execFileSync(file, args, { encoding: 'utf8', windowsHide: true, timeout: 30_000, stdio: ['ignore', 'pipe', 'pipe'], ...options }).trim();
}
export function canonical(directory) { return fs.realpathSync.native(directory).toLowerCase(); }
export function processIdentity(pid) {
  if (!Number.isSafeInteger(pid) || pid < 1) return null;
  try {
    return run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `(Get-Process -Id ${pid} -ErrorAction Stop).StartTime.ToUniversalTime().Ticks.ToString()`]);
  } catch { return null; }
}
export function sameProcess(record) { return Boolean(record?.pid && typeof record.processStarted === 'string' && record.processStarted.length && processIdentity(record.pid) === record.processStarted); }
export function killOwnedProcess(record) {
  if (record?.role === 'flutter' && record.jobProtected !== true) throw new Error('旧 Flutter 未受 Job Object 保护，无法证明后代已退出；保留设备锁与现场。');
  if (record?.pid && !record.processStarted) {
    try { process.kill(record.pid, 0); } catch { return; }
    throw new Error('遗留进程缺少开始时间，保留现场以免误杀。');
  }
  if (!sameProcess(record)) return;
  // 身份核验与停止在同一 PowerShell 内再检查一次，PID 重用不能误杀。
  run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `$p = Get-Process -Id ${record.pid} -ErrorAction SilentlyContinue; if ($p -and $p.StartTime.ToUniversalTime().Ticks.ToString() -eq '${record.processStarted}') { & taskkill.exe /PID $p.Id /T /F | Out-Null; if ($LASTEXITCODE -ne 0 -and (Get-Process -Id $p.Id -ErrorAction SilentlyContinue)) { throw 'Owned process tree stop failed' } }`]);
}
export function privateDirectory(directory) {
  fs.mkdirSync(directory, { recursive: true, mode: 0o700 });
  if (process.platform === 'win32') {
    // 已符合完整私有 ACL 时不重复 Set-Acl，避免重复启动触发 SeSecurityPrivilege。
    // 所有权、规则身份、权限和继承必须逐项相等；不能仅凭规则条数复用。
    const literal = `'${directory.replaceAll("'", "''")}'`;
    run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', `$ErrorActionPreference='Stop'; $sid=[System.Security.Principal.WindowsIdentity]::GetCurrent().User; $current=Get-Acl -LiteralPath ${literal}; $rules=@($current.GetAccessRules($true,$true,[System.Security.Principal.SecurityIdentifier])); $valid=$current.AreAccessRulesProtected -and $current.GetOwner([System.Security.Principal.SecurityIdentifier]).Value -eq $sid.Value -and $rules.Count -eq 2; foreach($rule in $rules) { $valid=$valid -and $rule.IdentityReference.Value -in @($sid.Value,'S-1-5-18') -and $rule.AccessControlType -eq 'Allow' -and $rule.FileSystemRights -eq 'FullControl' -and $rule.InheritanceFlags -eq 'ContainerInherit, ObjectInherit' -and $rule.PropagationFlags -eq 'None' -and !$rule.IsInherited }; if($valid -and @($rules.IdentityReference.Value | Select-Object -Unique).Count -eq 2) { exit 0 }; $acl=New-Object System.Security.AccessControl.DirectorySecurity; $acl.SetOwner($sid); $acl.SetAccessRuleProtection($true,$false); foreach($identity in @($sid,(New-Object System.Security.Principal.SecurityIdentifier('S-1-5-18')))) { $rule=New-Object System.Security.AccessControl.FileSystemAccessRule($identity,'FullControl','ContainerInherit,ObjectInherit','None','Allow'); $acl.AddAccessRule($rule) }; Set-Acl -LiteralPath ${literal} -AclObject $acl`]);
  } else fs.chmodSync(directory, 0o700);
}
export function readJson(file) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch (error) { if (error.code === 'ENOENT') return null; throw error; }
}
export function writeJson(file, value) {
  const temporary = `${file}.${randomBytes(8).toString('hex')}.tmp`;
  fs.writeFileSync(temporary, JSON.stringify(value, null, 2), { mode: 0o600 });
  fs.renameSync(temporary, file);
}
export function assertOwner(state, owner) {
  if (state.worktree !== owner.worktree || state.task !== owner.task || state.sessionId !== owner.sessionId || state.device !== owner.device || state.package !== PACKAGE) {
    throw new Error('会话属于其他任务、Worktree、预览批次或设备，拒绝接管。');
  }
}
export function acquireLock(file, owner) {
  try { fs.writeFileSync(file, JSON.stringify(owner), { flag: 'wx', mode: 0o600 }); }
  catch (error) {
    if (error.code !== 'EEXIST') throw error;
    throw new Error('同一设备的 Debug 包已有任务锁；先在原任务检查 dev:status/dev:stop。');
  }
}
export function releaseLock(file, token) {
  if (readJson(file)?.token === token) fs.unlinkSync(file);
}
export function sourceEvidence(cwd) {
  const paths = run('git', ['ls-files', '-z', '--cached', '--others', '--exclude-standard', '--', 'lib', 'android', 'assets', 'pubspec.yaml', 'pubspec.lock', 'packages', 'tool/dev'], { cwd, maxBuffer: 16 * 1024 * 1024 }).split('\0').filter(Boolean).sort();
  const digest = createHash('sha256');
  for (const file of paths) { digest.update(`${file}\0`); digest.update(fs.existsSync(path.join(cwd, file)) ? fs.readFileSync(path.join(cwd, file)) : '<deleted>'); }
  return { revision: run('git', ['rev-parse', 'HEAD'], { cwd }), sourceDigest: digest.digest('hex') };
}
export function selectDevice(devices, requested) {
  const eligible = devices.filter(d => d.state === 'device' && d.abi === 'arm64-v8a' && !d.id.startsWith('emulator-'));
  const found = requested ? eligible.filter(d => d.id === requested) : eligible;
  if (found.length !== 1) throw new Error('需要唯一已连接的 ARM64 真机；多设备时显式传 --device。');
  return found[0].id;
}
export function findAdb() {
  const roots = [process.env.ANDROID_SDK_ROOT, process.env.ANDROID_HOME, 'D:\\sdk\\android'].filter(Boolean);
  return roots.map(root => path.join(root, 'platform-tools', 'adb.exe')).find(fs.existsSync) ?? 'adb.exe';
}
export function discoverDevice(adb, requested) {
  const devices = run(adb, ['devices']).split(/\r?\n/).slice(1).map(line => {
    const [id, state] = line.trim().split(/\s+/);
    return { id, state, abi: state === 'device' ? run(adb, ['-s', id, 'shell', 'getprop', 'ro.product.cpu.abi']) : '' };
  });
  return selectDevice(devices, requested);
}
export function competingFlutter(commandLine, device) {
  if (!/flutter_tools(?:\.snapshot|\.dart)/i.test(commandLine) || !/\srun(?:\s|$)/.test(commandLine)) return false;
  const target = commandLine.match(/(?:\s-d\s+|\s--device-id(?:=|\s+))"?([^"\s]+)/);
  return !target || target[1] === device;
}
export function assertNoCompetingFlutter(device) {
  const processes = JSON.parse(run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', "@(Get-CimInstance Win32_Process -Filter \"Name = 'dart.exe'\" | Select-Object -ExpandProperty CommandLine) | ConvertTo-Json -Compress"] ) || '[]');
  if ([processes].flat().some(command => competingFlutter(command ?? '', device))) throw new Error('设备可能由已有 Flutter/IDE 会话使用；请在原任务停止，不能接管。');
}
export function installedPackageEvidence(adb, device, { includeHash = false } = {}) {
  const details = run(adb, ['-s', device, 'shell', 'dumpsys', 'package', PACKAGE]);
  const lastUpdateTime = details.match(/lastUpdateTime=([^\r\n]+)/)?.[1]?.trim();
  const appPid = run(adb, ['-s', device, 'shell', 'pidof', PACKAGE]);
  if (!lastUpdateTime || !/^\d+(?:\s+\d+)*$/.test(appPid)) throw new Error('无法核对已安装 Debug 包的更新时间与进程。');
  const result = { package: PACKAGE, appPid, lastUpdateTime };
  if (includeHash) {
    const apk = run(adb, ['-s', device, 'shell', 'pm', 'path', PACKAGE]).split(/\r?\n/).find(line => line.endsWith('/base.apk'))?.replace(/^package:/, '');
    if (!apk || !/^\/data\/app\/[a-zA-Z0-9_./=+~\-]+\/base\.apk$/.test(apk)) throw new Error('Debug APK 设备路径无法安全核验。');
    const digest = run(adb, ['-s', device, 'shell', 'sha256sum', apk]).split(/\s+/)[0];
    if (!/^[a-f0-9]{64}$/.test(digest)) throw new Error('Debug APK 哈希核验失败。');
    result.apkSha256 = digest;
  }
  return result;
}
export function flutterCommand() {
  let discovered;
  try { discovered = path.dirname(path.dirname(run('pwsh.exe', ['-NoProfile', '-NonInteractive', '-Command', '(Get-Command flutter -CommandType Application -ErrorAction Stop).Source']))); } catch {}
  const roots = [process.env.FLUTTER_ROOT, discovered, 'D:\\sdk\\flutter'].filter(Boolean);
  const root = roots.find(value => fs.existsSync(path.join(value, 'bin', 'cache', 'flutter_tools.snapshot')));
  if (!root) throw new Error('找不到 Flutter SDK；请设置 FLUTTER_ROOT 并先运行 flutter doctor。');
  // 直接启动 SDK dart 可可靠保存 PID，避免 .bat/cmd 子进程遗留。
  return { file: path.join(root, 'bin', 'cache', 'dart-sdk', 'bin', 'dart.exe'), prefix: [path.join(root, 'bin', 'cache', 'flutter_tools.snapshot')] };
}
export function assertDebugPackageConfiguration(cwd) {
  const gradle = fs.readFileSync(path.join(cwd, 'android', 'app', 'build.gradle.kts'), 'utf8');
  if (!/defaultConfig\s*\{[^}]*applicationId\s*=\s*"site\.wenyou\.app"/.test(gradle) || !/getByName\("debug"\)\s*\{[^}]*applicationIdSuffix\s*=\s*"\.debug"/.test(gradle)) throw new Error('Android Debug applicationId 配置已变化；拒绝安装到未知应用。');
}
export function ownedSpawn(file, args, options = {}) {
  const child = spawn(file, args, { windowsHide: true, stdio: ['pipe', 'pipe', 'pipe'], ...options });
  return child;
}
export function jobSpawn(file, args, options = {}) {
  const ownerStarted = processIdentity(process.pid);
  if (!ownerStarted) throw new Error('无法绑定后台进程归属。');
  return ownedSpawn('pwsh.exe', ['-NoProfile', '-NonInteractive', '-File', fileURLToPath(new URL('./job-launch.ps1', import.meta.url)), '-Executable', file, '-ArgumentsBase64', Buffer.from(JSON.stringify(args)).toString('base64'), '-OwnerPid', String(process.pid), '-OwnerStarted', ownerStarted], options);
}
export function portOpen(port) {
  return new Promise(resolve => {
    const socket = net.connect({ port, host: '127.0.0.1' });
    socket.setTimeout(1000);
    const done = value => { socket.destroy(); resolve(value); };
    socket.once('connect', () => done(true));
    socket.once('timeout', () => done(false));
    socket.once('error', () => done(false));
  });
}
