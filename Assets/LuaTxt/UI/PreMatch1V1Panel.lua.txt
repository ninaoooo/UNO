local PreMatchBasePanel = require("UI/UILogic/PreMatchBasePanel")

-- 子类定义：类级继承基类
local PreMatch1V1Panel = {}
setmetatable(PreMatch1V1Panel, { __index = PreMatchBasePanel })  -- 类级元表指向基类
PreMatch1V1Panel.__index = PreMatch1V1Panel  -- 实例级元表指向自身

-- 子类构造函数
function PreMatch1V1Panel:New()
    -- 1. 创建实例并继承基类元表
    local self = PreMatchBasePanel:New()
    -- 2. 覆盖元表为子类元表
    setmetatable(self, PreMatch1V1Panel)
    -- 3. 设置子类属性
    self.panelName = "PreMatchPanel"
    return self
end

-- 子类必须实现的方法
function PreMatch1V1Panel:ShowMe()
    self:Init(2,UnoCommonConfig.Match1v1NeedGold)
    self.panelObj:SetActive(true)
end

function PreMatch1V1Panel:GetMatchModeToRpc()
    return 3
end

function PreMatch1V1Panel:GetCancelMatchModeToRpc()
    return 3
end

return PreMatch1V1Panel