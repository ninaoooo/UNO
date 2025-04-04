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

        self.BtnReturn = self.panelObj.transform:Find("GRegisterBox/BtnReturn"):GetComponent(typeof(Button))
        self.playerName = self.panelObj.transform:Find("GRegisterBox/ImgLoginUserName/InputUserName"):GetComponent(typeof(TextMeshProInputField))
        self.passWord = self.panelObj.transform:Find("GRegisterBox/ImgLoginUserPassword/InputPassword"):GetComponent(typeof(TextMeshProInputField))
        self.BtnRegister = self.panelObj.transform:Find("GRegisterBox/BtnRegister"):GetComponent(typeof(Button))

        self.BtnPolicy = self.panelObj.transform:Find("GRegisterBox/GAccept/BtnPolicy"):GetComponent(typeof(Button))
        self.Toggle = self.panelObj.transform:Find("GRegisterBox/GAccept/Toggle"):GetComponent(typeof(Toggle))

        self.TextAlertAccept = self.panelObj.transform:Find("GRegisterBox/TextAlertAccept"):GetComponent(typeof(TextMeshPro))
        self.TextAlertRegisterResult = self.panelObj.transform:Find("GRegisterBox/TextAlertRegisterResult"):GetComponent(typeof(TextMeshPro))
        
        self.BtnReturn.onClick:AddListener(function() self:OnBtnReturnClick() end)
        self.BtnRegister.onClick:AddListener(function() self:OnBtnRegisterClick() end)
        self.BtnPolicy.onClick:AddListener(function() self:OnBtnPolicyClick() end)
        MonoBehaviourMgr:Register(self)
    end
end

function RegisterPanel:Start()
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
    local acceptPolicy = self.Toggle.isOn
    if acceptPolicy then 
        RpcMgr:Connect("124.220.67.240", 9010)
        C2S.RegisterUser(playerName, passWord)
    else 
        TextAlertShowAndClose(self.TextAlertAccept.gameObject,2)
    end
end

function RegisterPanel:HandleRegisterResult(result)
    if result then
        TextAlertShowAndClose(self.TextAlertRegisterResult.gameObject, 2, "注册成功,请登录")
        self:Destroy()
        LoginPanel:ShowMe()
    else 
        TextAlertShowAndClose(self.TextAlertRegisterResult.gameObject, 2, "注册失败,请重新注册")
    end
end
function TextAlertShowAndClose(TextAlert, delay, text)
    TextAlert:SetActive(true)
    TimerUtility:StartTimer("alertTimer", delay, function()
        TextAlert:SetActive(false)
    end)
end

function RegisterPanel:OnBtnReturnClick()
    RegisterPanel:Destroy()
    StartPanel:ShowMe()
end

function RegisterPanel:OnBtnPolicyClick()
    print("这里是隐私政策")
end

function RegisterPanel:Destroy()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end