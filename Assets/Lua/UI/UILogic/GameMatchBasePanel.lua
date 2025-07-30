-- 基类 GameMatchBasePanel
local GameMatchBasePanel = {}
local PlayerInfo = require("Tools/PlayerInfo")
local PoolMgr = require("UI/Pools/PoolMgr")
local cardPool = PoolMgr:getPool("card")
local GameMacthConfig = require("UI/GameMatchConfig")
GameMatchBasePanel.__index = GameMatchBasePanel

function GameMatchBasePanel:New()
    return setmetatable({}, GameMatchBasePanel)
end

function GameMatchBasePanel:Init(playerIds)
    if self.panelObj == nil then
        -- 检查 panelName 是否已设置
        if not self.panelName then
            error("panelName must be set in subclass")
        end

        self.panelObj = ABMgr:LoadRes("UI", self.panelName)
        self.panelObj.transform:SetParent(Canvas, false)

        self.UnoCardSpriteAltas = ABMgr:LoadRes("UI", "UnoCard")
        self.promptPrefab = ABMgr:LoadRes("modes", "GMsgPrompt")

        self:InitData(playerIds)
        self:InitUIComponents()
        self:InitComponent(playerIds)
        self:RegisterListeners()
        self:InitWildCardButtons()
    end
end

function GameMatchBasePanel:InitUIComponents()
    -- 通用的 UI 组件初始化
    self.ReverseArrow = MainCamara.transform:Find("Rotate")
    self.BtnExit = self.panelObj.transform:Find("GExit/Button"):GetComponent(typeof(Button))
    self.ImgBG = self.panelObj.transform:Find("ImgBG"):GetComponent(typeof(Image))
    self.GDiscardPile = self.panelObj.transform:Find("GDiscardPile"):GetComponent(typeof(Transform))
    self.BtnUno = self.panelObj.transform:Find("BtnUno"):GetComponent(typeof(Button))
    self.GDrawPile = self.panelObj.transform:Find("GDrawPile"):GetComponent(typeof(Transform))
    self.BtnDrawPile = self.panelObj.transform:Find("GDrawPile/BtnDrawPile"):GetComponent(typeof(Button))
    
    self.TextGameTimer = self.panelObj.transform:Find("GGameTimer/TextTimer"):GetComponent(typeof(TextMeshPro))
    self.TextPrepareTimer = self.panelObj.transform:Find("TextPrepareTime"):GetComponent(typeof(TextMeshPro))

    self.GConfirmShow = self.panelObj.transform:Find("GConfirmShow"):GetComponent(typeof(Transform))
    self.BtnChupai = self.GConfirmShow:Find("BtnChupai"):GetComponent(typeof(Button))
    self.BtnCancel = self.GConfirmShow:Find("BtnCancel"):GetComponent(typeof(Button))


    self.GWildCardSelectColor = self.panelObj.transform:Find("GWildCardSelectColor"):GetComponent(typeof(Transform))
    self.BtnExit.onClick:AddListener(function() self:OnBtnExitClick() end)
    self.BtnUno.onClick:AddListener(function() self:OnBtnUnoClick() end)
    self.BtnDrawPile.onClick:AddListener(function() self:OnBtnDrawPileClick() end)

    self.BtnCancel.onClick:AddListener(function() self:OnBtnCancelClick() end)
    self.BtnChupai.onClick:AddListener(function() self:OnBtnChupaiClick() end)
    self.GSuspicionDrawFour = self.panelObj.transform:Find("GSuspicionDrawFour"):GetComponent(typeof(Transform))
    self.Text = self.panelObj.transform:Find("Text"):GetComponent(typeof(TextMeshPro))
    MonoBehaviourMgr:Register(self)
end

function GameMatchBasePanel:InitData(playerIds)
    self.logic = UnoGameLogic:Init(playerIds)
    self.direction = -1 
end

