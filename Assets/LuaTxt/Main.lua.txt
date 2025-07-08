print("Lua主入口")
require("Base/MessageSystem")
require("Tools/InitClass")
require("UI/Pools/PoolBootstrap")
PoolBootstrap:init()

-- 初始化所有的类别名

require("UIPanels")

RpcMgr:InitModule()
StartPanel:ShowMe()

