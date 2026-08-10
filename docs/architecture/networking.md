# 网络与会话

## 环境

`AppEnvironment` 从 `--dart-define=API_BASE_URL=...` 读取地址。Debug 默认值为 `https://wenyou.site/api/v1`；Android 模拟器连接本地后端时使用 `http://10.0.2.2:3000/api/v1`。生成客户端的 endpoint 已包含 `/api/v1`，因此底层 Dio 只使用配置地址的 origin，避免版本路径重复拼接。业务代码只依赖注入后的 Dio 和仓储，不读取全局常量。

## 请求链

每个请求生成 UUID v4 `X-Request-ID`。登录和完成注册额外发送 `X-Client-Platform: mobile`。日志只记录方法、脱敏路径、请求 ID、HTTP 状态、业务码和响应契约版本；所有查询参数与 fragment 都在格式化前截断，`/threads/join-by-link/{token}` 的私密邀请 token 固定替换为 `<redacted>`。Debug 包额外记录传输或序列化异常原因，不记录认证头、密码、验证码、正文、预签名 URL 查询参数、邀请凭据或隐私资料。

Access Token 与 Refresh Token 都保存到安全存储。刷新和退出由无业务拦截器的独立生成客户端发起，避免刷新请求递归进入 `40101` 拦截链。并发请求遇到 `40101` 时共享同一个刷新 Future；刷新成功后原子替换双 Token，每个原请求最多重放一次。`40103` 至 `40106`、刷新失败或重放仍为 `40101` 时清空会话并携带失效原因进入登录页。

退出当前终端时同时提交 bearer 与 refresh token；若 access token 已过期，先共享刷新再重试退出一次。服务端成功或明确判定会话失效后清除本机 Token；网络/5xx 失败保留会话和请求 ID供重试。只有用户在风险提示中再次确认，才允许仅清除本机登录。

Cursor 是不透明字符串。筛选变化清空 cursor；`40007` 清空列表并从第一页重载。自动重试只覆盖 GET、明确幂等方法以及携带稳定 `clientRequestId` 的创建请求。

## 错误模型

`ApiFailure` 保存 HTTP 状态、业务错误码、请求 ID、响应契约版本和安全的用户提示。程序逻辑按业务码分支，不解析后端中文 message。未知响应或序列化失败降级为通用错误，同时保留请求 ID供排障。

验证码等限流写操作不自动重放；`42900` 只读取整数秒 `Retry-After` 并在 UI 建立冷却倒计时，由用户到期后明确重试。注册的验证码和密码只存在于页面/控制器内存，完成、返回修改邮箱或页面销毁后不持久化。

参见：[API 生成](api-generation.md)、[应用壳](../modules/app-shell.md)、[认证](../modules/auth.md)。
