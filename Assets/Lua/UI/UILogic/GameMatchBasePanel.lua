-- 基类 GameMatchBasePanel
local GameMatchBasePanel = {}
GameMatchBasePanel.__index = GameMatchBasePanel

function GameMatchBasePanel:New()
    local self = setmetatable({}, GameMatchBasePanel)
    return self
end


GameMatchBasePanel.WildCardColorButtons = {
    { name = "BtnRed", color = EnumUnoCardColor.eRed },
    { name = "BtnBlue", color = EnumUnoCardColor.eBlue },
    { name = "BtnGreen", color = EnumUnoCardColor.eGreen },
    { name = "BtnYellow", color = EnumUnoCardColor.eYellow },
}

GameMatchBasePanel.PlaySoundByType = {
    [EnumUnoCardType.eSkip] = true,     -- 10
    [EnumUnoCardType.eReverse] = true,  -- 11
    [EnumUnoCardType.eDrawTwo] = true,  -- 12
}

GameMatchBasePanel.PlaySoundByColor = {
    [EnumUnoCardColor.eRed] = true,        
    [EnumUnoCardColor.eGreen] = true,
    [EnumUnoCardColor.eBlue] = true,
    [EnumUnoCardColor.eYellow] = true,
}

GameMatchBasePanel.ShowTextByType = {
    [EnumUnoCardType.eSkip] = "Skip",     -- 10
    [EnumUnoCardType.eReverse] = "Reverse",  -- 11
    [EnumUnoCardType.eDrawTwo] = "Draw 2",  -- 12
}
GameMatchBasePanel.ShowTextByColor = {
    [EnumUnoCardColor.eRed] = "Red",        
    [EnumUnoCardColor.eGreen] = "Green",
    [EnumUnoCardColor.eBlue] = "Blue",
    [EnumUnoCardColor.eYellow] = "Yellow",
}

function GameMatchBasePanel:Init(playerIds)
    if self.panelObj == nil then
        -- 检查 panelName 是否已设置
        if not self.panelName then
            error("panelName must be set in subclass")
        end

        self.panelObj = ABMgr:LoadRes("UI", self.panelName)
        self.panelObj.transform:SetParent(Canvas, false)

        self.UnoCardSpriteAltas = ABMgr:LoadRes("UI", "UnoCard")
        self.UISpriteAltas = ABMgr:LoadRes("UI", "UI")
        self.promptPrefab = ABMgr:LoadRes("modes", "GMsgPrompt")

        self:InitUIComponents()
        self:InitData(playerIds)
        self:InitComponent(playerIds)
        self:InitWildCardButtons()
    end
end

function GameMatchBasePanel:InitUIComponents()
    -- 通用的 UI 组件初始化
    self.BtnExit = self.panelObj.transform:Find("GExit/Button"):GetComponent(typeof(Button))
    self.ImgBG = self.panelObj.transform:Find("ImgBG"):GetComponent(typeof(Image))
    self.GDiscardPile = self.panelObj.transform:Find("GDiscardPile"):GetComponent(typeof(Transform))
    self.BtnUno = self.panelObj.transform:Find("BtnUno"):GetComponent(typeof(Button))
    self.BtnDrawPile = self.panelObj.transform:Find("BtnDrawPile"):GetComponent(typeof(Button))
    self.ImgGameTimer = self.panelObj.transform:Find("GGameTimer/ImgTimer"):GetComponent(typeof(Image))
    self.TextGameTimer = self.panelObj.transform:Find("GGameTimer/TextTimer"):GetComponent(typeof(TextMeshPro))
    self.TextPrepareTimer = self.panelObj.transform:Find("TextPrepareTime"):GetComponent(typeof(TextMeshPro))

    self.GConfirmShow = self.panelObj.transform:Find("GConfirmShow"):GetComponent(typeof(Transform))
    self.GWildCardSelectColor = self.panelObj.transform:Find("GWildCardSelectColor"):GetComponent(typeof(Transform))
    self.BtnExit.onClick:AddListener(function() self:OnBtnExitClick() end)
    self.BtnUno.onClick:AddListener(function() self:OnBtnUnoClick() end)
    self.BtnDrawPile.onClick:AddListener(function() self:OnBtnDrawPileClick() end)

    self.GSuspicionDrawFour = self.panelObj.transform:Find("GSuspicionDrawFour"):GetComponent(typeof(Transform))
    self.Text = self.panelObj.transform:Find("Text"):GetComponent(typeof(TextMeshPro))
    MonoBehaviourMgr:Register(self)