function GameMatchBasePanel:RegisterListeners()
    MessageSystem.RegisterListener("S2C.SyncUnoCardDraw", function(playerId, cardType, cardColor, confirmshow) 
        print("SyncUnoCardDraw playerId: ", playerId, "cardType: ", cardType, "cardColor: ", cardColor, "confirmshow: ", confirmshow)
        self:OnUnoCardDraw(playerId, cardType, cardColor, confirmshow)
    end)
    MessageSystem.RegisterListener("S2C.SyncUnoCardPlay", function(playerId, cardType, cardColor) 
        print("SyncUnoCardPlay playerId: ", playerId, "cardType: ", cardType, "cardColor: ", cardColor)
        if PlayerInfo:IsSelf(playerId) then
            self:OnSelfUnoCardPlay(cardType, cardColor)
        elseif playerId ~= 0 then
            self:OnOtherUnoCardPlay(playerId, cardType, cardColor)
        else 
            self:InitFirstCardToDiscardPile(cardType, cardColor)
        end
        if playerId ~= 0 and cardType == EnumUnoCardType.eReverse then
            self.direction = self.direction*-1
            self.ReverseArrow.transform.localScale = Vector3(self.direction*1,1,1)
        end
        self.logic:AddCardToDiscard(cardType, cardColor)
        self:PlaySound(cardType, cardColor)
        self:ShowText(cardType, cardColor)
    end)
    MessageSystem.RegisterListener("S2C.ShowUnoWaitConfirmCard",function(playerId, cardIdx, cardType, cardColor)
    end)
    MessageSystem.RegisterListener("S2C.SyncUnoShoutUno",function(playerId, hasUno)
        self:SetShoutUnoStatus(playerId,hasUno)
    end)
    MessageSystem.RegisterListener("S2C.SyncUnoPlayEnd",function(winPlayerId, playerCardInfo_U)
        local playerCardList,playerId2Score = table.unpack(msgpack.unpack(playerCardInfo_U))
        self:PlayEndShowCard(playerCardList)
        PlayEndPanel:ShowMe(winPlayerId,playerId2Score)
    end)
    MessageSystem.RegisterListener("S2C.SyncUnoCards",function(playerId, cardNum, cards_U)
        print("SyncUnoCards playerId: ", playerId, "cardNum: ", cardNum)
    end)
    MessageSystem.RegisterListener("S2C.SyncUnoPlayRoundInfo",function(totalRestTime, curOpRestTime, curPlayerId, stage)
        print("SyncUnoPlayRoundInfo totalRestTime: ", totalRestTime, "curOpRestTime: ", curOpRestTime, "curPlayerId: ", curPlayerId, "stage: ", stage)
        self.logic.m_currentPlayerId = curPlayerId
        self:TimerMgr(curPlayerId, totalRestTime, curOpRestTime)
        self:PlayerStage(curPlayerId, stage)
    end)
end
function GameMatchBasePanel:GetPositionMap()
    error("GetPositionMap must be implemented by subclass")
end

function GameMatchBasePanel:InitComponent(playerIds)
    self.Player2Info = {}
    local playerIndex = 0
    for i = 1, #playerIds do
        if self.logic:IsSelf(playerIds[i]) then
            playerIndex = i
            break
        end
    end
    local positionMap = self:GetPositionMap()
    local pos = 1
    for i = playerIndex, playerIndex + #playerIds - 1 do
        local idx = i % #playerIds
        if idx == 0 then
            idx = #playerIds
        end
        local curPlayerId = playerIds[idx]
        local avatarIdx = curPlayerId%13
        self.Player2Info[curPlayerId] = {}
        self.Player2Info[curPlayerId].BtnAvatar = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/BtnAvatar"):GetComponent(typeof(Button))
        self.Player2Info[curPlayerId].ImgAvatar = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/BtnAvatar"):GetComponent(typeof(Image))
        self.Player2Info[curPlayerId].ImgAvatar.sprite = AvatarSpriteAltas:GetSprite("avatar ("..avatarIdx..")")
        self.Player2Info[curPlayerId].ImgGlow = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/Image"):GetComponent(typeof(Image))
        self.Player2Info[curPlayerId].GTurnTimer = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/GTurnTimer")
        self.Player2Info[curPlayerId].TextTurnTimer = self.Player2Info[curPlayerId].GTurnTimer.transform:Find("Image/Text"):GetComponent(typeof(TextMeshPro))

        self.Player2Info[curPlayerId].playerName = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/Text"):GetComponent(typeof(TextMeshPro))
        self.Player2Info[curPlayerId].ImgWin = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/ImgWin"):GetComponent(typeof(Image))
        self.Player2Info[curPlayerId].ImgShoutUno = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/ImgShoutUno"):GetComponent(typeof(Image))
        self.Player2Info[curPlayerId].playerName.text = curPlayerId
        self.Player2Info[curPlayerId].Location = positionMap[pos]
        self.Player2Info[curPlayerId].HandContainer = self.panelObj.transform:Find("G"..positionMap[pos].."HandContainer"):GetComponent(typeof(Transform))

        
        self.Player2Info[curPlayerId].BtnAvatar.onClick:AddListener(function() self:OnBtnAvatarClick(curPlayerId) end)
        pos = pos + 1
        print("已初始化完成ID"..curPlayerId.."的组件")
    end
    self.actionTimer = CountdownTimer.New("actionTimer")
    self.totalTimer = CountdownTimer.New("totalTimer")
