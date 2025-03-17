GameMatch1V1Panel = {}

GameMatch1V1Panel.panelObj = nil
GameMatch1V1Panel.ImgBG = nil
GameMatch1V1Panel.SelfAvatar = nil
GameMatch1V1Panel.SelfName = nil
GameMatch1V1Panel.OpponentAvatar = nil
GameMatch1V1Panel.OpponentName = nil
GameMatch1V1Panel.GDiscardPile = nil
GameMatch1V1Panel.BtnUno = nil
GameMatch1V1Panel.BtnDrawPile = nil
GameMatch1V1Panel.ImgGameTimer = nil
GameMatch1V1Panel.TextGameTimer = nil
GameMatch1V1Panel.TextTurnTimer = nil
GameMatch1V1Panel.BtnSetting = nil



function GameMatch1V1Panel:Init(playerIds)
    if  self.panelObj == nil then
        self.panelObj = ABMgr:LoadRes("UI", "GameMatch1v1Panel")
        self.panelObj.transform:SetParent(Canvas,false)

        self.UnoCardSpriteAltas = ABMgr:LoadRes("UI", "UnoCard")
        self.promptPrefab = ABMgr:LoadRes("modes", "GMsgPrompt")
        
        self.BtnSetting = self.panelObj.transform:Find("GSettings/Button"):GetComponent(typeof(Button))
        self.ImgBG = self.panelObj.transform:Find("ImgBG"):GetComponent(typeof(Image))
        self.GDiscardPile = self.panelObj.transform:Find("GDiscardPile"):GetComponent(typeof(Transform))
        self.BtnUno = self.panelObj.transform:Find("BtnUno"):GetComponent(typeof(Button))
        self.BtnDrawPile = self.panelObj.transform:Find("BtnDrawPile"):GetComponent(typeof(Button))
        self.ImgGameTimer = self.panelObj.transform:Find("GGameTimer/ImgTimer"):GetComponent(typeof(Image))
        self.TextGameTimer = self.panelObj.transform:Find("GGameTimer/TextTimer"):GetComponent(typeof(TextMeshPro))
        self.TextPrepareTimer = self.panelObj.transform:Find("TextPrepareTime"):GetComponent(typeof(TextMeshPro))

        self.GConfirmShow = self.panelObj.transform:Find("GConfirmShow"):GetComponent(typeof(Transform))
        self.GWildCardSelectColor = self.panelObj.transform:Find("GWildCardSelectColor"):GetComponent(typeof(Transform))
        self.BtnUno.onClick:AddListener(function() self:OnBtnUnoClick() end)
        self.BtnDrawPile.onClick:AddListener(function() self:OnBtnDrawPileClick() end)
        
        self.GSuspicionDrawFour = self.panelObj.transform:Find("GSuspicionDrawFour")
        MonoBehaviourMgr:Register(self)

        self:InitData(playerIds)
        self:InitComponent(playerIds)
    end
end

-- 初始化拿到的数据
function GameMatch1V1Panel:InitData(playerIds)
    -- 记录所有玩家
    self.m_Players = playerIds
    
    -- 初始化弃牌堆
    self.m_DiscardList = {}

    -- 初始化玩家手牌 手牌类型，颜色
    self.m_PlayerCardList = {}
    for i = 1, #playerIds do
        self.m_PlayerCardList[playerIds[i]] = {}
    end

    -- 初始化当前玩家
    self.m_CurPlayerId = playerIds[1]

    -- 初始化喊了UNO的玩家 playerId -> uno
    self.m_HasUno = {}

    -- 初始化cardId
    self.nextCardId = 1

end


function GameMatch1V1Panel:InitComponent(playerIds)
    -- Player2Info是存储所有玩家的信息，PlayerInfo是存储自己的信息
    self.Player2Info = {}
    -- 找到玩家所在下标
    local playerIndex = 0
    for i = 1, #playerIds do
        -- 通过遍历 playerIds，找到当前玩家（PlayerInfo.playerId）在列表中的下标，这里的下标就当做玩家本局的下标
        if playerIds[i] == PlayerInfo.playerId then
            playerIndex = i
            break
        end
    end
    local positionMap = {
        [1] = "Self",     -- 自己
        [2] = "Opponent"  -- 对面
    }
    -- 玩家自己在最下面
    -- 初始化一个变量 pos，用于表示当前玩家在 UI 中的位置
    local pos = 1
    -- 从玩家自己的下标开始遍历所有玩家，确保当前玩家始终位于最下面
    -- 如果有 3 个玩家，当前玩家下标为 2，则循环范围为 2, 3, 4。
    for i = playerIndex, playerIndex + #playerIds - 1 do
        -- 计算当前循环索引 i 在玩家列表中的实际下标。如果有 3 个玩家：
        -- 当 i = 2 时，idx = 2 % 3 = 2。当 i = 3 时，idx = 3 % 3 = 0。当 i = 4 时，idx = 4 % 3 = 1
        local idx = i % #playerIds

        -- 在 Lua 中，列表的下标从 1 开始，而不是 0。如果 idx == 0，表示当前索引超出了玩家列表的范围，需要将其映射到最后一个玩家。
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
        pos = pos + 1
        print("已初始化完成ID"..curPlayerId.."的组件")
    end
    -- 弃牌堆
    self.GDiscardPile:Find("BtnCardOthers").gameObject:SetActive(false)

    -- 两个计时器
    self.totalTimer = CountdownTimer.New()
    self.actionTimer = CountdownTimer.New()

