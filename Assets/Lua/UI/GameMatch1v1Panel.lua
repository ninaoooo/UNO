GameMatch1V1Panel = {}
local PlayerInfo = require("Tools/PlayerInfo")
local UnoGameLogic = require("GameLogic/UnoGameLogic")
local UnoUILogic = require("UI/UILogic/UnoUILogic")
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
    self.gameInstance  = UnoGameLogic:Init(playerIds)
end


function GameMatch1V1Panel:InitComponent(playerIds)
    -- Player2Info是存储所有玩家的信息，PlayerInfo是存储自己的信息
    self.Player2Info = {}
    -- 找到玩家所在下标
    local playerIndex = 0
    for i = 1, #playerIds do
        -- 通过遍历 playerIds，找到当前玩家（PlayerInfo.playerId）在列表中的下标，这里的下标就当做玩家本局的下标
        if self.gameInstance:IsSelf(playerIds[i]) then
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
        local cardImage = showCard:GetComponent(typeof(Image))

        local cardString = self.gameInstance:GetCardString(cardType,cardColor)
        cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)
        
        BtnChupai.onClick:AddListener(function()
            self:OnBtnPlayDrawCardClick(playerId, cardType,cardColor)
        end)
        BtnCancel.onClick:AddListener(function()
            self:OnBtnCancelClick(playerId, cardType,cardColor,false)
        end)
    else
        -- 先更新玩家的手牌数据
        local cardId = self.gameInstance:GetCardId(cardType,cardColor)
        self.gameInstance:AddCardToPlayer(playerId, cardId,cardType, cardColor)

        -- 如果玩家自己得到牌，则排序手牌数据
        if self.gameInstance:IsSelf(playerId) then
            DynamicEffects:SortHandCards(self.gameInstance.m_PlayerCardList[playerId])
        end

        -- 根据玩家 ID 决定卡牌生成的位置
        if self.gameInstance:IsSelf(playerId) then
            cardPrefab = HandContainer:Find("BtnCard").gameObject
        else
            cardPrefab = HandContainer:Find("BtnCardOthers").gameObject        
        end

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

            local cardString = self.gameInstance:GetCardString(cardType,cardColor)
            local cardImage = card:GetComponent(typeof(Image))
            cardImage.sprite = self.UnoCardSpriteAltas:GetSprite(cardString)
        else
            local cardImage = card:GetComponent(typeof(Image))
            cardImage.sprite = self.UnoCardSpriteAltas:GetSprite("CardBack")
        end
        
        -- DynamicEffects:DrawCard(card.transform, self.GDiscardPile.localPosition , HandContainer.localPosition)
        DynamicEffects:UpdateHandLayout(playerId,self.gameInstance.m_PlayerCardList[playerId],HandContainer)
    end
end

-- 玩家自己出牌
function GameMatch1V1Panel:OnSelfUnoCardPlay(playerId, cardType, cardColor)
    local cardIndex = self.gameInstance:FindCardIndex(playerId, cardType, cardColor)
    local cardData = self.gameInstance.m_PlayerCardList[playerId][cardIndex]
    local card = cardData.cardTransform.gameObject
    -- 1.删除掉要出的这张牌
    self.gameInstance:RemoveCardFromPlayer(playerId, cardIndex)
    -- 2.删除这张手牌的UI
    if card.BtnCard ~=nil then
        card.BtnCard.onClick:RemoveAllListeners()
    end
    GameObject.Destroy(card)
    -- 3.更新手牌布局
    local HandContainer = self.Player2Info[playerId].HandContainer
    DynamicEffects:UpdateHandLayout(playerId,self.gameInstance.m_PlayerCardList[playerId],HandContainer)

end


-- 对手出牌
function GameMatch1V1Panel:OnOtherUnoCardPlay(playerId)
    -- 对手出牌的时候我们只需要看到他少了一张牌就行 所以这里我们默认移除他最左边一张牌
    local HandContainer = self.Player2Info[playerId].HandContainer
    DynamicEffects:UpdateHandLayout(playerId,self.gameInstance.m_PlayerCardList[playerId],HandContainer)
end

function GameMatch1V1Panel:TimerMgr(playerId,totalRestTime,curOpRestTime)
    -- 先把所有的玩家轮次计时器全部隐藏
    if #self.gameInstance.m_Players == 0 then
        print("m_Players为空")
    end
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

