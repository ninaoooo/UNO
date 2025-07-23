local BasePool = require("UI/Pools/BasePool")
local MsgLeftPool = {}
MsgLeftPool.__index = MsgLeftPool
setmetatable(MsgLeftPool, BasePool)


function MsgLeftPool:new(prefab, parent, count)
    local self = BasePool.new(self, prefab, parent, count)
    return self
end

function MsgLeftPool:clean(obj)
    print("MsgLeftPool:clean - Cleaning card object: ")
    local btn = obj.transform:Find("HorizonCnt/Image"):GetComponent("Button")
    if btn then
        btn.onClick:RemoveAllListeners()
    end
    local ImgAvatar = obj:GetComponent("ImgAvatar")
    if ImgAvatar then
        ImgAvatar.sprite = nil
    end
end

return MsgLeftPool