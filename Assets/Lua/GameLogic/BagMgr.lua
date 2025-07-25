BagMgr = {}

function BagMgr.InitBag(size)
    local bag = {size = size, slots = {}}
    for i=1, size do
        bag.slots[i] = nil
    end
    return bag
end

function BagMgr:CreateBag(bagData,size)
    print(type(size))
    local bag = self.InitBag(size)
    for _,item in ipairs(bagData) do
        if item.slot and item.slot >= 1 and item.slot <=size then
            bag.slots[item.slot] = {ID = item.ID, Count = item.count}
        end
    end
    return bag
end

function BagMgr.GetItemCount(self,itemID)
    local count = 0
    for _,slot in pairs(self.slots) do
        if slot and slot.ID == itemID then
            count = count + slot.Count
        end
    end
end

function BagMgr.AddItem(self,itemID,count)
    -- 1. 先尝试叠加到已有格子
    for i = 1, self.size do
        local slot = self.slots[i]
        if slot and slot.ID == itemID and slot.Count < Config.PorpItemsByID[itemID].MaxStack then
            local canAdd = math.min(count, Config.PorpItemsByID[itemID].MaxStack - slot.Count)
            slot.Count = slot.Count + canAdd
            count = count - canAdd
            MessageSystem.Dispatch("BAG_ITEM_CHANGED", i, slot)
            if count <= 0 then return true end
        end
    end
    -- 2. 放入新的空格子
    for i = 1, self.size do
        local slot = self.slots[i]
        if not slot then
            local toAdd = math.min(count, Config.PorpItemsByID[itemID].MaxStack)
            slot = { ID = itemID, Count = toAdd}
            count = count - toAdd
            MessageSystem.Dispatch("BAG_ITEM_CHANGED", i, slot)
            if count <= 0 then return true end
        end
    end
    return false -- 没能完全添加
end

function BagMgr.DelItem(self,slotIdx,itemID)
    if self.slots[slotIdx].ID == itemID then
        self.slots[slotIdx] = nil
        return true
    else error("Item ID mismatch at slot " .. slotIdx) end
end

function BagMgr.UseItem(self,slotIdx,itemID,count)
    local remain = count
    local isEmpty = false

    local slot = self.slots[slotIdx]
    if slot.ID == itemID then
        if slot.Count >= remain then
            slot.Count = slot.Count - remain
            if slot.Count == 0 then
                self.slots[slotIdx] = nil -- 删除空格子
                isEmpty = true
            end
            return isEmpty, true, slot.Count
        end
    end
end