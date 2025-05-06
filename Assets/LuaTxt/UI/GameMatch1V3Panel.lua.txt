local GameMatchBasePanel = require("UI/UILogic/GameMatchBasePanel")
local PlayerInfo = require("Tools/PlayerInfo")
local UnoGameLogic = require("GameLogic/UnoGameLogic")
local UnoUILogic = require("UI/UILogic/UnoUILogic")

-- 子类定义：类级继承基类
local GameMatch1V3Panel = {}
setmetatable(GameMatch1V3Panel, { __index = GameMatchBasePanel })  -- 类级元表指向基类
GameMatch1V3Panel.__index = GameMatch1V3Panel  -- 实例级元表指向自身

-- 子类构造函数
function GameMatch1V3Panel:New()
    -- 1. 创建实例并继承基类元表
    local self = GameMatchBasePanel:New()
    -- 2. 覆盖元表为子类元表
    setmetatable(self, GameMatch1V3Panel)
    -- 3. 设置子类属性
    self.panelName = "GameMatch1V3Panel"
    return self
end

-- 子类必须实现的方法
function GameMatch1V3Panel:GetPositionMap()
    return {
        [1] = "Self",
        [2] = "Left",
        [3] = "Opponent",
        [4] = "Right"
    }
end


return GameMatch1V3Panel