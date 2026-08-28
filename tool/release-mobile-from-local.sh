#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
PLATFORM=android
VERSION_NAME=
BUILD_NUMBER=
SSH_TARGET=${WENYOU_RELEASE_SSH_TARGET:-wenyou-release@wenyou.site}
REMOTE_PROMOTE_COMMAND=${WENYOU_RELEASE_REMOTE_PROMOTE_COMMAND:-/usr/local/sbin/wenyousite-promote-android}
TESTFLIGHT_GROUP=${TESTFLIGHT_GROUP:-Wenyou Internal}
SKIP_CHECKS=false
BUILD_ONLY=false
UPLOAD_ONLY=false
ANDROID_RELEASE_APK=
ANDROID_RELEASE_SHA256=
ANDROID_RELEASE_MANIFEST=

usage() {
  cat <<'EOF'
从本地 Flutter 仓库构建并发布：
  bash tool/release-mobile-from-local.sh \
    --version 1.4.0 \
    --build 120 \
    --platform android|ios|both

只在本机构建、验签并生成发布制品：
  bash tool/release-mobile-from-local.sh \
    --version 1.4.0 \
    --build 120 \
    --platform android \
    --build-only

上传对象存储但不更新服务端推荐版本：
  bash tool/release-mobile-from-local.sh \
    --version 1.4.0 \
    --build 120 \
    --platform android \
    --upload-only

Android 可选环境变量：
  WENYOU_RELEASE_S3_ENDPOINT          默认 https://cn-nb1.rains3.com
  WENYOU_RELEASE_S3_REGION            默认 auto
  WENYOU_RELEASE_S3_BUCKET            默认 wenyou-apk
  WENYOU_RELEASE_S3_PREFIX            默认 mobile/android
  WENYOU_RELEASE_PUBLIC_BASE_URL      默认 https://wenyou-apk.cn-nb1.rains3.com
  WENYOU_RELEASE_S3_ACCESS_KEY_ID     发布桶专用 AccessKey
  WENYOU_RELEASE_S3_SECRET_ACCESS_KEY 发布桶专用 SecretKey
  WENYOU_RELEASE_SSH_TARGET           默认 wenyou-release@wenyou.site
  WENYOU_RELEASE_REMOTE_PROMOTE_COMMAND  VPS 版本晋级命令

iOS 必需环境变量：
  APP_STORE_CONNECT_API_KEY_JSON  fastlane API Key JSON 的绝对路径
  TESTFLIGHT_GROUP                TestFlight 外部测试组名称
EOF
}

while (($# > 0)); do
  case "$1" in
    --project)
      PROJECT_DIR=${2:-}
      shift 2
      ;;
    --platform)
      PLATFORM=${2:-}
      shift 2
      ;;
    --version)
      VERSION_NAME=${2:-}
      shift 2
      ;;
    --build)
      BUILD_NUMBER=${2:-}
      shift 2
      ;;
    --host)
      SSH_TARGET=${2:-}
      shift 2
      ;;
    --skip-checks)
      SKIP_CHECKS=true
      shift
      ;;
    --build-only)
      BUILD_ONLY=true
      shift
      ;;
    --upload-only)
      UPLOAD_ONLY=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! "$VERSION_NAME" =~ ^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$ ]]; then
  echo "--version 格式不合法" >&2
  exit 2
