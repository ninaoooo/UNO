StartPanel = {}

StartPanel.panelObj = nil
StartPanel.BtnStart = nil
StartPanel.BtnExitLogin = nil
StartPanel.BtnChangeUser = nil

function StartPanel:Init()
    -- 面板没有实例化过才去实例化面板
    if self.panelObj == nil then
        -- 1.实例化面板对象，设置父对象
        -- LoadRes(abName,resName)
        self.panelObj = ABMgr:LoadRes("UI", "StartPanel")
        self.panelObj.transform:SetParent(Canvas, false)
        -- 2.找到对应控件 再找到挂在身上想要的脚本
        self.BtnStart = self.panelObj.transform:Find("BtnStart"):GetComponent(typeof(Button))
        self.BtnExitLogin = self.panelObj.transform:Find("BtnExitLogin"):GetComponent(typeof(Button))
        self.BtnChangeUser = self.panelObj.transform:Find("BtnChangeUser"):GetComponent(typeof(Button))
        -- 3.为控件加上事件监听 进行点击等的逻辑处理
        self.BtnStart.onClick:AddListener(function() self:OnBtnStartClick() end)
        self.BtnExitLogin.onClick:AddListener(function() self:OnBtnExitLoginClick() end)
        self.BtnChangeUser.onClick:AddListener(function() self:OnBtnChangeUserClick() end)
        MonoBehaviourMgr:Register(self)
    end
end

function StartPanel:Start()
    print("StartPanel Start")
end

function StartPanel:Update()
    
end
function StartPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end

function StartPanel:HideMe()
    self.panelObj:SetActive(false)
end

function StartPanel:OnBtnExitLoginClick()
    print("当前登录账号", PlayerInfo.playerName)
    print(string.format("%s:退出登录",PlayerInfo.playerName))
    PlayerPrefs.SetString("playerId", "")
    PlayerPrefs.SetString("playerName", "")
    PlayerPrefs.SetString("passWord", "")
    PlayerPrefs.Save()
    PlayerInfo:ClearUser()

    if(PlayerPrefs.GetString("playerName", "") == "") then
        print("当前没有登录账号")
    end
end

function StartPanel:OnBtnChangeUserClick()
    print("切换账号")
end

function StartPanel:OnBtnStartClick()
    RpcMgr:Connect("124.220.67.240", 9010)
    -- 自动登录
    -- 检查 PlayerPrefs 中是否有账号和密码
    local playerName = PlayerPrefs.GetString("playerName", "")
    local passWord = PlayerPrefs.GetString("passWord", "")

    if playerName ~= "" and passWord ~= "" then
        -- 如果有账号和密码，直接执行登录操作
        C2S.LoginUser(playerName, passWord)
        print("正在自动登录...登录账号：", playerName)
    else
        -- 如果没有账号和密码，显示登录面板
        StartPanel:HideMe()
        LoginPanel:ShowMe()
    end
end

function StartPanel:OnDestroy()
    print("StartPanel OnDestroy")
end

function StartPanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    StartPanel.panelObj = nil
    StartPanel.BtnStart = nil
    StartPanel.BtnExitLogin = nil
    StartPanel.BtnChangeUser = nil
end
-- 