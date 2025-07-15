local PoolMgr = require("UI/Pools/PoolMgr")
local CardPool = require("UI/Pools/CardPool")

PoolBootstrap = {}
function PoolBootstrap:init()
    local cardPoolRoot = GameObject.Find("Main Camera/CardPoolRoot")
    local cardPrefab = ABMgr:LoadRawRes("modes", "BtnCard")
    local cardPool = CardPool:new(cardPrefab, cardPoolRoot.transform, 100)
    PoolMgr:register("card", cardPool)
    cardPool:warmup()
end

