local PoolMgr = require("UI/Pools/PoolMgr")
local CardPool = require("UI/Pools/CardPool")
local MsgLeftPool = require("UI/Pools/MsgLeftPool")
local MsgRightPool = require("UI/Pools/MsgRightPool")
PoolBootstrap = {}
function PoolBootstrap:init()
    local cardPoolRoot = GameObject.Find("Main Camera/CardPoolRoot")
    local cardPrefab = ABMgr:LoadRawRes("modes", "BtnCard")
    local cardPool = CardPool:new(cardPrefab, cardPoolRoot.transform, 100)
    PoolMgr:register("card", cardPool)
    cardPool:warmup()

    local msgLeftPoolRoot = GameObject.Find("Main Camera/MsgLeftPoolRoot")
    local msgLeftPrefab = ABMgr:LoadRawRes("modes", "MsgLeft")
    local msgLeftPool = MsgLeftPool:new(msgLeftPrefab, msgLeftPoolRoot.transform, 100)
    PoolMgr:register("msgLeftPool", msgLeftPool)
    msgLeftPool:warmup()

    local msgRightPoolRoot = GameObject.Find("Main Camera/MsgRightPoolRoot")
    local msgRightPrefab = ABMgr:LoadRawRes("modes", "MsgRight")
    local msgRightPool = MsgRightPool:new(msgRightPrefab, msgRightPoolRoot.transform, 100)
    PoolMgr:register("msgRightPool", msgRightPool)
    msgRightPool:warmup()

end