end




-- 万能牌选择按钮初始化
function GameMatchBasePanel:InitWildCardButtons()
    -- 绑定所有颜色按钮
    for _, buttonInfo in ipairs(GameMacthConfig.WildCardColorButtons) do
        local buttonPath = "GWildCardSelectColor/GOption/" .. buttonInfo.name
        local button = self.panelObj.transform:Find(buttonPath):GetComponent(typeof(Button))
        local color = buttonInfo.color
        self:BindButtonClick(button, function()
            self:OnWildCradColorSelected(color)
        end)
    end
end

-- 万能牌颜色选择回调
function GameMatchBasePanel:OnWildCradColorSelected(color)
    -- 检查万能牌的来源（手牌/牌堆）
    if self.logic.m_tempCardList[1].cardFromHand then
        self.logic.NotifyServerToPlayCard(self.logic.m_tempCardList[1].cardType,color)
        self.logic.m_tempCardList = {}
    else 
        self.logic.NotifyServerToPlayDrawnCard(color)
    end
    self.GWildCardSelectColor.gameObject:SetActive(false)
end

function GameMatchBasePanel:SetCardImg(cardImage,cardType, cardColor)
    local cardString = string.format("card%d_%s", cardType, cardColor)
    cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)
end

function GameMatchBasePanel:InitFirstCardToDiscardPile(cardType, cardColor)
    local discardCard = cardPool:get()

    discardCard.transform:SetParent(self.GDrawPile, false)
    local cardRect = discardCard:GetComponent(typeof(RectTransform))
    cardRect.localPosition  = Vector3(0, 0, 0)
    print("初始化一张牌到弃牌堆")
    DynamicEffects.FirstCardToDiscardPile( discardCard.transform, self.GDiscardPile, true,cardType, cardColor)
end

-- 系统发牌至玩家
function GameMatchBasePanel:OnUnoCardDraw(playerId, cardType, cardColor, confirmshow)
    local HandContainer = self.Player2Info[playerId].HandContainer
    local card = cardPool:get()
    card.transform:SetParent(self.GDrawPile, false)
    card.transform:GetComponent(typeof(RectTransform)).localPosition  = Vector3(0, 0, 0)
    --1.如果是 confirmshow = true 的牌 要在屏幕上展示，并让玩家确认是否需要出掉这张牌
    if self.logic:IsSelf(playerId) and confirmshow then
        table.insert(self.logic.m_tempCardList,{cardTransform = card.transform, cardType = cardType, cardColor = cardColor, cardFromHand = false})
        self.GConfirmShow.gameObject:SetActive(true)
        DynamicEffects.CardFromDrawPileToShow(self.GConfirmShow, card.transform, cardType, cardColor)
    else
        self.logic.m_initCardCnt[playerId] = self.logic.m_initCardCnt[playerId] + 1
        if self.logic:IsSelf(playerId) then
            -- 更新自己的手牌数据(AddCardToSelf已排序)
            local cardId = self.logic:GetCardId()
            self.logic:AddCardToSelf(cardId, cardType, cardColor, card.transform)
            card:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnCardClick(cardId) end)
            if(self.logic.initCardsStage) then
                if(self.logic.m_initCardCnt[playerId] == 7) then 
                    self.logic.initCardsStage = false 
                end
                DynamicEffects.InitCardFromDrawPileToHand(self.logic.m_initCardCnt[playerId],card.transform,HandContainer,cardType,cardColor,self.logic.m_PlayerCardList[playerId])
            end
            local newCardIndex,newCardData = self.logic:FindCardById(cardId)
            DynamicEffects.CardFromDrawPileToSelfHand(newCardIndex,newCardData,HandContainer)
        else
            DynamicEffects.CardFromDrawPileToOtherHand(card.transform,HandContainer,self.Player2Info[playerId].Location)
        end
    end
end