end



-- 玩家抽牌
function GameMatch1V1Panel:OnUnoCardDraw(playerId, cardType, cardColor, confirmshow)
    local HandContainer = self.Player2Info[playerId].HandContainer
    local cardPrefab = nil

    --1.如果是 confirmshow = true 的牌 要在屏幕上展示，并让玩家确认是否需要出掉这张牌
    if confirmshow then
        self.GConfirmShow.gameObject:SetActive(true)
        local BtnChupai = self.panelObj.transform:Find("GConfirmShow/BtnChupai"):GetComponent(typeof(Button))
        local BtnCancel = self.panelObj.transform:Find("GConfirmShow/BtnCancel"):GetComponent(typeof(Button))
        local showCard = self.panelObj.transform:Find("GConfirmShow/BtnCardOthers"):GetComponent(typeof(Button))

        local cardString = EnumCardColour[cardColor] ..EnumCardType[cardType]
        local cardImage = showCard:GetComponent(typeof(Image))
        cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)

        BtnChupai.onClick:AddListener(function()
            self:OnBtnChupaiClick(playerId, cardType,cardColor)
        end)
        BtnCancel.onClick:AddListener(function()
                self:OnBtnCancelClick(playerId, cardType,cardColor,false)
        end)
    else
        -- 先更新玩家的手牌数据
        local cardId = self.nextCardId
        self.nextCardId = self.nextCardId + 1
        table.insert(self.m_PlayerCardList[playerId], {cardId = cardId,cardType = cardType, cardColor = cardColor, cardIsSelected = false,cardTransform = nil})

        -- 如果玩家自己得到牌，则排序手牌数据
        if playerId == PlayerInfo.playerId then
            DynamicEffects:SortHandCards(self.m_PlayerCardList[playerId])
        end

        -- 根据玩家 ID 决定卡牌生成的位置
        if playerId == PlayerInfo.playerId then
            cardPrefab = HandContainer:Find("BtnCard").gameObject
        else
            cardPrefab = HandContainer:Find("BtnCardOthers").gameObject        
        end

        -- 生成卡牌
        local card = GameObject.Instantiate(cardPrefab, HandContainer)
        card.transform:SetParent(HandContainer.transform, false)
        card:SetActive(true)
        
        -- 将 card.tramsform 存入
        for _, cardData in ipairs(self.m_PlayerCardList[playerId]) do
            if cardData.cardId == cardId then
                cardData.cardTransform = card.transform
                break
            end
        end

        -- 为自己的牌添加监听事件、设置卡面
        if playerId == PlayerInfo.playerId then
            local BtnCard = card:GetComponent(typeof(Button))
            BtnCard.onClick:AddListener(function()
                    self:OnCardClick(playerId, cardId)
                end)

            local cardString = EnumCardColour[cardColor] ..EnumCardType[cardType]
            local cardImage = card:GetComponent(typeof(Image))
            cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)
        else
            local cardImage = card:GetComponent(typeof(Image))
            cardImage.sprite = self.UnoCardSpriteAltas:GetSprite("Wild_Card_Empty")
        end
        
        -- DynamicEffects:DrawCard(card.transform, self.GDiscardPile.localPosition , HandContainer.localPosition)
        DynamicEffects:UpdateHandLayout(playerId,HandContainer)
    end
end

-- 玩家自己出牌
function GameMatch1V1Panel:OnSelfUnoCardPlay(playerId, cardType, cardColor)
    for i, cardData in ipairs(self.m_PlayerCardList[playerId]) do
        if cardData.cardType == cardType and (cardData.cardColor == cardColor or cardType == EnumUnoCardType.eWild or cardType == EnumUnoCardType.eWildDrawFour) then
            -- 先删除掉要出的这张牌
            table.remove(self.m_PlayerCardList[playerId], i)
            -- 再删除掉玩家手牌UI 
            local card = cardData.cardTransform.gameObject
            -- 在销毁卡牌前要先移除该卡牌的监听器
            if card.BtnCard ~=nil then
                card.BtnCard.onClick:RemoveAllListeners()
            end
            -- 销毁卡牌对象
            GameObject.DestroyImmediate(card)

            -- 更新手牌布局
            local HandContainer = self.Player2Info[playerId].HandContainer
            DynamicEffects:UpdateHandLayout(playerId,HandContainer)
            break
        end
    end
