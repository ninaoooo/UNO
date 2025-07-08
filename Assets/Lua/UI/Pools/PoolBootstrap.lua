local PoolMgr = require("UI/Pools/PoolMgr")
local CardPool = require("UI/Pools/CardPool")

PoolBootstrap = {}
function PoolBootstrap:init()
    print("PoolBootstrap:init() called")
    local cardPoolRoot = GameObject.Find("Main Camera/CardPoolRoot")
    local cardPrefab = ABMgr:LoadRawRes("modes", "BtnCard")
    print("cardPrefab prefab name: ", cardPrefab.name)
    local cardPool = CardPool:new(cardPrefab, cardPoolRoot.transform, 100)
    PoolMgr:register("card", cardPool)
    PoolMgr:printAllPoolNames()
    cardPool:warmup()
end

