local GameMatchBasePanel = require("UI/UILogic/GameMatchBasePanel")
local PlayerInfo = require("Tools/PlayerInfo")
local UnoGameLogic = require("GameLogic/UnoGameLogic")
local UnoUILogic = require("UI/UILogic/UnoUILogic")
local PoolMgr = require("UI/Pools/PoolMgr")

-- 子类定义：类级继承基类
local GameMatch1V1Panel = {}
setmetatable(GameMatch1V1Panel, { __index = GameMatchBasePanel })  -- 类级元表指向基类
GameMatch1V1Panel.__index = GameMatch1V1Panel  -- 实例级元表指向自身

-- 子类构造函数
function GameMatch1V1Panel:New()
    -- 1. 创建实例并继承基类元表
    local self = GameMatchBasePanel:New()
    -- 2. 覆盖元表为子类元表
    setmetatable(self, GameMatch1V1Panel)
    -- 3. 设置子类属性
    self.panelName = "GameMatch1v1Panel"
    return self
end

-- 子类必须实现的方法
function GameMatch1V1Panel:GetPositionMap()
    return {
        [1] = "Self",
        [2] = "Opponent"
    }
end

local ProfilerHelper = CS.LuaProfilerHelper

function GameMatch1V1Panel:cardPrefabsTest()
    local ProfilerHelper = CS.LuaProfilerHelper
    if ProfilerHelper == nil then
        print("LUA FATAL ERROR: CS.LuaProfilerHelper is NIL!")
        return
    end

    -- self.testConstainers  = self.panelObj.transform:Find("Test/GameObject"):GetComponent(typeof(Transform))
    -- self.testCardPrefabs = self.panelObj.transform:Find("Test/GameObject/Button"):GetComponent(typeof(Button))
    -- ProfilerHelper.BeginSample("Lua - Instantiate 100 Cards")
    -- for i = 1, 100, 1 do
    --     local card = GameObject.Instantiate(self.testCardPrefabs, self.testConstainers)
    -- end
    -- ProfilerHelper.EndSample()
    -- print("Test finished: 100 cards instantiated.")

    -- local cardPool = PoolMgr:getPool("card")
    -- if cardPool == nil then
    --     print("LUA FATAL ERROR: PoolMgr.get('card') returned NIL!")
    --     return
    -- end

    -- for i = 1, 100, 1 do
    --     local card = cardPool:get()
    --     if card == nil then
    --         print("LUA FATAL ERROR: cardPool:get() returned NIL!")
    --         return
    --     end
    -- end
    -- ProfilerHelper.BeginSample("Lua - Get 100 Cards From Pool")
    -- print("Test finished: 100 cards got.")
end

function GameMatch1V1Panel:Update()
    self.totalTimer:Update()
    self.actionTimer:Update()

    
    if InputMgr:GetKey(KeyCode.A) then
        -- self.GConfirmShow.gameObject:SetActive(true)
        -- local cardImage = self.showCard:GetComponent(typeof(Image))
        -- self:SetCardImg(cardImage, 1, 1)
        self:cardPrefabsTest()
    end
end

return GameMatch1V1Panel