-- 玩家自己出牌
function GameMatchBasePanel:OnSelfUnoCardPlay(cardType, cardColor)
    -- 1.出牌
    local cardTransform = self.logic:HandleSelfPlayCard(cardType, cardColor)
    -- 2.丢牌到弃牌堆
    print("self play card",cardTransform)
    local HandContainer = self.Player2Info[self.logic.m_MyPlayerId].HandContainer
    if self.logic:IsWildCard(cardType) then
        DynamicEffects.CardFromHandToDiscardPile(cardTransform,HandContainer,self.GDiscardPile,true, cardType, cardColor)
    else
        DynamicEffects.CardFromHandToDiscardPile(cardTransform,HandContainer,self.GDiscardPile,true)
    end
end

-- 对手出牌
function GameMatchBasePanel:OnOtherUnoCardPlay(playerId,cardType,cardColor)
    -- 对手出牌的时候我们只需要看到他少了一张牌就行 所以这里我们默认移除他最左边一张牌
    local HandContainer = self.Player2Info[playerId].HandContainer
    local cardTransform =  HandContainer.transform:GetChild(0)
    print(playerId.." play card",cardTransform)
    DynamicEffects.CardFromHandToDiscardPile(cardTransform,HandContainer,self.GDiscardPile,true, cardType, cardColor)
end

function GameMatchBasePanel:TimerMgr(playerId,totalRestTime,curOpRestTime)
    -- 先把所有的玩家轮次计时器全部隐藏
    for _, id in ipairs(self.logic.m_Players) do
        self.Player2Info[id].GTurnTimer.gameObject:SetActive(false)
        DynamicEffects:StopBreath( self.Player2Info[id].ImgGlow)
    end
    -- 再把当前玩家的轮次计时器显示出来
    self.Player2Info[playerId].GTurnTimer.gameObject:SetActive(true)
    DynamicEffects:StartBreath(self.Player2Info[playerId].ImgGlow)
    self.totalTimer:StartTimer(totalRestTime,"mm:ss")
    self.actionTimer:StartTimer(curOpRestTime,"ss")

    self.totalTimer.onUpdate = function (timestr)
        self.TextGameTimer.text = timestr
    end
    self.actionTimer.onUpdate = function (timestr)
        self.Player2Info[playerId].TextTurnTimer.text = timestr
    end

    -- -- 设置计时器回调
    self.actionTimer.onFinish = function()
        -- 关键判断：只有当确认弹窗处于激活状态时才执行保留
        if self.GConfirmShow and self.GConfirmShow.gameObject.activeSelf then
            print("[倒计时结束] 自动保留卡牌")
            -- 调用与"取消"按钮相同的逻辑
            self:OnBtnCancelClick()
        end
        self.GConfirmShow.gameObject:SetActive(false) -- 关闭确认弹窗
        self.GWildCardSelectColor.gameObject:SetActive(false) -- 关闭颜色选择面板
    end
end

-- 出从牌堆里来的牌
function GameMatchBasePanel:OnBtnChupaiClick()
        -- 1.如果是万能牌 弹出颜色选择框 等待玩家选择
    local cardType = self.logic.m_tempCardList[1].cardType
    local cardColor = self.logic.m_tempCardList[1].cardColor
    local cardTransform = self.logic.m_tempCardList[1].cardTransform
    if self.logic:IsWildCard(cardType) then
        print("牌堆发来了一张万能牌 请选择颜色")
        self.GWildCardSelectColor.gameObject:SetActive(true)
    else
        -- 2.非万能牌，直接发送确认出牌消息
        self.logic.NotifyServerToPlayDrawnCard(cardColor)
        DynamicEffects.CardFromShowToDiscardPile(cardTransform,self.GDiscardPile,cardType,cardColor)
        self.logic.m_tempCardList = {}
    end  
    self.GConfirmShow.gameObject:SetActive(false) -- 关闭确认弹窗
    self.GWildCardSelectColor.gameObject:SetActive(false) -- 关闭颜色选择面板
end


-- 玩家自行点击牌堆 决定保留
function GameMatchBasePanel:OnBtnCancelClick()
    local tempCardData = self.logic.m_tempCardList[1]
    self.logic.m_tempCardList = {}
    local cardId = self.logic:GetCardId()
    self.logic.NotifyServerToKeepDrawnCard(tempCardData.cardColor)
    self.logic:AddCardToSelf(cardId, tempCardData.cardType, tempCardData.cardColor, tempCardData.cardTransform)
    local newCardIndex, newCardData = self.logic:FindCardById(cardId)

    self.GConfirmShow.gameObject:SetActive(false)
    DynamicEffects.CardFromShowToSelfHand(newCardIndex,newCardData,self.Player2Info[self.logic.m_MyPlayerId].HandContainer)
