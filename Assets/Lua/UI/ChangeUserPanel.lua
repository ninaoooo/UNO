ChangeUserPanel = {}

function ChangeUserPanel:Init()
    if self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "ChangeUserPanel")
        self.panelObj.transform:SetParent(Canvas, false)
        
        self.GLoginInfoBox = self.panelObj.transform:Find("GLoginInfoBox"):GetComponent(typeof(Transform))
        self.GOtherUserLoginBox = self.panelObj.transform:Find("GUserLoginBox")
        self.BtnOtherUserLogin = self.panelObj.transform:Find("GLoginInfoBox/BtnOtherUserLogin"):GetComponent(typeof(Button))
        self.BtnOtherUserLogin.onClick:AddListener(function() self:OnBtnOtherUserLoginClick() end)

        -- GLoginInfoBox
        self.BtnReturnFromLoginInfo = self.panelObj.transform:Find("GLoginInfoBox/BtnReturn"):GetComponent(typeof(Button))
        self.TextUserName = self.panelObj.transform:Find("GLoginInfoBox/ImgLoginInfo/TextUserName"):GetComponent(typeof(TextMeshPro))
        self.BtnLogin =self.panelObj.transform:Find("GLoginInfoBox/BtnLogin"):GetComponent(typeof(Button))
        self.BtnLogin.onClick:AddListener(function() self:OnBtnLoginClick() end)            
        self.BtnReturnFromLoginInfo.onClick:AddListener(function() self:OnBtnReturnFromLoginInfoClick() end)

        -- GOtherUserLoginBox
        self.BtnReturnFromOtherUserLogin = self.panelObj.transform:Find("GUserLoginBox/BtnReturn"):GetComponent(typeof(Button))
        self.InputUserName = self.panelObj.transform:Find("GUserLoginBox/ImgLoginUserName/InputUserName"):GetComponent(typeof(TextMeshProInputField))
        self.InputPassword = self.panelObj.transform:Find("GUserLoginBox/ImgLoginUserPassword/InputPassword"):GetComponent(typeof(TextMeshProInputField))
        self.BtnLoginFromOtherUserLogin = self.panelObj.transform:Find("GUserLoginBox/BtnLogin"):GetComponent(typeof(Button))
        self.BtnRegister = self.panelObj.transform:Find("GUserLoginBox/BtnRegister"):GetComponent(typeof(Button))

        self.BtnReturnFromOtherUserLogin.onClick:AddListener(function() self:OnBtnReturnFromOtherUserLoginClick() end)
        self.BtnLoginFromOtherUserLogin.onClick:AddListener(function() self:OnBtnLoginFromOtherUserLoginClick() end)
        self.BtnRegister.onClick:AddListener(function() self:OnBtnRegisterClick() end)
        
        self:InitLoginInfoBox()
        MonoBehaviourMgr:Register(self)
    end
end

function ChangeUserPanel:InitLoginInfoBox()
    self.TextUserName.text = PlayerPrefs.GetString("playerName", "")
end


function ChangeUserPanel:OnBtnOtherUserLoginClick()
    self:LoginInfoHideMe()
    self:OtherUserLoginShowMe()
end
-- 这个登录是保持原来的账号进行登录的
function ChangeUserPanel:OnBtnLoginClick()
    StartPanel:ShowMe()
end

-- 这是登录新账号的 先保存账号密码 
function ChangeUserPanel:OnBtnLoginFromOtherUserLoginClick()
    local playerName = self.InputUserName.text
    local passWord = self.InputPassword.text

    PlayerPrefs.SetString("playerName", playerName)
    PlayerPrefs.SetString("passWord", passWord)
    PlayerPrefs.Save()

    StartPanel:ShowMe()
end

function ChangeUserPanel:OnBtnReturnFromLoginInfoClick()
    self:LoginInfoHideMe()
    StartPanel:ShowMe()
end

function ChangeUserPanel:OnBtnReturnFromOtherUserLoginClick()
    self:OtherUserLoginHideMe()
    self:LoginInfoShowMe()
end

function ChangeUserPanel:OnBtnRegisterClick()
    RegisterPanel:ShowMe()
end



function ChangeUserPanel:LoginInfoShowMe()
    self.GLoginInfoBox.gameObject:SetActive(true)
end

function ChangeUserPanel:LoginInfoHideMe()
    self.GLoginInfoBox.gameObject:SetActive(false)
end

function ChangeUserPanel:OtherUserLoginShowMe()
    self.GOtherUserLoginBox.gameObject:SetActive(true)
end

function ChangeUserPanel:OtherUserLoginHideMe()
    self.GOtherUserLoginBox.gameObject:SetActive(false)
end

function ChangeUserPanel:Destroy()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end

function ChangeUserPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end