end

function GameMatchBasePanel:InitData(playerIds)
    self.gameInstance = UnoGameLogic:Init(playerIds)
end

function GameMatchBasePanel:GetPositionMap()
    error("GetPositionMap must be implemented by subclass")
end

function GameMatchBasePanel:InitComponent(playerIds)
    self.Player2Info = {}
    local playerIndex = 0
    for i = 1, #playerIds do
        if self.gameInstance:IsSelf(playerIds[i]) then
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
        self.Player2Info[curPlayerId] = {}
        self.Player2Info[curPlayerId].BtnAvatar = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/ImgBG/BtnAvatar"):GetComponent(typeof(Button))
        self.Player2Info[curPlayerId].playerName = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/Text"):GetComponent(typeof(TextMeshPro))
        self.Player2Info[curPlayerId].playerName.text = curPlayerId
        self.Player2Info[curPlayerId].HandContainer = self.panelObj.transform:Find("G"..positionMap[pos].."HandContainer"):GetComponent(typeof(Transform))
        self.Player2Info[curPlayerId].TextTurnTimer = self.panelObj.transform:Find("G"..positionMap[pos].."HandContainer/TextTurnTimer"):GetComponent(typeof(TextMeshPro))
        self.Player2Info[curPlayerId].TextPlayingCard = self.panelObj.transform:Find("G"..positionMap[pos].."HandContainer/TextPlayingCard"):GetComponent(typeof(TextMeshPro))
        self.Player2Info[curPlayerId].ImgShoutUno = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/ImgShoutUno"):GetComponent(typeof(Image))
        self.Player2Info[curPlayerId].BtnCatchUno = self.panelObj.transform:Find("GPlayer"..positionMap[pos].."/BtnCatchUno"):GetComponent(typeof(Button))
        self.Player2Info[curPlayerId].BtnCatchUno.onClick:AddListener(function()
            self:OnBtnCatchUnoClicked(curPlayerId) -- 传递当前玩家ID
        end)

        pos = pos + 1
        print("已初始化完成ID"..curPlayerId.."的组件")
    end
    self.GDiscardPile:Find("BtnCardOthers").gameObject:SetActive(false)
    self.totalTimer = CountdownTimer.New()
    self.actionTimer = CountdownTimer.New()
end



-- 万能牌选择按钮初始化
function GameMatchBasePanel:InitWildCardButtons()
    -- 绑定所有颜色按钮
    for _, buttonInfo in ipairs(self.WildCardColorButtons) do
        local buttonPath = "GWildCardSelectColor/GOption/" .. buttonInfo.name
        local button = self.panelObj.transform:Find(buttonPath):GetComponent(typeof(Button))
        
        if button then
            local color = buttonInfo.color
            self:BindButtonClick(button, function()
                self:OnColorSelected(color)
                end)
        end
    end
end

-- 颜色选择回调
function GameMatchBasePanel:OnColorSelected(color)
    print(string.format("颜色选择触发 | 面板激活状态：%s", 
        self.GWildCardSelectColor.gameObject.activeSelf
    ))
    -- 根据万能牌出牌状态 isWildCardFromHandContainer：玩家从手牌中出万能牌、玩家从牌堆中摸到的万能牌
    if self.isWildCardFromHandContainer then
        self.gameInstance.NotifyServerToPlayCard(self.pendingWildCardType,color)
    else 
        self.gameInstance.NotifyServerToPlayDrawnCard(color)
    end
    
    self.pendingWildCardType = nil
    self.GWildCardSelectColor.gameObject:SetActive(false)
end

function GameMatchBasePanel:SetCardImg(cardImage,cardType, cardColor)
    local cardString = string.format("card%d_%s", cardType, cardColor)
    cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)
end

