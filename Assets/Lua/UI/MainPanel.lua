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

local PlayerInfo = require("Tools/PlayerInfo")
AvatarSpriteAltas = ABMgr:LoadRes("UI", "Avatar")
function MainPanel:Init()
    if  self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI","MainPanel")
        self.panelObj.transform:SetParent(Canvas,false)        -- 2.找到对应控件 再找到挂在身上想要的脚本
        
        self.BtnAvatar = self.panelObj.transform:Find("GAvatar/BtnAvatar"):GetComponent(typeof(Button))
        self.ImgAvatar = self.BtnAvatar.transform:GetComponent(typeof(Image))
        self.BtnSetting = self.panelObj.transform:Find("GSettings/Button"):GetComponent(typeof(Button))
        self.BtnStore = self.panelObj.transform:Find("GStore/Button"):GetComponent(typeof(Button))
        self.BtnModeMatch1V1 = self.panelObj.transform:Find("GPlayerModeContainer/GPlayMode1V1/Button"):GetComponent(typeof(Button))
        self.BtnModeMatch1V3 = self.panelObj.transform:Find("GPlayerModeContainer/GPlayMode1V3/Button"):GetComponent(typeof(Button))
        -- 3.为控件加上事件监听 进行点击等的逻辑处理
        self.BtnModeMatch1V1.onClick:AddListener(function() self:OnBtnModeMatch1V1Click() end)
        self.BtnModeMatch1V3.onClick:AddListener(function() self:OnBtnModeMatch1V3Click() end)
        self.BtnAvatar.onClick:AddListener(function() self:OnBtnAvatarClick() end)
        self.BtnSetting.onClick:AddListener(function() self:OnBtnSettingClick() end)
        MonoBehaviourMgr:Register(self)

        
        self.avatarString = PlayerInfo:GetPlayerAvatar()
        self.ImgAvatar.sprite = AvatarSpriteAltas:GetSprite(self.avatarString)
    end
end

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
    self:HideMe()
    SettingPanel:ShowMe()
end

function MainPanel:OnBtnStoreClick()
    print("OnBtnStoreClick")
end

function MainPanel:OnBtnModeMatch1V1Click()
    MainPanel:DestroyPanel()
    PreMatchPanel = PreMatch1V1Panel:New()
    PreMatchPanel:ShowMe()
end

function MainPanel:OnBtnModeMatch1V3Click()
    MainPanel:DestroyPanel()
    PreMatchPanel = PreMatch1V3Panel:New()
    PreMatchPanel:ShowMe()
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