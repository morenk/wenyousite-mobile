#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR=$(pwd)
PLATFORM=android
VERSION_NAME=
BUILD_NUMBER=
SSH_TARGET=${WENYOU_RELEASE_SSH_TARGET:-root@wenyou.site}
REMOTE_BACKEND_DIR=${WENYOU_REMOTE_BACKEND_DIR:-/root/wenyousite/wenyousite-backend}
TESTFLIGHT_GROUP=${TESTFLIGHT_GROUP:-Wenyou Internal}
SKIP_CHECKS=false

usage() {
  cat <<'EOF'
从本地 Flutter 仓库构建并发布：
  bash tool/release-mobile-from-local.sh \
    --version 1.4.0 \
    --build 120 \
    --platform android|ios|both

Android 可选环境变量：
  WENYOU_RELEASE_SSH_TARGET   默认 root@wenyou.site
  WENYOU_REMOTE_BACKEND_DIR  默认 /root/wenyousite/wenyousite-backend

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
if [[ ! "$REMOTE_BACKEND_DIR" =~ ^/[0-9A-Za-z._/-]+$ ]]; then
  echo "WENYOU_REMOTE_BACKEND_DIR 必须是简单的绝对路径" >&2
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
    flutter pub get
    flutter analyze --fatal-infos --fatal-warnings
    flutter test
  )
fi

publish_android() {
  local apk_path
  local remote_stage
  local remote_command

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

  remote_stage="/tmp/wenyou-${VERSION_NAME}-${BUILD_NUMBER}-$$.apk"
  trap 'ssh "$SSH_TARGET" "rm -f -- $remote_stage" >/dev/null 2>&1 || true' RETURN
  scp -- "$apk_path" "$SSH_TARGET:$remote_stage"
  printf -v remote_command 'bash %q --source %q --version %q --build %q' \
    "$REMOTE_BACKEND_DIR/scripts/publish-android-release.sh" \
    "$remote_stage" \
    "$VERSION_NAME" \
    "$BUILD_NUMBER"
  ssh "$SSH_TARGET" "$remote_command"
  ssh "$SSH_TARGET" "rm -f -- $remote_stage"
  trap - RETURN
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

echo "移动端发布流程完成: $VERSION_NAME+$BUILD_NUMBER ($PLATFORM)"
