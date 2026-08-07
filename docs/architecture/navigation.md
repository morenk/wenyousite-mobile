# 导航

go_router 是唯一导航入口。根级兼容检查先于业务路由；未知契约主版本进入升级提示页，网络失败进入可重试页。

主导航使用保留状态的四分支壳：首页 `/home`、搜索 `/search`、通知 `/notifications`、我的 `/me`。悬浮创建按钮是独立入口 `/compose/thread`，未登录时先去 `/auth/login?returnTo=/compose/thread`，成功后恢复原目标。回跳只接受仓库内绝对路径并拒绝认证页自循环；主题、楼层、用户和通知目标使用命名路由，禁止页面自行拼接不透明参数。

V1 不配置 Android App Links。应用内部仍使用稳定路径，给后续深链留下兼容边界。

参见：[应用壳](../modules/app-shell.md)、[认证](../modules/auth.md)。
