PlayEndPanel = {}

function PlayEndPanel:Init(winPlayerId,playerCardList)
    if  self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "PlayEndPanel")
        self.panelObj.transform:SetParent(Canvas,false)
        
        self.ImgLabel = self.panelObj.transform:Find("ImgLabel"):GetComponent(typeof(Image))
        self.TextLabel = self.ImgLabel:Find("TextLabel"):GetComponent(typeof(TextMeshPro))
        self.GScoreList = self.panelObj.transform:Find("GScoreList")
        
        self.PlayerScoreInfoPrefab = ABMgr:LoadRes("modes", "ImgPlayerScoreInfo")
        
        self.BtnContinueMatch = self.panelObj.transform:Find("GBtnList/BtnContinueMatch"):GetComponent(typeof(Button))
        self.BtnHome = self.panelObj.transform:Find("GBtnList/BtnHome"):GetComponent(typeof(Button))

        --- 为继续游戏按钮添加点击事件监听器,点击时调用 OnBtnContinueMatchClick 方法
        -- @private
        self.BtnContinueMatch.onClick:AddListener(function() self:OnBtnContinueMatchClick() end)
        self.BtnHome.onClick:AddListener(function() self:OnBtnHomeClick() end)
        MonoBehaviourMgr:Register(self)

        self:InitData(GameMatch1V1Panel.m_Players,playerCardList)
        self:InitComponent(GameMatch1V1Panel.m_Players)
    end
end

function PlayEndPanel:InitData(playerIds,playerCardList)

end

function PlayEndPanel:InitComponent(playerCardList)
    for i, playerId in ipairs(playerCardList) do
        local playerScoreInfo = GameObject.Instantiate(self.PlayerScoreInfoPrefab,self.GScoreList)
        playerScoreInfo.transform:SetParent(self.GScoreList,false)

        -- 设置列表信息
        local TextPlayerRank = playerScoreInfo.transform:Find("TextPlayerRank"):GetComponent(typeof(TextMeshPro))
        local TextPlayerName = playerScoreInfo.transform:Find("TextPlayerName"):GetComponent(typeof(TextMeshPro))
        local TextPlayerScore = playerScoreInfo.transform:Find("TextPlayerName"):GetComponent(typeof(TextMeshPro))

        TextPlayerRank.text = tostring(i)
        TextPlayerName.text = playerId
    end
end

function PlayEndPanel:OnBtnContinueMatchClick()
    self:HideMe()
    PreMatch1V1Panel:ShowMe()
end

function PlayEndPanel:OnBtnHomeClick()
    self:HideMe()
    MainPanel:ShowMe()
end

function PlayEndPanel:ShowMe()
    self:Init()
    self.panelObj:SetActive(true)
end

function PlayEndPanel:HideMe()
    self.panelObj:SetActive(false)
end