function GameMatchBasePanel:InitFirstCardToDiscardPile(cardType, cardColor)
    local discardCard = GameObject.Instantiate(self.GDiscardPile:Find("BtnCardOthers").gameObject,self.GDiscardPile)
    discardCard:SetActive(true)
    discardCard.transform:SetParent(self.GDiscardPile, false)
    local cardImage = discardCard:GetComponent(typeof(Image))
    self:SetCardImg(cardImage,cardType, cardColor)
end

-- 系统发牌至玩家
function GameMatchBasePanel:OnUnoCardDraw(playerId, cardType, cardColor, confirmshow)
    local HandContainer = self.Player2Info[playerId].HandContainer
    --1.如果是 confirmshow = true 的牌 要在屏幕上展示，并让玩家确认是否需要出掉这张牌
    if self.gameInstance:IsSelf(playerId) and confirmshow then
        self.GConfirmShow.gameObject:SetActive(true)
        local BtnChupai = self.panelObj.transform:Find("GConfirmShow/BtnChupai"):GetComponent(typeof(Button))
        local BtnCancel = self.panelObj.transform:Find("GConfirmShow/BtnCancel"):GetComponent(typeof(Button))
        local showCard = self.panelObj.transform:Find("GConfirmShow/BtnCardOthers"):GetComponent(typeof(Button))
        local cardImage = showCard:GetComponent(typeof(Image))

        self:SetCardImg(cardImage,cardType, cardColor)
        
        BtnChupai.onClick:AddListener(function()
            self.gameInstance.confirmshow = true
            self.gameInstance.m_TempConfirmCard = {cardType = cardType, cardColor = cardColor, cardTransform = showCard.transform}
            self:OnBtnPlayDrawCardClick(cardType, cardColor)
        end)
        BtnCancel.onClick:AddListener(function()
            self:OnBtnCancelClick(playerId, cardType,cardColor,false)
        end)
    else
        self.gameInstance.confirmshow = false
        self.gameInstance.m_TempConfirmCard = nil
        -- 先更新玩家的手牌数据，返回新插入的牌的cardId
        local cardId = self.gameInstance:HandleDrawCard(playerId,cardType,cardColor)

        -- 如果玩家自己得到牌，则排序手牌数据
        if self.gameInstance:IsSelf(playerId) then
            DynamicEffects:SortHandCards(self.gameInstance.m_PlayerCardList[playerId])
        end

        -- 根据玩家 ID 决定卡牌生成的位置
        local cardPrefab = self.gameInstance:IsSelf(playerId) and HandContainer:Find("BtnCard").gameObject or 
        HandContainer:Find("BtnCardOthers").gameObject

        -- 生成卡牌
        local card = GameObject.Instantiate(cardPrefab, HandContainer)
        card.transform:SetParent(HandContainer.transform, false)
        card:SetActive(true)
        
        -- 将 card.tramsform 存入
        self.gameInstance:SetCardTransformToPlayer(playerId,cardId,card.transform)

        -- 为自己的牌添加监听事件、设置卡面
        if self.gameInstance:IsSelf(playerId) then
            local BtnCard = card:GetComponent(typeof(Button))
            BtnCard.onClick:AddListener(function() self:OnCardClick(playerId, cardId) end)

            local cardImage = card.transform:Find("ImgCard"):GetComponent(typeof(Image))
            self:SetCardImg(cardImage,cardType, cardColor)
        else
            local cardImage = card.transform:Find("ImgCardOthers"):GetComponent(typeof(Image))
            self:SetCardImg(cardImage,cardType, cardColor)
        end
        DynamicEffects:UpdateHandLayout(playerId,self.gameInstance.m_PlayerCardList[playerId],HandContainer)
    end
end

-- 玩家自己出牌
function GameMatchBasePanel:OnSelfUnoCardPlay(playerId, cardType, cardColor)
    -- 1.出牌
    local success,cardTransform = self.gameInstance:HandlePlayCard(playerId, cardType, cardColor)
    -- 2.丢牌到弃牌堆
    if success then
        DynamicEffects:AddCardToDiscardPile(cardTransform,self.GDiscardPile,true)
        if self.gameInstance:IsWildCard(cardType) then
            local cardImage = cardTransform:Find("ImgCard"):GetComponent(typeof(Image))
            self:SetCardImg(cardImage,cardType, cardColor)
        end
    -- 3.更新手牌布局
        local HandContainer = self.Player2Info[playerId].HandContainer
        DynamicEffects:UpdateHandLayout(playerId,self.gameInstance.m_PlayerCardList[playerId],HandContainer)
    end
