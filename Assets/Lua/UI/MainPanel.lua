MainPanel = {}

MainPanel.panelObj = nil
MainPanel.BtnAvatar = nil
MainPanel.BtnDiamondAdd = nil
MainPanel.TextDiamond = nil
MainPanel.BtnGlodAdd = nil
MainPanel.TextGlod = nil
MainPanel.BtnSetting = nil
MainPanel.BtnStore = nil
MainPanel.BtnModeMatch1V1 = nil
MainPanel.BtnModeRoom = nil

function MainPanel:Init()
    if  self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI","MainPanel")
        self.panelObj.transform:SetParent(Canvas,false)        -- 2.找到对应控件 再找到挂在身上想要的脚本
        
        self.BtnAvatar = self.panelObj.transform:Find("GAvatar/BtnAvatar"):GetComponent(typeof(Button))
        self.BtnAvatar:GetComponent(typeof(Image)).sprite = ABMgr:LoadRes("unocardimage", "Blue_1")

        self.BtnSetting = self.panelObj.transform:Find("GSettings/Button"):GetComponent(typeof(Button))
        self.BtnStore = self.panelObj.transform:Find("GStore/Button"):GetComponent(typeof(Button))
        self.BtnModeMatch1V1 = self.panelObj.transform:Find("GPlayMode/Button"):GetComponent(typeof(Button))
        -- 3.为控件加上事件监听 进行点击等的逻辑处理
        self.BtnModeMatch1V1.onClick:AddListener(function() self:OnBtnModeMatch1V1Click() end)
        self.BtnAvatar.onClick:AddListener(function() self:OnBtnAvatarClick() end)
        MonoBehaviourMgr:Register(self)
    end
end


-- local GAvatar = self.panelObj.transform:Find("GAvatar")
--         if GAvatar then
--             self.BtnAvatar = GAvatar:Find("BtnAvatar"):GetComponent(typeof(Button))
--         end 



function MainPanel:Start()
    print("MainPanel Start")
end

function MainPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end

function MainPanel:HideMe()
    self.panelObj:SetActive(false)
end

function MainPanel:OnBtnAvatarClick()
    print("OnBtnAvatarClick")
end

function MainPanel:OnBtnSettingClick()
    print("OnBtnSettingClick")
end

function MainPanel:OnBtnStoreClick()
    print("OnBtnStoreClick")
end

function MainPanel:OnBtnModeMatch1V1Click()
    MainPanel:HideMe()
    PreMatch1V1Panel:ShowMe()
end

function MainPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    MainPanel.panelObj = nil
    MainPanel.BtnAvatar = nil
    MainPanel.BtnDiamondAdd = nil
    MainPanel.TextDiamond = nil
    MainPanel.BtnGlodAdd = nil
    MainPanel.TextGlod = nil
    MainPanel.BtnSetting = nil
    MainPanel.BtnStore = nil
    MainPanel.BtnModeMatch1V1 = nil
    MainPanel.BtnModeRoom = nil
end