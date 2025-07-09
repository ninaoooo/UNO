local PlayerInfo = require("Tools/PlayerInfo")
PreMatchBasePanel = {}
-- PreMatchBasePanel.__index = PreMatchBasePanel

-- function PreMatchBasePanel:New()
--     local self = setmetatable({}, PreMatchBasePanel)
--     return self
-- end

function PreMatchBasePanel:InitUI()
    
    if self.panelObj == nil then
        -- 检查 panelName 是否已设置
        -- if not self.panelName then
        --     error("panelName must be set in subclass")
        -- end
        self.panelObj = ABMgr:LoadRes("UI", "PreMatchPanel")
        self.panelObj.transform:SetParent(Canvas, false)
        
        self.BtnReturn = self.panelObj.transform:Find("GReturn/BtnReturn"):GetComponent(typeof(Button))
        self.GPlayerContainer = self.panelObj.transform:Find("GPlayerContainer"):GetComponent(typeof(Transform))
        self.BtnStartMatch = self.panelObj.transform:Find("BtnStart"):GetComponent(typeof(Button))
        self.TextBtnStartMatch = self.panelObj.transform:Find("BtnStart/Text (TMP)"):GetComponent(typeof(TextMeshPro))
        self.TextBtnStartMatch.text = "开始匹配"
        self.BtnStartMatch.onClick:AddListener(function() self:OnBtnStartMatchClick() end)
        self.TextMatchNeedGold = self.panelObj.transform:Find("GUseGoldTip/TextUseGoldTip"):GetComponent(typeof(TextMeshPro))
        self.TextMatchNeedGold.text = "匹配消耗\n" .. self.matchGold .. "金币"
        self.BtnReturn.onClick:AddListener(function() self:OnBtnReturnClick() end)
    end   
    MonoBehaviourMgr:Register(self)
end

function PreMatchBasePanel:InitData(playerNum,playMode,matchGold)
    self.playerNum = playerNum
    self.playMode = playMode    
    self.matchGold = matchGold
end


function PreMatchBasePanel:InitPlayerComponents()
    local playerPrefab = self.panelObj.transform:Find("GPlayerContainer/GPlayer").gameObject
    for playerIndex = 1, self.playerNum do
        local GPlayer = GameObject.Instantiate(playerPrefab,self.GPlayerContainer)
        GPlayer.transform:SetParent(self.GPlayerContainer, false)
        GPlayer:SetActive(true)
        local TextSelfPlayerName = GPlayer.transform:Find("Text"):GetComponent(typeof(TextMeshPro))
        local ImgAvatar = GPlayer.transform:Find("BtnAvatar"):GetComponent(typeof(Image))
        if playerIndex == 1 then
            TextSelfPlayerName.text = PlayerInfo:GetPlayerName()
            ImgAvatar.sprite = AvatarSpriteAltas:GetSprite(PlayerInfo:GetPlayerAvatar())
        else
            TextSelfPlayerName.text = "等待匹配"
        end
    end
end

function PreMatchBasePanel:Start()
    
end

function PreMatchBasePanel:ShowMe(playerNum,playMode,matchGold)
    PreMatchBasePanel:InitData(playerNum,playMode,matchGold)
    PreMatchBasePanel:InitUI()
    PreMatchBasePanel:InitPlayerComponents()
    self.TextBtnStartMatch.text = "开始匹配"
end

function PreMatchBasePanel:HideMe()
    self.panelObj:SetActive(false)
end
function PreMatchBasePanel:OnBtnReturnClick()
    -- 返回的时候要取消匹配状态
    self:DestroyPanel()
    MainPanel:ShowMe()
end

function PreMatchBasePanel:OnBtnStartMatchClick()
    if self.TextBtnStartMatch.text == "开始匹配" then
        self.TextBtnStartMatch.text = "取消匹配"
        if self.playMode == UnoCommonConfig.matchType1V1 then
            C2S.RequestDoMatch(UnoCommonConfig.matchType1V1)
        elseif self.playMode == UnoCommonConfig.matchType1V3 then
            C2S.RequestDoMatch(UnoCommonConfig.matchType1V3)
        end
    elseif  self.TextBtnStartMatch.text == "取消匹配" then
        self.TextBtnStartMatch.text = "开始匹配"
    end
end


function PreMatchBasePanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end

-- return  PreMatchBasePanel