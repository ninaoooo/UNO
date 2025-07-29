local BasePool = require("UI/Pools/BasePool")
local CardPool = {}
CardPool.__index = CardPool
setmetatable(CardPool, BasePool)


function CardPool:new(prefab, parent, count)
    local instance = BasePool.new(self, prefab, parent, count)
    setmetatable(instance, self)
    return instance
end

function CardPool:clean(obj)
    print("CardPool:clean - Cleaning card object: ")
    local rectTransform = obj:GetComponent(typeof(CS.UnityEngine.RectTransform))
    rectTransform.localPosition = Vector3(0, 0, 0)
    
    -- 2. 清除旋转（完全重置）
    rectTransform.localRotation = CS.UnityEngine.Quaternion.identity
    
    -- 3. 清除缩放（恢复为 1,1,1）
    rectTransform.localScale = CS.UnityEngine.Vector3(1, 1, 1)
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