end


function GameMatchBasePanel:ClearOtherCardSelected(playerCardList,cardId)
    -- 1.先找场上有没有别的牌被选中
    for _, cardData in ipairs(playerCardList) do
    -- 2.如果有别的牌被选中 恢复别的牌的选中标志位和卡牌位置
        if cardData.cardIsSelected and cardData.cardId ~= cardId then
            cardData.cardIsSelected = false
            DynamicEffects.ResetCard(cardData.cardTransform)
        end
    end
end


-- 玩家按照规则尝试出牌
function GameMatchBasePanel:TryPlayCard(cardData)
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    local canPlay, message = self.logic:CheckPlayCardRules(cardData.cardType, cardData.cardColor)
    -- 根据返回值处理逻辑
    if not canPlay then MsgPrompt:ShowPrompt(message, self.panelObj.transform) return end
    -- 如果需要选择颜色，显示颜色选择面板
    if message == self.logic.messages.NEED_COLOR then    
        self.GWildCardSelectColor.gameObject:SetActive(true)
        return
    end
    -- 普通牌直接出牌
    self.logic.NotifyServerToPlayCard(cardData.cardType, cardData.cardColor)
end

-- 手牌点击事件
function GameMatchBasePanel:OnCardClick(cardId)
    -- 1.如果有别的手牌被点击过 复位手牌位置
    self:ClearOtherCardSelected(self.logic.m_PlayerCardList[self.logic.m_MyPlayerId],cardId)
    -- 2.找到现在被点击的牌
    local index, cardData = self.logic:FindCardById(cardId)
    if not cardData then return end
    -- 3.牌已被选中，尝试出牌
    if cardData.cardIsSelected then
        self:TryPlayCard(cardData)
    else 
    -- 如果牌未曾选中 设置被选择状态和位置
        self.logic.m_PlayerCardList[self.logic.m_MyPlayerId][index].cardIsSelected = true
        DynamicEffects.SelectCard(cardData.cardTransform)
    end
    
end

-- 玩家主动抽牌
function GameMatchBasePanel:OnBtnDrawPileClick()
    self.logic.NotifyServerToDrawCard()
end




function GameMatchBasePanel:PlayerStage(playerId,stage)
    if self.logic:IsSelf(playerId) then
        -- 质疑+4牌阶段
        if stage == EnumRoundStage.eWaitConfirmDrawFour then
            self.GSuspicionDrawFour.gameObject:SetActive(true)
            local BtnSuspicion = self.GSuspicionDrawFour:Find("BtnSuspicion"):GetComponent(typeof(Button))
            local BtnCancel = self.GSuspicionDrawFour:Find("BtnCancel"):GetComponent(typeof(Button))
            self:BindButtonClick(BtnSuspicion, function()
                self.logic.NotifyServerToSuspicionDrawFour(false)
                self.GSuspicionDrawFour.gameObject:SetActive(false)
            end)
            self:BindButtonClick(BtnCancel, function()
                self.logic.NotifyServerToSuspicionDrawFour(true)
                self.GSuspicionDrawFour.gameObject:SetActive(false)
            end) 
        else
            self.GSuspicionDrawFour.gameObject:SetActive(false)
        end
    end
end

function GameMatchBasePanel:SetShoutUnoStatus(playerId,hasUno)
    -- 1. 播放音效（只要 hasUno=true 就播放）
    if hasUno then
        self:PlaySoundUno()
        self.Player2Info[playerId].ImgShoutUno.gameObject:SetActive(true)
    else
        self.Player2Info[playerId].ImgShoutUno.gameObject:SetActive(false)
    end
end

function GameMatchBasePanel:OnBtnUnoClick()
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    if not self.logic:IsTimeToShoutUno() then
        MsgPrompt:ShowPrompt("现在不用喊uno", self.panelObj.transform)
    end
end

function GameMatchBasePanel:OnBtnCatchUnoClicked(playerId)
    self.logic:NotifyServerToCatchUno(playerId)
end

function GameMatchBasePanel:ClearHandContainer(HandContainer)
    for i = HandContainer.transform.childCount - 1, 0, -1 do
        local child = HandContainer.transform:GetChild(i).gameObject
        if child.activeSelf then  -- 只销毁 Activate 为 true 的卡牌
            GameObject.Destroy(child)
        end
    end
