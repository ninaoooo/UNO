print("Lua主入口")
-- 初始化所有的类别名
require("Base/MessageSystem")
require("Tools/InitClass")
require("UIPanels")
RpcMgr:InitModule()
StartPanel:ShowMe()