end

-- 对手出牌
function GameMatchBasePanel:OnOtherUnoCardPlay(playerId,cardType,cardColor)
    -- 对手出牌的时候我们只需要看到他少了一张牌就行 所以这里我们默认移除他最左边一张牌
    local cardTransform = self.gameInstance:HandleOtherPlayCard(playerId, cardType, cardColor)
    local HandContainer = self.Player2Info[playerId].HandContainer
    local cardImg = cardTransform.gameObject.transform:Find("ImgCardOthers"):GetComponent(typeof(Image))
    DynamicEffects:AddCardToDiscardPile(cardTransform,self.GDiscardPile,false)
    self:SetCardImg(cardImg,cardType, cardColor)
    DynamicEffects:UpdateHandLayout(playerId,self.gameInstance.m_PlayerCardList[playerId],HandContainer)
end

function GameMatchBasePanel:TimerMgr(playerId,totalRestTime,curOpRestTime)
    -- 先把所有的玩家轮次计时器全部隐藏
    for _, id in ipairs(self.gameInstance.m_Players) do
        self.Player2Info[id].TextTurnTimer.gameObject:SetActive(false)
        self.Player2Info[id].TextPlayingCard.gameObject:SetActive(false)
    end
    -- 再把当前玩家的显示出来
    self.Player2Info[playerId].TextTurnTimer.gameObject:SetActive(true)
    self.Player2Info[playerId].TextPlayingCard.gameObject:SetActive(true)

    self.totalTimer:Start(totalRestTime,"mm:ss")
    self.actionTimer:Start(curOpRestTime,"ss")

    self.totalTimer.onUpdate = function (timestr)
        self.TextGameTimer.text = timestr
    end
    self.actionTimer.onUpdate = function (timestr)
        self.Player2Info[playerId].TextTurnTimer.text = timestr
    end
end

-- 玩家自行点击牌堆 决定出牌
function GameMatchBasePanel:OnBtnPlayDrawCardClick(cardType,cardColor)
    self.GConfirmShow.gameObject:SetActive(false)
    if self.gameInstance:IsWildCard(cardType) then
        print("万能牌: ",cardType,cardColor)
        self.GWildCardSelectColor.gameObject:SetActive(true)
        self.pendingWildCardType = cardType
        self.isWildCardFromHandContainer =false
    else
        -- 非万能牌，直接发送确认出牌消息
        self.gameInstance.NotifyServerToPlayDrawnCard(cardColor)
    end  
end

-- 玩家自行点击牌堆 决定保留
function GameMatchBasePanel:OnBtnCancelClick(playerId, cardType,cardColor,confirmshow)
    
    self.gameInstance.NotifyServerToKeepDrawnCard(cardColor)
    self:OnUnoCardDraw(playerId, cardType,cardColor,confirmshow)
    self.GConfirmShow.gameObject:SetActive(false)
end


function GameMatchBasePanel:ClearAllButCurrentSelection(playerCardList,cardId)
    -- 1.先找场上有没有别的牌被选中
    for _, cardData in ipairs(playerCardList) do
    -- 2.如果有别的牌被选中 恢复别的牌的选中标志位和卡牌位置
        if cardData.cardIsSelected and cardData.cardId ~= cardId then
            cardData.cardIsSelected = false
            local otherCard = cardData.cardTransform
            DynamicEffects:ResetCard(otherCard)
        end
    end
end


