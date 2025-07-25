BagPanel = {}

function BagPanel:Init()
    if  self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI","BagPanel")
        self.panelObj.transform:SetParent(Canvas,false)  -- 2.找到对应控件 再找到挂在身上想要的脚本

        self.BtnClose = self.panelObj.transform:Find("BG/BtnClose"):GetComponent(typeof(Button))
        self.BtnClose.onClick:AddListener(function() self.panelObj.gameObject:SetActive(false) end)
        
        self.DescPanel = self.panelObj.transform:Find("BG/Left")
        self.DescPanel.gameObject:SetActive(false)
        self.ImgPorpDesc = self.panelObj.transform:Find("BG/Left/Image"):GetComponent(typeof(Image))
        self.TextPorpDesc = self.panelObj.transform:Find("BG/Left/TextPorpDesc"):GetComponent(typeof(TextMeshPro))
        self.TextPorpName = self.panelObj.transform:Find("BG/Left/TextPorpName"):GetComponent(typeof(TextMeshPro))
        self.BtnDelete = self.panelObj.transform:Find("BG/Left/BtnDelete"):GetComponent(typeof(Button))
        self.BtnUse = self.panelObj.transform:Find("BG/Left/BtnUse"):GetComponent(typeof(Button))
        self.UsePanel = self.panelObj.transform:Find("BG/Left/UsePanel")
        self.BtnConfirm = self.UsePanel:Find("BtnConfirm"):GetComponent(typeof(Button))
        self.BtnCancel = self.UsePanel:Find("BtnCancel"):GetComponent(typeof(Button))
        self.Input = self.UsePanel:Find("Input"):GetComponent(typeof(TextMeshProInputField))

        self.BagContent = self.panelObj.transform:Find("BG/Right/Bag/Scroll View/Viewport/Content")
        self.BtnOrganize = self.panelObj.transform:Find("BG/Right/Button"):GetComponent(typeof(Button))
        

        self.BtnDelete.onClick:AddListener(function() self:BtnDelectOnClick() end)
        self.BtnUse.onClick:AddListener(function() self:BtnUseOnClick() end)
        self.BtnCancel.onClick:AddListener(function() self.UsePanel.gameObject:SetActive(false) end)
        self.BtnConfirm.onClick:AddListener(function() self:BtnConfirmOnClick() end)
        self.Input.onValueChanged:AddListener(function(value) self:CheckInputNum(tonumber(value)) end)
        self:InitData()
        self:SetSlot()

        self.onBagItemChangedCallback = function(...) self:OnBagItemChanged(...) end
        MessageSystem.RegisterListener("BAG_ITEM_CHANGED", self.onBagItemChangedCallback)
    end
end

function BagPanel:InitData()
    self.curSlot = nil
    self.curItemID = nil
    self.defalutUseNum = 1
end

function BagPanel:SetSlot()
    for slot, item in ipairs(PlayerInfo.Bag.slots) do
        local slotObj = self.BagContent:GetChild(slot-1).gameObject
        local ImgPorp = slotObj.transform:Find("ImgPorp"):GetComponent(typeof(Image))
        local ImgCheck = slotObj.transform:Find("Image"):GetComponent(typeof(Image))
        ImgPorp.sprite = PorpSpriteAltas:GetSprite(Config.PorpItemsByID[item.ID].FileName)
        ImgPorp.gameObject:SetActive(true)
        slotObj.transform:Find("TextNum"):GetComponent(typeof(TextMeshPro)).text = item.Count
        slotObj.transform:GetComponent(typeof(Button)).onClick:AddListener(function() self:BtnSlotOnClick(slot,item.ID) ImgCheck.gameObject:SetActive(true) end)
    end
end


function BagPanel:BtnSlotOnClick(slotIdx,ID)
    self.curSlot = slotIdx
    self.curItemID = ID
    self:ClearSelected()
    self:ShowPorpDesc(self.curItemID)
end

