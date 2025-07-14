PlayEndPanel = {}
local GameMatchBasePanel = require("UI/UILogic/GameMatchBasePanel")
function PlayEndPanel:Init(winPlayerId,playerId2Score)
    if  self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "PlayEndPanel")
        self.panelObj.transform:SetParent(Canvas,false)
        
        self.ImgLabel = self.panelObj.transform:Find("ImgLabel"):GetComponent(typeof(Image))
        self.TextLabel = self.panelObj.transform:Find("ImgLabel/TextLabel"):GetComponent(typeof(TextMeshPro))
        self.GScoreList = self.panelObj.transform:Find("GScoreList"):GetComponent(typeof(Transform))

        self.BtnContinueMatch = self.panelObj.transform:Find("GBtnList/BtnContinueMatch"):GetComponent(typeof(Button))
        self.BtnHome = self.panelObj.transform:Find("GBtnList/BtnHome"):GetComponent(typeof(Button))

        self.BtnContinueMatch.onClick:AddListener(function() self:OnBtnContinueMatchClick() end)
        self.BtnHome.onClick:AddListener(function() self:OnBtnHomeClick() end)
        MonoBehaviourMgr:Register(self)
    end
end

function PlayEndPanel:InitData(winPlayerId,playerId2Score)
    self.winPlayerId = winPlayerId
    self.scoreArray = {}
    for playerId, score in pairs(playerId2Score) do
        table.insert(self.scoreArray, {playerId, score})
    end
    table.sort(self.scoreArray, function(a, b) return a[2] < b[2] end)
end

function PlayEndPanel:InitComponent()
    local scoreItemPrefeb = self.GScoreList:Find("List").gameObject
    for rankIndex, scoreData in ipairs(self.scoreArray) do
        
        local playerScoreInfo = GameObject.Instantiate(scoreItemPrefeb,self.GScoreList)
        playerScoreInfo.transform:SetParent(self.GScoreList,false)
        playerScoreInfo:SetActive(true)
        
        -- 设置列表信息
        local TextRank = playerScoreInfo.transform:Find("GInfo/TextRank"):GetComponent(typeof(TextMeshPro))
        local TextName = playerScoreInfo.transform:Find("GInfo/TextName"):GetComponent(typeof(TextMeshPro))
        -- local TextGold = playerScoreInfo.transform:Find("TextGlod"):GetComponent(typeof(TextMeshPro))
        local TextScore = playerScoreInfo.transform:Find("GInfo/TextScore"):GetComponent(typeof(TextMeshPro))
        TextRank.text= tostring(rankIndex)
        TextName.text= tostring(scoreData[1])
        if rankIndex == 1 then
            local winFlag = playerScoreInfo.transform:Find("TextWin")
            winFlag.gameObject:SetActive(true)
            TextScore.text= tostring(scoreData[2])
        else
            TextScore.text= tostring(-scoreData[2])
        end
        
    end
end



function PlayEndPanel:OnBtnContinueMatchClick()
    PlayEndPanel:DestroyPanel()
    GameEntry.currentGamePanel:DestroyPanel()
    PreMatchBasePanel:ShowMe()
end

function PlayEndPanel:OnBtnHomeClick()
    PlayEndPanel:DestroyPanel()
    GameEntry.currentGamePanel:DestroyPanel()
    MainPanel:ShowMe()
end

function PlayEndPanel:ShowMe(winPlayerId,playerId2Score)
    self:InitData(winPlayerId,playerId2Score)
    self:Init()
    self:InitComponent()
    self.panelObj:SetActive(true)
end

function PlayEndPanel:HideMe()
    self.panelObj:SetActive(false)
end

function PlayEndPanel:Update()
    
end

function PlayEndPanel:DestroyPanel()
    self.panelObj:SetActive(false)
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end