local BasePool = require("UI/Pools/BasePool")
local MsgRightPool = {}
MsgRightPool.__index = MsgRightPool
setmetatable(MsgRightPool, BasePool)


function MsgRightPool:new(prefab, parent, count)
    local self = BasePool.new(self, prefab, parent, count)
    return self
end

function MsgRightPool:clean(obj)
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

return MsgRightPool