function GameMatch1V1Panel:AddCardToDiscardPile(cardType, cardColor)
    -- 将牌添加到弃牌堆
    self.gameInstance:AddCardToDiscardPile(cardType, cardColor)
    
    -- 创建弃牌堆的UI对象
    local discardCard = GameObject.Instantiate(self.GDiscardPile:Find("BtnCardOthers").gameObject, self.GDiscardPile)
    discardCard:SetActive(true)
    
    -- 设置弃牌堆的卡面
    local cardString = self.gameInstance:GetCardString(cardType,cardColor)
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
    -- 调用 UnoGameLogic 的 CheckPlayCardRules 方法
    local canPlay, message = self.gameInstance:CheckPlayCardRules(cardData.cardType, cardData.cardColor)

    -- 根据返回值处理逻辑
    if not canPlay then
        MsgPrompt:ShowPrompt(message, self.panelObj.transform)
        return
    end

    -- 如果需要选择颜色，显示颜色选择面板
    if message == self.gameInstance.messages.NEED_COLOR then
        self:PlayWildCard(function(selectedColor)
            self.gameInstance.NotifyServerToPlayCard(cardData.cardType, selectedColor)
            print("已发送到服务器：", PlayerInfo.playerId, cardData.cardType, selectedColor)
        end)
        return
    end

    -- 非万能牌，直接出牌
    self.gameInstance.NotifyServerToPlayCard(cardData.cardType, cardData.cardColor)
    print("已发送到服务器：", PlayerInfo.playerId, cardData.cardType, cardData.cardColor)
end

-- 手牌点击事件
function GameMatch1V1Panel:OnCardClick(playerId, cardId)
    -- 1.复位手牌位置
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
function GameMatch1V1Panel:OnBtnDrawPileClick()
    self.gameInstance.NotifyServerToDrawCard()
end

-- 玩家抽到的牌 决定出牌
function GameMatch1V1Panel:OnBtnPlayDrawCardClick(playerId, cardType,cardColor)
    self.GConfirmShow.gameObject:SetActive(false)
    -- 1.如果要出的牌是万能牌或万能+4牌
    if self.gameInstance:IsWildCard(cardType) then
        -- 显示颜色选择面板，并等待玩家选择颜色
        self:PlayWildCard(function(selectedColor)
            -- 玩家选择颜色后，发送确认出牌消息
            self.gameInstance.NotifyServerToPlayDrawnCard(selectedColor)
            print("已发送到服务器", playerId, cardType, selectedColor)
            
            self:AddCardToDiscardPile(cardType, selectedColor)
        end)
    else
        -- 非万能牌，直接发送确认出牌消息
        self.gameInstance.NotifyServerToPlayDrawnCard(cardColor)
        print("已发送到服务器", playerId, cardType, cardColor)
        self:AddCardToDiscardPile(cardType, cardColor)
    end
end

-- 玩家抽到的牌 决定保留
function GameMatch1V1Panel:OnBtnCancelClick(playerId, cardType,cardColor,confirmshow)
    
    self.gameInstance.NotifyServerToKeepDrawnCard(cardColor)
    self:OnUnoCardDraw(playerId, cardType,cardColor,confirmshow)
    self.GConfirmShow.gameObject:SetActive(false)
end



-- 如果玩家要出的牌是万能牌或万能+4牌
function GameMatch1V1Panel:PlayWildCard(onColorSelectedCallback)
    -- 显示颜色选择面板
    self.GWildCardSelectColor.gameObject:SetActive(true)
    -- 遍历按钮表，绑定事件
    for _, buttonInfo in ipairs(UnoUILogic.WildCardColorButtons) do
        local buttonPath = "GWildCardSelectColor/GOption/" .. buttonInfo.name
        local button = self.panelObj.transform:Find(buttonPath):GetComponent(typeof(Button))

        UnoUILogic.BindButtonClick(button, function()
            -- 调用颜色选择回调
            if onColorSelectedCallback then
                onColorSelectedCallback(buttonInfo.color)
            end
            -- 隐藏颜色选择面板
            self.GWildCardSelectColor.gameObject:SetActive(false)
        end)
    end
end

function GameMatch1V1Panel:PlayerStage(playerId,stage)
    if self.gameInstance:IsSelf(playerId) then
        -- 质疑+4牌阶段
        if stage == EnumRoundStage.eWaitConfirmDrawFour then
            self.GSuspicionDrawFour.gameObject:SetActive(true)
            local BtnSuspicion = self.GSuspicionDrawFour:Find("BtnSuspicion"):GetComponent(typeof(Button))
            local BtnCancel = self.GSuspicionDrawFour:Find("BtnCancel"):GetComponent(typeof(Button))
            UnoUILogic.BindButtonClick(BtnSuspicion, function()
                self.gameInstance.UnoGameLogic.NotifyServerToSuspicionDrawFour(false)
            end)
            UnoUILogic.BindButtonClick(BtnCancel, function()
                self.gameInstance.NotifyServerToSuspicionDrawFour(true)
            end)
        end
    end
    if stage == EnumRoundStage.eEnd then
        PlayEndPanel:ShowMe()
    end
end


function GameMatch1V1Panel:OnBtnUnoClick()
    MsgPrompt:SetPromptPrefab(self.promptPrefab)
    if self.gameInstance:IsShoutUnoTime() then
        self.gameInstance.NotifyServerToShoutUno()
    else
        MsgPrompt:ShowPrompt("现在不用喊uno", self.panelObj.transform)
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