fi
if [[ ! "$BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]]; then
  echo "--build 必须是正整数" >&2
  exit 2
fi
if [[ ! "$PLATFORM" =~ ^(android|ios|both)$ ]]; then
  echo "--platform 只能是 android、ios 或 both" >&2
  exit 2
fi
if [ "$BUILD_ONLY" = true ] && [ "$UPLOAD_ONLY" = true ]; then
  echo "--build-only 与 --upload-only 不能同时使用" >&2
  exit 2
fi
if [ "$UPLOAD_ONLY" = true ] && [ "$PLATFORM" != android ]; then
  echo "--upload-only 仅支持 Android" >&2
  exit 2
fi
if [[ ! "$REMOTE_PROMOTE_COMMAND" =~ ^/[0-9A-Za-z._/-]+$ ]]; then
  echo "WENYOU_RELEASE_REMOTE_PROMOTE_COMMAND 必须是简单的绝对路径" >&2
  exit 2
fi
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
  echo "找不到 Flutter 项目: $PROJECT_DIR" >&2
  exit 2
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo "本机未安装 flutter" >&2
  exit 2
fi

PROJECT_DIR=$(cd -- "$PROJECT_DIR" && pwd)

if [ "$SKIP_CHECKS" != true ]; then
  (
    cd "$PROJECT_DIR"
    npm run check
  )
fi

resolve_android_sdk() {
  local configured=${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}

  if [ -z "$configured" ]; then
    configured=$(
      flutter config --list 2>/dev/null \
        | sed -n 's/^[[:space:]]*android-sdk:[[:space:]]*//p' \
        | head -n 1
    )
  fi
  if [ -z "$configured" ]; then
    echo "无法定位 Android SDK；请设置 ANDROID_SDK_ROOT 或运行 flutter config --android-sdk" >&2
    return 1
  fi
  if command -v cygpath >/dev/null 2>&1 && [[ "$configured" =~ ^[A-Za-z]:[\\/].* ]]; then
    configured=$(cygpath -u "$configured")
  fi
  if [ ! -d "$configured/build-tools" ]; then
    echo "Android SDK 缺少 build-tools: $configured" >&2
    return 1
  fi
  printf '%s\n' "$configured"
}

find_android_tool() {
  local directory=$1
  local name=$2
  local candidate

  for candidate in "$directory/$name" "$directory/$name.exe" "$directory/$name.bat"; do
    if [ -f "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "Android build-tools 缺少 $name: $directory" >&2
  return 1
}

verify_android_elf_page_alignment() {
  local apk_path=$1
  local android_sdk=$2
  local ndk_dir
  local host_dir
  local readelf
  local extract_dir
  local library
  local load_alignment
  local library_count=0

  ndk_dir=$(find "$android_sdk/ndk" -mindepth 1 -maxdepth 1 -type d -print | sort -V | tail -n 1)
  if [ -z "$ndk_dir" ]; then
    echo "Android SDK 没有可用的 NDK，无法检查 ELF 页面对齐: $android_sdk" >&2
    return 1
  fi
  host_dir=$(find "$ndk_dir/toolchains/llvm/prebuilt" -mindepth 1 -maxdepth 1 -type d -print | head -n 1)
  if [ -z "$host_dir" ]; then
    echo "Android NDK 缺少 LLVM host tools: $ndk_dir" >&2
    return 1
  fi
  readelf=$(find_android_tool "$host_dir/bin" llvm-readelf)
  extract_dir=$(mktemp -d)
  if ! unzip -qq "$apk_path" 'lib/*/*.so' -d "$extract_dir"; then
    rm -rf -- "$extract_dir"
    echo "无法从 APK 提取原生库以检查 16 KB 页面支持" >&2
    return 1
  fi

  while IFS= read -r library; do
    library_count=$((library_count + 1))
    while IFS= read -r load_alignment; do
      if ((load_alignment < 0x4000)); then
        rm -rf -- "$extract_dir"
        echo "原生库 LOAD 段未按 16 KB 对齐: ${library#"$extract_dir"/} align=$load_alignment" >&2
        return 1
      fi
    done < <(
      "$readelf" --program-headers --wide "$library" \
        | awk '$1 == "LOAD" { print $NF }'
    )
  done < <(find "$extract_dir/lib" -type f -name '*.so' -print)

  rm -rf -- "$extract_dir"
  if ((library_count == 0)); then
    echo "APK 中没有可检查的原生库" >&2
    return 1
  fi
}

build_android() {
  local apk_path
  local android_sdk
  local build_tools_dir
  local apksigner
  local zipalign
  local aapt
  local package_line
  local certificate_output
  local certificate_sha256
  local release_dir
  local release_base
  local release_apk
  local sha256_file
  local summary_file
  local apk_sha256
  local apk_size
  local source_commit
  local created_at

  if [ ! -f "$PROJECT_DIR/android/key.properties" ]; then
    echo "缺少 android/key.properties，不能生成可持续覆盖安装的正式签名 APK" >&2
    return 1
  fi
  local signing_key
  for signing_key in storePassword keyPassword keyAlias storeFile; do
    if ! grep -Eq "^${signing_key}=.+$" "$PROJECT_DIR/android/key.properties"; then
      echo "android/key.properties 缺少 ${signing_key}" >&2
      return 1
    fi
  done

  (cd "$PROJECT_DIR" && flutter build apk --release --build-name "$VERSION_NAME" --build-number "$BUILD_NUMBER")
  apk_path="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
  if [ ! -f "$apk_path" ]; then
    echo "Android release APK 未生成: $apk_path" >&2
    return 1
  fi

  android_sdk=$(resolve_android_sdk)
  build_tools_dir=$(find "$android_sdk/build-tools" -mindepth 1 -maxdepth 1 -type d -print | sort -V | tail -n 1)
  if [ -z "$build_tools_dir" ]; then
    echo "Android SDK 没有可用的 build-tools: $android_sdk" >&2
    return 1
  fi
  apksigner=$(find_android_tool "$build_tools_dir" apksigner)
  zipalign=$(find_android_tool "$build_tools_dir" zipalign)
  aapt=$(find_android_tool "$build_tools_dir" aapt)

  "$zipalign" -c -P 16 4 "$apk_path" >/dev/null
  verify_android_elf_page_alignment "$apk_path" "$android_sdk"
  certificate_output=$("$apksigner" verify --verbose --print-certs "$apk_path")
  certificate_sha256=$(
    printf '%s\n' "$certificate_output" \
      | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' \
      | head -n 1
  )
  if [ -z "$certificate_sha256" ]; then
    echo "无法读取 APK 签名证书摘要" >&2
    return 1
  fi
  package_line=$("$aapt" dump badging "$apk_path" | sed -n '1p')
  if [[ "$package_line" != *"name='site.wenyou.app'"* ]]; then
    echo "APK applicationId 不是 site.wenyou.app" >&2
    return 1
  fi
  if [[ "$package_line" != *"versionCode='$BUILD_NUMBER'"* ]]; then
    echo "APK versionCode 与 --build 不一致" >&2
    return 1
  fi
  if [[ "$package_line" != *"versionName='$VERSION_NAME'"* ]]; then
    echo "APK versionName 与 --version 不一致" >&2
    return 1
  fi

  release_dir="$PROJECT_DIR/build/releases"
  release_base="wenyou-${VERSION_NAME}-${BUILD_NUMBER}"
  release_apk="$release_dir/${release_base}.apk"
  sha256_file="$release_dir/${release_base}.apk.sha256"
  summary_file="$release_dir/${release_base}.json"
  mkdir -p "$release_dir"
  cp -f -- "$apk_path" "$release_apk"
  apk_sha256=$(sha256sum "$release_apk" | awk '{print $1}')
  apk_size=$(wc -c < "$release_apk" | tr -d '[:space:]')
  source_commit=$(git -C "$PROJECT_DIR" rev-parse HEAD)
  created_at=$(date --utc +'%Y-%m-%dT%H:%M:%SZ')
  printf '%s  %s\n' "$apk_sha256" "${release_base}.apk" > "$sha256_file"
  cat > "$summary_file" <<EOF
{
  "applicationId": "site.wenyou.app",
  "versionName": "$VERSION_NAME",
  "versionCode": $BUILD_NUMBER,
  "certificateSha256": "$certificate_sha256",
  "apkSha256": "$apk_sha256",
  "apkSize": $apk_size,
  "apkFile": "${release_base}.apk",
  "sourceCommit": "$source_commit",
  "createdAt": "$created_at"
}
EOF

  ANDROID_RELEASE_APK=$release_apk
  ANDROID_RELEASE_SHA256=$sha256_file
  ANDROID_RELEASE_MANIFEST=$summary_file
  echo "Android release APK 已构建并验签: $ANDROID_RELEASE_APK"
  echo "签名证书 SHA-256: $certificate_sha256"
  echo "APK SHA-256: $apk_sha256"
}

publish_android() {
  local apk_path
  local upload_result
  local update_url
  local apk_size
  local apk_sha256
  local remote_command

  build_android
  apk_path=$ANDROID_RELEASE_APK
  if [ "$BUILD_ONLY" = true ]; then
    echo "--build-only 已启用，跳过 Android 上传"
    return 0
  fi

  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "发布对象存储需要 Node.js 与 npm" >&2
    return 1
  fi
  (cd "$PROJECT_DIR" && npm ci --ignore-scripts)
  upload_result=$(node "$PROJECT_DIR/tool/upload_android_release.mjs" \
    --apk "$apk_path" \
    --sha256-file "$ANDROID_RELEASE_SHA256" \
    --manifest "$ANDROID_RELEASE_MANIFEST" \
    --version "$VERSION_NAME" \
    --build "$BUILD_NUMBER")
  update_url=$(printf '%s' "$upload_result" | node -e \
    'let input=""; process.stdin.on("data", chunk => input += chunk).on("end", () => process.stdout.write(JSON.parse(input).url));')
  apk_size=$(printf '%s' "$upload_result" | node -e \
    'let input=""; process.stdin.on("data", chunk => input += chunk).on("end", () => process.stdout.write(String(JSON.parse(input).size)));')
  apk_sha256=$(printf '%s' "$upload_result" | node -e \
    'let input=""; process.stdin.on("data", chunk => input += chunk).on("end", () => process.stdout.write(JSON.parse(input).sha256));')

  if [ "$UPLOAD_ONLY" = true ]; then
    echo "--upload-only 已启用，APK 已上传但尚未向用户推荐: $update_url"
    return 0
  fi

  printf -v remote_command 'sudo -n %q --version %q --build %q --url %q --size %q --sha256 %q' \
    "$REMOTE_PROMOTE_COMMAND" \
    "$VERSION_NAME" \
    "$BUILD_NUMBER" \
    "$update_url" \
    "$apk_size" \
    "$apk_sha256"
  ssh "$SSH_TARGET" "$remote_command"
}

publish_ios() {
  local ipa_path
  local api_key_json=${APP_STORE_CONNECT_API_KEY_JSON:-}

  if [ "$(uname -s)" != Darwin ]; then
    echo "iOS 只能在 macOS 上构建" >&2
    return 1
  fi
  if ! command -v fastlane >/dev/null 2>&1; then
    echo "本机未安装 fastlane" >&2
    return 1
  fi
  if [ -z "$api_key_json" ] || [ ! -f "$api_key_json" ]; then
    echo "请设置 APP_STORE_CONNECT_API_KEY_JSON" >&2
    return 1
  fi

  (cd "$PROJECT_DIR" && flutter build ipa --release --build-name "$VERSION_NAME" --build-number "$BUILD_NUMBER")
  ipa_path=$(find "$PROJECT_DIR/build/ios/ipa" -maxdepth 1 -type f -name '*.ipa' -print -quit)
  if [ -z "$ipa_path" ]; then
    echo "iOS IPA 未生成" >&2
    return 1
  fi
  if [ "$BUILD_ONLY" = true ]; then
    echo "iOS release IPA 已构建: $ipa_path"
    echo "--build-only 已启用，跳过 TestFlight 上传"
    return 0
  fi

  fastlane pilot upload \
    --ipa "$ipa_path" \
    --api_key_path "$api_key_json" \
    --distribute_external true \
    --groups "$TESTFLIGHT_GROUP" \
    --notify_external_testers true
}

case "$PLATFORM" in
  android)
    publish_android
    ;;
  ios)
    publish_ios
    ;;
  both)
    publish_android
    publish_ios
    ;;
esac

if [ "$BUILD_ONLY" = true ]; then
  echo "移动端本地构建完成: $VERSION_NAME+$BUILD_NUMBER ($PLATFORM)"
elif [ "$UPLOAD_ONLY" = true ]; then
  echo "移动端对象上传完成，尚未晋级: $VERSION_NAME+$BUILD_NUMBER ($PLATFORM)"
else
  echo "移动端发布流程完成: $VERSION_NAME+$BUILD_NUMBER ($PLATFORM)"
fi
