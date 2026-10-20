/// 仅用于本机待上传附件，发布/远端草稿和跨应用复制不得包含此标记。
const localAudioMarkerPrefix = 'https://local.invalid/wenyou-pending-audio/';
bool containsLocalAudioMarker(String source) =>
    source.contains(localAudioMarkerPrefix);