function BagPanel:ShowPorpDesc(ID)
    self.DescPanel.gameObject:SetActive(true)
    self.ImgPorpDesc.sprite = PorpSpriteAltas:GetSprite(Config.PorpItemsByID[ID].FileName)
    self.TextPorpDesc.text = Config.PorpItemsByID[ID].Desc
    self.TextPorpName.text = Config.PorpItemsByID[ID].Name
end
function BagPanel:ClearSelected()
    for i = 0, self.BagContent.childCount - 1 do
        local child = self.BagContent:GetChild(i)
        local ImgCheck = child.transform:Find("Image"):GetComponent(typeof(Image))
        ImgCheck.gameObject:SetActive(false)
    end
end
function BagPanel:BtnDelectOnClick()
    local res = BagMgr.DelItem(PlayerInfo.Bag,self.curSlot, self.curItemID)
    if res then
        local slotObj = self.BagContent:GetChild(self.curSlot-1).gameObject
        self.ClearSlot(slotObj)
        self.DescPanel.gameObject:SetActive(false)
    end
end

function BagPanel:BtnUseOnClick()
    self.UsePanel.gameObject:SetActive(true)
    self.Input.text = tostring(self.defalutUseNum)
end

function BagPanel:BtnConfirmOnClick()
    local useNum = tonumber(self.Input.text)
    if useNum == nil then 
        self.Input.text = tostring(self.defalutUseNum)
        return
    else
        if math.type(useNum) ~= "integer" or useNum <= 0 or useNum > PlayerInfo.Bag.slots[self.curSlot].Count then
            print("Invalid input")
            return
        else 
            local isEmpty, res, remain = BagMgr.UseItem(PlayerInfo.Bag,self.curSlot, self.curItemID,useNum)
            print("UseItem result:", res, "isEmpty:", isEmpty, "remain:", remain)
            if res then
                local slotObj = self.BagContent:GetChild(self.curSlot-1).gameObject
                if isEmpty then 
                    self.ClearSlot(slotObj)
                    self.DescPanel.gameObject:SetActive(false)
                else 
                    slotObj.transform:Find("TextNum"):GetComponent(typeof(TextMeshPro)).text = remain
                end
                self.UsePanel.gameObject:SetActive(false)
            end
        end
    end
end

function BagPanel.ClearSlot(slotObj)
    slotObj.transform:Find("ImgPorp"):GetComponent(typeof(Image)).sprite = nil
    slotObj.transform:Find("ImgPorp"):GetComponent(typeof(Image)).gameObject:SetActive(false)
    slotObj.transform:Find("Image"):GetComponent(typeof(Image)).gameObject:SetActive(false)
    slotObj.transform:Find("TextNum"):GetComponent(typeof(TextMeshPro)).text = ""
end

function BagPanel:CheckInputNum(value)
    print("CheckInputNum called with value:", value)
    if value ~= nil then
        if math.type(value) ~= "integer" or value <= 0 then
            self.Input.text = tostring(self.defalutUseNum)
        elseif value > PlayerInfo.Bag.slots[self.curItemID].Count then
            self.Input.text = tostring(PlayerInfo.Bag.slots[self.curSlot].Count)
        end
    end
end

function BagPanel:OnBagItemChanged(slotIdx, slotData)
    print("OnBagItemChanged called for slot:", slotIdx, "with data:", slotData)
    local slotObj = self.BagContent:GetChild(slotIdx-1).gameObject
    if slotObj then
        local ImgPorp = slotObj.transform:Find("ImgPorp"):GetComponent(typeof(Image))
        ImgPorp.sprite = PorpSpriteAltas:GetSprite(Config.PorpItemsByID[slotData.ID].FileName)
        ImgPorp.gameObject:SetActive(true)
        local ImgCheck = slotObj.transform:Find("Image"):GetComponent(typeof(Image))
        slotObj.transform:Find("TextNum"):GetComponent(typeof(TextMeshPro)).text = slotData.Count
        slotObj.transform:GetComponent(typeof(Button)).onClick:AddListener(function() self:BtnSlotOnClick(slotIdx,slotData.ID) ImgCheck.gameObject:SetActive(true) end)
    else
        self.ClearSlot(slotObj)
    end
    
end
function BagPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end