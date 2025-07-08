local BasePool = require("UI/Pools/BasePool")
local CardPool = {}
CardPool.__index = CardPool
setmetatable(CardPool, BasePool)


function CardPool:new(prefab, parent, count)
    local self = BasePool.new(self, prefab, parent, count)
    return self
end

function CardPool:clean(obj)
    local btn = obj:GetComponent("Button")
    if btn then
        btn.onClick:RemoveAllListeners()
    end
    local image = obj:GetComponent("Image")
    if image then
        image.sprite = nil
    end
end

return CardPool