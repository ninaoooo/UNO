RegisterPanel = {}
RegisterPanel.panelObj = nil
RegisterPanel.BtnClose = nil
RegisterPanel.BtnRegister = nil
RegisterPanel.playerName = nil
RegisterPanel.passWord = nil

function RegisterPanel:Init()
    if self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "RegisterPanel")
        self.panelObj.transform:SetParent(Canvas, false)

        self.BtnClose = self.panelObj.transform:Find("ImgBG/BtnClose"):GetComponent(typeof(Button))
        self.BtnRegister = self.panelObj.transform:Find("ImgBG/BtnRegister"):GetComponent(typeof(Button))

        self.playerName = self.panelObj.transform:Find("ImgBG/InputPlayerName"):GetComponent(typeof(TextMeshProInputField))
        self.passWord = self.panelObj.transform:Find("ImgBG/InputPassword"):GetComponent(typeof(TextMeshProInputField))

        self.BtnClose.onClick:AddListener(function() self:OnBtnCloseClick() end)
        self.BtnRegister.onClick:AddListener(function() self:OnBtnRegisterClick() end)

        MonoBehaviourMgr:Register(self)
    end
end

function RegisterPanel:Start()
    print("RegisterPanel Start")
end

function RegisterPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end

function RegisterPanel:HideMe()
    self.panelObj:SetActive(false)
end

function RegisterPanel:OnBtnRegisterClick()
    local playerName = self.playerName.text
    local passWord = self.passWord.text
    print(playerName)
    print(passWord)
    C2S.RegisterUser(playerName, passWord)
    RegisterPanel:HideMe()
    LoginPanel:ShowMe()
end

function RegisterPanel:OnBtnCloseClick()
    RegisterPanel:HideMe()
    StartPanel:ShowMe()
end