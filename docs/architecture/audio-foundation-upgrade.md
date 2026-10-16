# 音频依赖升级候选

- Foundation 固定正式 Tag `v7.3.0`，解析提交 `a582d6ec498e26f30739d8bf6995f9613e26eb4d`；已读取 CHANGELOG、audio 体验契约与 Mobile profile。新增 `editor.audio`、`media.play`、`media.pause` 不使用本地替代资产。
- 同一依赖提交锁定 `just_audio 0.10.6`、`audio_session 0.2.4`（MIT）与 `file_selector 1.1.0`（BSD-3-Clause）。仅播放和文件选择，不录音、不添加麦克风权限或后台服务。Android 继续 API 26，iOS 继续 13。
- `flutter pub get` 已解析正式 Tag；定向主题与品牌同源测试覆盖本次升级。用户明确禁止合并前全量测试／门禁，本次不执行。
- 新增插件需要最终源码集中原生构建；依赖解析不代表音频功能、真机或负责人视觉验收完成。