end


-- 对手出牌
function GameMatch1V1Panel:OnOtherUnoCardPlay(playerId)
    -- 对手出牌的时候我们只需要看到他少了一张牌就行 所以这里我们默认移除他最左边一张牌
    local HandContainer = self.Player2Info[playerId].HandContainer
    -- local card = HandContainer:GetChild(0)
    -- GameObject.Destroy(card.gameObject)
    DynamicEffects:UpdateHandLayout(playerId,HandContainer)
end

function GameMatch1V1Panel:TimerMgr(playerId,totalRestTime,curOpRestTime)
    -- 先把所有的玩家轮次计时器全部隐藏
    for _, id in ipairs(self.m_Players) do
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
function GameMatch1V1Panel:AddCardToDiscardPile(cardType, cardColor)
    -- 将牌添加到弃牌堆
    table.insert(self.m_DiscardList, {cardType = cardType, cardColor = cardColor})
    
    -- 创建弃牌堆的UI对象
    local discardCard = GameObject.Instantiate(self.GDiscardPile:Find("BtnCardOthers").gameObject, self.GDiscardPile)
    discardCard:SetActive(true)
    
    -- 设置弃牌堆的卡面
    local cardString = EnumCardColour[cardColor] .. EnumCardType[cardType]
    print("cardString",cardString)
    local cardImage = discardCard:GetComponent(typeof(Image))
    cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)
    
    -- 更新弃牌堆的UI布局
    DynamicEffects:AddCardToDiscardPile(discardCard.transform)
end

function GameMatch1V1Panel:ClearAllButCurrentSelection(playerCardList,cardId)
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

-- 找到现在被点击的牌
function GameMatch1V1Panel:FindNowClickedCard(playerCardList, cardId)
    for _, cardData in ipairs(playerCardList) do
        if cardData.cardId == cardId then
            return cardData
        end
    end
    return nil
end

-- 玩家按照规则尝试出牌
function GameMatch1V1Panel:TryPlayCard(cardData)
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    -- 1.检查是否是当前玩家的轮次
    if self.curPlayerId ~= PlayerInfo.playerId then
        MsgPrompt:ShowPrompt("现在不是你的出牌时间", self.panelObj.transform)
        return
    end
     -- 2. 检查是否符合出牌规则
     if not self:IsValidPlay(cardData.cardType, cardData.cardColor) then
        MsgPrompt:ShowPrompt("选中的牌不符合出牌规则", self.panelObj.transform)
        print("选中的牌不符合出牌规则", cardData.cardType, cardData.cardColor)
        return
    end
     -- 3. 如果是万能牌，显示颜色选择面板
     if self:IsWildCard(cardData.cardType) then
        self:PlayWildCard(function(selectedColor)
            C2S.UnoPlayPlayerPlayCard(cardData.cardType, selectedColor)
            print("已发送到服务器：", PlayerInfo.playerId, cardData.cardType, selectedColor)
        end)
        return
    end
     -- 4. 非万能牌，直接出牌
     C2S.UnoPlayPlayerPlayCard(cardData.cardType, cardData.cardColor)
     print("已发送到服务器：", PlayerInfo.playerId, cardData.cardType, cardData.cardColor)
end
-- 手牌点击事件
function GameMatch1V1Panel:OnCardClick(playerId, cardId)
    local playerCardList = self.m_PlayerCardList[playerId]
    
    -- 1.复位手牌位置
    self:ClearAllButCurrentSelection(playerCardList,cardId)
    -- 2.找到现在被点击的牌
    local cardData = self:FindNowClickedCard(playerCardList, cardId)
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
function GameMatch1V1Panel:OnBtnDrawPileClick()
    C2S.UnoPlayPlayerDrawCard()
end

-- 玩家抽到的牌 决定出牌
function GameMatch1V1Panel:OnBtnChupaiClick(playerId, cardType,cardColor)
    self.GConfirmShow.gameObject:SetActive(false)
    print("Card Type:", cardType, "Is Wild Card:", self:IsWildCard(cardType))
    -- 1.如果要出的牌是万能牌或万能+4牌
    if self:IsWildCard(cardType) then
        -- 显示颜色选择面板，并等待玩家选择颜色
        self:PlayWildCard(function(selectedColor)
            -- 玩家选择颜色后，发送确认出牌消息
            C2S.UnoPlayPlayerConfirmOut(true, selectedColor)
            print("已发送到服务器", playerId, cardType, selectedColor)
            
            self:AddCardToDiscardPile(cardType, selectedColor)
        end)
    else
        -- 非万能牌，直接发送确认出牌消息
        C2S.UnoPlayPlayerConfirmOut(true, cardColor)
        print("已发送到服务器", playerId, cardType, cardColor)
        self:AddCardToDiscardPile(cardType, cardColor)
    end