-- 玩家按照规则尝试出牌
function GameMatchBasePanel:TryPlayCard(cardData)
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    -- 调用 UnoGameLogic 的 CheckPlayCardRules 方法
    local canPlay, message = self.gameInstance:CheckPlayCardRules(cardData.cardType, cardData.cardColor)

    -- 根据返回值处理逻辑
    if not canPlay then MsgPrompt:ShowPrompt(message, self.panelObj.transform) return end

    -- 如果需要选择颜色，显示颜色选择面板
    if message == self.gameInstance.messages.NEED_COLOR then
        self.GWildCardSelectColor.gameObject:SetActive(true)
        self.pendingWildCardType = cardData.cardType
        self.isWildCardFromHandContainer = true
        return
    end
    -- 非万能牌，直接出牌
    self.gameInstance.NotifyServerToPlayCard(cardData.cardType, cardData.cardColor)
end

-- 手牌点击事件
function GameMatchBasePanel:OnCardClick(playerId, cardId)
    -- 1.如果有别的手牌被点击过 复位手牌位置
    self.GWildCardSelectColor.gameObject:SetActive(false)
    self:ClearAllButCurrentSelection(self.gameInstance.m_PlayerCardList[playerId],cardId)
    -- 2.找到现在被点击的牌
    local cardData = self.gameInstance:FindCardById(playerId, cardId)
    if not cardData then return print("未找到卡牌:", cardId) end
    -- 3.牌已被选中，尝试出牌
    if cardData.cardIsSelected then
        print("已被选中",cardData.cardType,cardData.cardColor)
        self:TryPlayCard(cardData)
        return
    end
    -- 如果牌未曾选中 设置被选择状态和位置
    cardData.cardIsSelected = true
    DynamicEffects:SelectCard(cardData.cardTransform)
end

-- 玩家主动抽牌
function GameMatchBasePanel:OnBtnDrawPileClick()
    self.gameInstance.NotifyServerToDrawCard()
end




function GameMatchBasePanel:PlayerStage(playerId,stage)
    if self.gameInstance:IsSelf(playerId) then
        -- 质疑+4牌阶段
        if stage == EnumRoundStage.eWaitConfirmDrawFour then
            self.GSuspicionDrawFour.gameObject:SetActive(true)
            local BtnSuspicion = self.GSuspicionDrawFour:Find("BtnSuspicion"):GetComponent(typeof(Button))
            local BtnCancel = self.GSuspicionDrawFour:Find("BtnCancel"):GetComponent(typeof(Button))
            self:BindButtonClick(BtnSuspicion, function()
                self.gameInstance.NotifyServerToSuspicionDrawFour(false)
                self.GSuspicionDrawFour.gameObject:SetActive(false)
            end)
            self:BindButtonClick(BtnCancel, function()
                self.gameInstance.NotifyServerToSuspicionDrawFour(true)
                self.GSuspicionDrawFour.gameObject:SetActive(false)
            end) 
        else
            self.GSuspicionDrawFour.gameObject:SetActive(false)
        end
    end
end

function GameMatchBasePanel:ShoutUnoStage(playerId,hasUno)
    if not hasUno then
        self.Player2Info[playerId].BtnCatchUno.gameObject:SetActive(true)
    end
end

function GameMatchBasePanel:OnBtnUnoClick()
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    local success = self.gameInstance:HandleShoutUno(self.gameInstance.m_MyPlayerId)
    if success then
        local ImgUno = self.BtnUno:GetComponent(typeof(Image))
        ImgUno.sprite = self.UISpriteAltas:GetSprite("ShoutUno")
    else 
        MsgPrompt:ShowPrompt("现在不用喊uno", self.panelObj.transform)
        local ImgUno = self.BtnUno:GetComponent(typeof(Image))
        ImgUno.sprite = self.UISpriteAltas:GetSprite("NotTimeToShoutUno")
    end
end