end



function GameMatchBasePanel:PlayEndShowCard(playerCardList)
    for playerId,cardList in pairs(playerCardList) do
        local HandContainer = self.Player2Info[playerId].HandContainer
        for i = HandContainer.transform.childCount - 1, 0, -1 do
            local card = HandContainer.transform:GetChild(i).gameObject
            cardPool:put(card)
        end

        for _, cardData in ipairs(cardList) do 
            local card = cardPool:get()
            card.transform:SetParent(HandContainer, false)
            local cardImage = card:GetComponent(typeof(Image))
            self:SetCardImg(cardImage, cardData[1], cardData[2])
        end
        DynamicEffects.UpdateHandLayout(HandContainer)
    end
end


-- 播放音效
function GameMatchBasePanel:PlaySound(cardType, cardColor)
    local soundName = nil
    if GameMacthConfig.PlaySoundByType[cardType] then
        soundName = LuaAudioMgr:GetSoundNameById(cardType)
        LuaAudioMgr:PlaySound(LuaAudioMgr.soundABName, soundName)
    elseif self.logic:IsWildCard(cardType) then
        soundName = LuaAudioMgr:GetSoundNameById(cardColor)
        LuaAudioMgr:PlaySound(LuaAudioMgr.soundABName, soundName)
    end
end

function GameMatchBasePanel:PlaySoundUno()
    LuaAudioMgr:PlaySound(LuaAudioMgr.soundABName, "UNO")
end

function GameMatchBasePanel:ShowText(cardType, cardColor)
    if self.logic:IsWildCard(cardType) then
        self.Text.text = GameMacthConfig.ShowTextByColor[cardColor]
        DynamicEffects:ShowText(self.Text.transform)
    elseif GameMacthConfig.ShowTextByType[cardType] ~= nil then
        self.Text.text = GameMacthConfig.ShowTextByType[cardType]
        DynamicEffects:ShowText(self.Text.transform)
    end
    
end

function GameMatchBasePanel:OnBtnAvatarClick(playerId)
    if #self.logic.m_PlayerCardList[playerId]<2 then
        C2S.UnoPlayPlayerCatchNoUno(playerId)
        print("抓住你啦")
    end
end

function GameMatchBasePanel:OnBtnExitClick()
    self:DestroyPanel()
    MainPanel:ShowMe()
end

-- 更新函数
function GameMatchBasePanel:Update(dt)
    self.totalTimer:Update(dt)
    self.actionTimer:Update(dt)
    self.ReverseArrow.transform:Rotate(Vector3.up, self.direction* 90 * Time.deltaTime);
end
-- 绑定按钮点击事件
function GameMatchBasePanel:BindButtonClick(button, onClickCallback)
    if not button then return end
    -- 解绑已有的事件F
    button.onClick:RemoveAllListeners()
    -- 绑定新的事件
    button.onClick:AddListener(onClickCallback)
end


function GameMatchBasePanel:BatchReturnCardsToPool()
    -- 清理玩家手牌
    for _, playerId in ipairs(self.logic.m_Players) do
        local HandContainer = self.Player2Info[playerId].HandContainer
        if HandContainer then
            for i = HandContainer.transform.childCount - 1, 0, -1 do
                local card = HandContainer.transform:GetChild(i).gameObject
                cardPool:put(card)
            end
        end
    end
    -- 清理弃牌堆
    for i = self.GDiscardPile.childCount - 1,0,-1 do
        local  card = self.GDiscardPile:GetChild(i).gameObject
        cardPool:put(card)
    end
end
function GameMatchBasePanel:DestroyPanel()
    self:BatchReturnCardsToPool()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
    GameEntry.currentGamePanel = nil
    MessageSystem.RemoveListener("S2C.SyncUnoCardDraw")
    MessageSystem.RemoveListener("S2C.SyncUnoCardPlay")
    MessageSystem.RemoveListener("S2C.ShowUnoWaitConfirmCard")
    MessageSystem.RemoveListener("S2C.SyncUnoShoutUno")
    MessageSystem.RemoveListener("S2C.SyncUnoPlayEnd")
    MessageSystem.RemoveListener("S2C.SyncUnoCards")
    MessageSystem.RemoveListener("S2C.SyncUnoPlayRoundInfo")
end

return GameMatchBasePanel