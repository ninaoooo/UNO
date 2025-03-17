local PlayerInfo = require("Tools/PlayerInfo")
PreMatch1V1Panel = {}
PreMatch1V1Panel.panelObj = nil
PreMatch1V1Panel.TextSelfPlayerName = nil
PreMatch1V1Panel.BtnSelfAvatar = nil
PreMatch1V1Panel.TextOpponentPlayerName = nil
PreMatch1V1Panel.BtnOpponentAvatar = nil
PreMatch1V1Panel.BtnStartMatch = nil
PreMatch1V1Panel.TextBtnStartMatch = nil


function PreMatch1V1Panel:Init()
    if self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "PreMatch1V1Panel")
        self.panelObj.transform:SetParent(Canvas, false)

        self.TextSelfPlayerName = self.panelObj.transform:Find("GPlayerContainer/GPlayer/Text"):GetComponent(typeof(TextMeshPro))
        self.BtnSelfAvatar = self.panelObj.transform:Find("GPlayerContainer/GPlayer/ImgBG/BtnAvatar"):GetComponent(typeof(Button))
        
        self.TextOpponentPlayerName = self.panelObj.transform:Find("GPlayerContainer/GPlayerOpponent/Text"):GetComponent(typeof(TextMeshPro))
        self.BtnOpponentAvatar = self.panelObj.transform:Find("GPlayerContainer/GPlayerOpponent/ImgBG/BtnAvatar"):GetComponent(typeof(Button))

        self.BtnStartMatch = self.panelObj.transform:Find("BtnStart"):GetComponent(typeof(Button))
        self.TextBtnStartMatch = self.panelObj.transform:Find("BtnStart/Text (TMP)"):GetComponent(typeof(TextMeshPro))
        self.TextBtnStartMatch.text = "开始匹配"
        self.BtnStartMatch.onClick:AddListener(function() self:OnBtnStartMatchClick() end)


        self.TextSelfPlayerName.text = PlayerInfo:GetPlayerName()
        self.TextOpponentPlayerName.text = "等待匹配"
        MonoBehaviourMgr:Register(self)
    end
end

function PreMatch1V1Panel:Start()
    print("PreMatch1V1Panel Start")
    
end

function PreMatch1V1Panel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end

function PreMatch1V1Panel:HideMe()
    self.panelObj:SetActive(false)
end

function PreMatch1V1Panel:OnBtnStartMatchClick()
    if self.TextBtnStartMatch.text == "开始匹配" then
        self.TextBtnStartMatch.text = "取消匹配"
        C2S.RequestDoMatch(3)
    elseif  self.TextBtnStartMatch.text == "取消匹配" then
        self.TextBtnStartMatch.text = "开始匹配"
    end
end

function PreMatch1V1Panel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    PreMatch1V1Panel.panelObj = nil
    PreMatch1V1Panel.TextSelfPlayerName = nil
    PreMatch1V1Panel.BtnSelfAvatar = nil
    PreMatch1V1Panel.TextOpponentPlayerName = nil
    PreMatch1V1Panel.BtnOpponentAvatar = nil
    PreMatch1V1Panel.BtnStartMatch = nil
    PreMatch1V1Panel.TextBtnStartMatch = nil
end