function GameMatchBasePanel:OnBtnCatchUnoClicked(playerId)
    self.gameInstance:NotifyServerToCatchUno(playerId)
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
    local playerHandCard = {}
    for playerId,cardList in pairs(playerCardList) do
        local HandContainer = self.Player2Info[playerId].HandContainer
        playerHandCard[playerId] = {}
        self:ClearHandContainer(HandContainer)

        for _, cardData in ipairs(cardList) do 
            -- 根据玩家 ID 决定卡牌的GameObject名字
            local cardPrefab = self.gameInstance:IsSelf(playerId) and HandContainer:Find("BtnCard").gameObject or 
            HandContainer:Find("BtnCardOthers").gameObject

            -- 生成卡牌
            local card = GameObject.Instantiate(cardPrefab, HandContainer)
            card.transform:SetParent(HandContainer.transform, false)
            card:SetActive(true)
            
            table.insert(playerHandCard[playerId],{cardType=cardData[1],cardColor=cardData[2],cardTransform=card.transform})
            -- 设置卡面
            if self.gameInstance:IsSelf(playerId) then
                local cardImage = card.transform:Find("ImgCard"):GetComponent(typeof(Image))
                self:SetCardImg(cardImage, cardData[1], cardData[2])
            else
                local cardImage = card.transform:Find("ImgCardOthers"):GetComponent(typeof(Image))
                self:SetCardImg(cardImage, cardData[1], cardData[2])
            end
        end

        DynamicEffects:UpdateHandLayout(playerId, playerHandCard[playerId],HandContainer)
    end
end

function GameMatchBasePanel:ShowLastCards(playerId, playerLastCardInfo)
    local HandContainer = self.Player2Info[playerId].HandContainer

    -- 清理 HandContainer
    self:ClearHandContainer(HandContainer)

    -- 遍历 playerLastCardInfo，生成卡面图片
    for _, cardInfo in ipairs(playerLastCardInfo) do
        local cardType = cardInfo.cardType
        local cardColor = cardInfo.cardColor

        -- 根据玩家 ID 决定卡牌生成的位置
        local cardPrefab = self.gameInstance:IsSelf(playerId) and HandContainer:Find("BtnCard").gameObject or 
                           HandContainer:Find("BtnCardOthers").gameObject

        -- 生成卡牌
        local card = GameObject.Instantiate(cardPrefab, HandContainer)
        card.transform:SetParent(HandContainer.transform, false)
        card:SetActive(true)

        -- 为自己的牌设置卡面
        if self.gameInstance:IsSelf(playerId) then
            local cardImage = card.transform:Find("ImgCard"):GetComponent(typeof(Image))
            self:SetCardImg(cardImage, cardType, cardColor)
        else
            local cardImage = card.transform:Find("ImgCardOthers"):GetComponent(typeof(Image))
            cardImage.sprite = self.UnoCardSpriteAltas:GetSprite("CardBack")
        end

        -- 将 card.transform 存储到 cardInfo 中
        cardInfo.cardTransform = card.transform
    end

    -- 更新布局
    DynamicEffects:UpdateHandLayout(playerId, playerLastCardInfo, HandContainer)
end

-- 播放音效
function GameMatchBasePanel:PlaySound(cardType, cardColor)
    local soundName = nil
    if self.PlaySoundByType[cardType] then
        soundName = LuaAudioMgr:GetSoundNameById(cardType)
        LuaAudioMgr:PlaySound(LuaAudioMgr.soundABName, soundName)
    elseif self.gameInstance:IsWildCard(cardType) then
        soundName = LuaAudioMgr:GetSoundNameById(cardColor)
        LuaAudioMgr:PlaySound(LuaAudioMgr.soundABName, soundName)
    end
end

function GameMatchBasePanel:ShowText(cardType, cardColor)
    if self.gameInstance:IsWildCard(cardType) then
        self.Text.text = self.ShowTextByColor[cardColor]
        DynamicEffects:ShowText(self.Text.transform)
    elseif self.ShowTextByType[cardType] ~= nil then
        self.Text.text = self.ShowTextByType[cardType]
        DynamicEffects:ShowText(self.Text.transform)
    end
    
end

function GameMatchBasePanel:OnBtnExitClick()
    self:DestroyPanel()
    MainPanel:ShowMe()
end

-- 更新函数
function GameMatchBasePanel:Update()
    self.totalTimer:Update()
    self.actionTimer:Update()
end
-- 绑定按钮点击事件
function GameMatchBasePanel:BindButtonClick(button, onClickCallback)
    if not button then return end
    -- 解绑已有的事件
    button.onClick:RemoveAllListeners()
    -- 绑定新的事件
    button.onClick:AddListener(onClickCallback)
end

function GameMatchBasePanel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
    self.panelObj = nil
end

return GameMatchBasePanel