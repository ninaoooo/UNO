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

        MessageSystem.RegisterListener("S2C.RegisterUserResult",function (result)
            RegisterPanel:HandleRegisterResult(result) 
        end) 
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
        C2S.RegisterUser(playerName, passWord)
        print("已发送注册请求")
    else 
        TextAlertShowAndClose(self.TextAlertAccept,1,"请先阅读并同意隐私政策")
    end
end

function RegisterPanel:HandleRegisterResult(result)
    if result then
        TextAlertShowAndClose(self.TextAlertRegisterResult, 1, "注册成功,请登录")
        TimerUtility:StartTimer("alertTimer", 1, function()
            self:DestroyPanel()
            LoginPanel:ShowMe()
        end)
    else 
        TextAlertShowAndClose(self.TextAlertRegisterResult, 1, "注册失败,请重新注册")
    end
end
function TextAlertShowAndClose(TextAlert, delay, text)
    TextAlert.gameObject:SetActive(true)
    TextAlert.text = text
    TimerUtility:StartTimer("alertTimer", delay, function()
        TextAlert.gameObject:SetActive(false)
    end)
end

function RegisterPanel:OnBtnReturnClick()
    RegisterPanel:DestroyPanel()
    StartPanel:ShowMe()
end

function RegisterPanel:OnBtnPolicyClick()
    print("这里是隐私政策")
end

function RegisterPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end