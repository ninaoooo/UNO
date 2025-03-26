LoginPanel = {}
LoginPanel.panelObj = nil
LoginPanel.BtnClose = nil
LoginPanel.BtnConfirm = nil
LoginPanel.playerName = nil
LoginPanel.passWord = nil
LoginPanel.BtnRegister = nil



function LoginPanel:Init()
    if  self.panelObj == nil then
        -- 1.实例化面板对象，设置父对象
        -- LoadRes(abName,resName)
        self.panelObj = ABMgr:LoadRes("UI","LoginPanel")
        self.panelObj.transform:SetParent(Canvas,false)

        -- 2.找到对应控件 再找到挂在身上想要的脚本
        self.BtnConfirm = self.panelObj.transform:Find("ImgBG/BtnConfirm"):GetComponent(typeof(Button))
        self.BtnRegister = self.panelObj.transform:Find("ImgBG/BtnRegister"):GetComponent(typeof(Button))
        self.BtnClose = self.panelObj.transform:Find("ImgBG/BtnClose"):GetComponent(typeof(Button))


        -- 3.为控件加上事件监听 进行点击等的逻辑处理
        self.BtnConfirm.onClick:AddListener(function() self:OnBtnConfirmClick() end)
        self.BtnRegister.onClick:AddListener(function() self:OnBtnRegisterClick() end)
        self.BtnClose.onClick:AddListener(function() self:OnBtnCloseClick() end)


        self.playerName = self.panelObj.transform:Find("ImgBG/InputPlayerName"):GetComponent(typeof(TextMeshProInputField))
        self.passWord = self.panelObj.transform:Find("ImgBG/InputPassword"):GetComponent(typeof(TextMeshProInputField))

        MonoBehaviourMgr:Register(self)
    end
end

function LoginPanel:Start()
    print("LoginPanel Start")
end

function LoginPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end

function LoginPanel:HideMe()
    self.panelObj:SetActive(false)
end

function LoginPanel:OnBtnConfirmClick()
    local playerName = self.playerName.text
    local passWord = self.passWord.text
    print("playerName",playerName)
    print("passWord",passWord)
    PlayerPrefs.SetString("playerName", playerName)
    PlayerPrefs.SetString("passWord", passWord)
    PlayerPrefs.Save()

    LoginPanel:DestroyPanel()
    StartPanel:ShowMe()
end

function LoginPanel:OnBtnCloseClick()
    LoginPanel:DestroyPanel()
    StartPanel:ShowMe()
end

function LoginPanel:OnBtnRegisterClick()
    RegisterPanel:ShowMe()
end

function LoginPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    LoginPanel.panelObj = nil
    LoginPanel.BtnClose = nil
    LoginPanel.BtnConfirm = nil
    LoginPanel.playerName = nil
    LoginPanel.passWord = nil
    LoginPanel.BtnRegister = nil
end