end

-- 玩家抽到的牌 决定保留
function GameMatch1V1Panel:OnBtnCancelClick(playerId, cardType,cardColor,confirmshow)
    
    C2S.UnoPlayPlayerConfirmOut(false,cardColor)
    print("已发送到服务器",playerId, cardType,cardColor)
    self:OnUnoCardDraw(playerId, cardType,cardColor,confirmshow)
    self.GConfirmShow.gameObject:SetActive(false)
end

-- 判断玩家选择的牌是否符合出牌规则
function GameMatch1V1Panel:IsValidPlay(cardType,cardColor)
    local otherValidType = {
        [EnumUnoCardType.eWild] = true,
        [EnumUnoCardType.eWildDrawFour] = true
    }
    local lastPlayedCard = self.m_DiscardList[#self.m_DiscardList]
    -- 判断条件:颜色相同或者类型相同或符合某些类型(万能牌\万能+4牌)
    if lastPlayedCard.cardColor == cardColor or lastPlayedCard.cardType == cardType or otherValidType[cardType] then
        return true
    end
    return false
end

function GameMatch1V1Panel:IsWildCard(cardType)
    return cardType == EnumUnoCardType.eWild or cardType == EnumUnoCardType.eWildDrawFour
end

-- 如果玩家要出的牌是万能牌或万能+4牌
function GameMatch1V1Panel:PlayWildCard(onColorSelectedCallback)
    -- 显示颜色选择面板
    self.GWildCardSelectColor.gameObject:SetActive(true)

    -- 定义按钮名称和对应的颜色
    local colorButtons = {
        { name = "BtnRed", color = EnumUnoCardColor.eRed },
        { name = "BtnBlue", color = EnumUnoCardColor.eBlue },
        { name = "BtnGreen", color = EnumUnoCardColor.eGreen },
        { name = "BtnYellow", color = EnumUnoCardColor.eYellow },
    }

    -- 遍历按钮表，绑定事件
    for _, buttonInfo in ipairs(colorButtons) do
        local buttonPath = "GWildCardSelectColor/GOption/" .. buttonInfo.name
        local button = self.panelObj.transform:Find(buttonPath):GetComponent(typeof(Button))
        -- 解绑已有的事件
        button.onClick:RemoveAllListeners()
        -- 绑定新的事件
        button.onClick:AddListener(function()
            -- 调用颜色选择回调
            if onColorSelectedCallback then onColorSelectedCallback(buttonInfo.color) end
            -- 隐藏颜色选择面板
            self.GWildCardSelectColor.gameObject:SetActive(false)
        end)
    end
end

function GameMatch1V1Panel:PlayerStage(playerId,stage)
    if playerId == PlayerInfo.playerId then
        -- 质疑+4牌阶段
        if stage == EnumRoundStage.eWaitConfirmDrawFour then
            self.GSuspicionDrawFour.gameObject:SetActive(true)
            local BtnSuspicion = self.GSuspicionDrawFour:Find("BtnSuspicion"):GetComponent(typeof(Button))
            local BtnCancel = self.GSuspicionDrawFour:Find("BtnCancel"):GetComponent(typeof(Button))
            -- 解绑已有的事件
            BtnSuspicion.onClick:RemoveAllListeners()
            BtnCancel.onClick:RemoveAllListeners()
            -- 绑定新的事件
            BtnSuspicion.onClick:AddListener(function()
                C2S.UnoPlayPlayerResponseDrawFour(false)
            end)
            BtnCancel.onClick:AddListener(function()
                C2S.UnoPlayPlayerResponseDrawFour(true)
            end)
        end
    end
    if stage == EnumRoundStage.eEnd then
        PlayEndPanel:ShowMe()
    end
end


function GameMatch1V1Panel:OnBtnUnoClick()
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    if self.curPlayerId == PlayerInfo.playerId then
        if #self.m_PlayerCardList[PlayerInfo.playerId] == 2 then
            C2S.UnoPlayPlayerShoutUno()
        else
            MsgPrompt:ShowPrompt("现在不用喊uno", self.panelObj.transform)
        end
    else
        MsgPrompt:ShowPrompt("现在不是你的出牌时间", self.panelObj.transform)
    end
end

-- 更新函数
function GameMatch1V1Panel:Update()
    self.totalTimer:Update()
    self.actionTimer:Update()
end

-- 销毁窗口
function GameMatch1V1Panel:DestroyPanel()
    GameObject.Destroy(self.panelObj)
end

