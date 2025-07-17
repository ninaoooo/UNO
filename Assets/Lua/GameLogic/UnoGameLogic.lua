UnoGameLogic = {}
local PlayerInfo = require("Tools/PlayerInfo")
function UnoGameLogic:Init(playerIds)
    local instance = {
        -- 初始化玩家列表
        m_Players = playerIds,
        -- 初始化所有玩家手牌列表
        m_PlayerCardList = {},
        -- 初始化弃牌堆手牌列表
        m_DiscardList = {},
        -- 初始化是否是初始牌状态
        m_initCardCnt = {},
        initCardsStage = true;
        -- 初始化我的要确认的临时手牌
        m_TempConfirmCard = nil,
        confirmshow = false,
        -- 初始化当前玩家id
        m_currentPlayerId = playerIds[1],
        -- 初始化喊了Uno的玩家
        m_hasUno = {},
        -- 初始化自身玩家
        m_MyPlayerId = PlayerInfo:GetPlayerId(),
        -- 初始化cardId
        nextCardId = 1,
        messages = {
            NOT_YOUR_TURN = "现在不是你的出牌时间",
            INVALID_PLAY = "选中的牌不符合出牌规则",
            NEED_COLOR = "需要选择颜色",
            CAN_PLAY = "可以出牌"
        }
    }
    
    -- 初始化所有玩家手牌列表
    for i = 1, #playerIds do
        instance.m_PlayerCardList[playerIds[i]] = {}
    end

    -- 初始化所有玩家喊Uno列表
    for i = 1, #playerIds do
        instance.m_hasUno[playerIds[i]] = false
    end

    -- 初始化所有玩家手牌数量列表
    for i = 1, #playerIds do
        instance.m_initCardCnt[playerIds[i]] = 0
    end
    setmetatable(instance, { __index = UnoGameLogic })
    return instance
end



function UnoGameLogic:IsSelf(playerId)
    return playerId == self.m_MyPlayerId
end

function UnoGameLogic:GetCardId()
    local cardId = self.nextCardId
    self.nextCardId = self.nextCardId + 1
    return cardId
end



function UnoGameLogic:FindCardIndexByCardData(cardType,cardColor)
    for index, cardData in ipairs(self.m_PlayerCardList[self.m_MyPlayerId]) do
        if cardData.cardType == cardType and (cardData.cardColor == cardColor or self:IsWildCard(cardData.cardType)) then
            return index, cardData
        end
    end
end 

function UnoGameLogic:FindCardById(cardId)
    for index, cardData in ipairs(self.m_PlayerCardList[self.m_MyPlayerId]) do
        if cardData.cardId == cardId then
            return index,cardData
        end
    end
    return nil,nil
end

function UnoGameLogic:IsWildCard(cardType)
    return cardType == EnumUnoCardType.eWild or cardType == EnumUnoCardType.eWildDrawFour
end

-- 判断玩家选择的牌是否符合出牌规则
function UnoGameLogic:IsValidPlay(cardType,cardColor)
    local otherValidType = {[EnumUnoCardType.eWild] = true,[EnumUnoCardType.eWildDrawFour] = true}
    local lastPlayedCard = self.m_DiscardList[#self.m_DiscardList]
    -- 判断条件:颜色相同或者类型相同或符合某些类型(万能牌\万能+4牌)
    if lastPlayedCard.cardColor == cardColor or lastPlayedCard.cardType == cardType or otherValidType[cardType] then
        return true
    end
    return false
end

function UnoGameLogic:IsTimeToShoutUno()
    if #self.m_PlayerCardList[self.m_MyPlayerId] <= 2 then
        self:NotifyServerToShoutUno()
        return true
    end
    return false
end

function UnoGameLogic:SortHandCards()
    table.sort(self.m_PlayerCardList[self.m_MyPlayerId], function(a, b)
        -- 按颜色排序（cardColor 越小优先级越高）
        if a.cardColor ~= b.cardColor then
            return a.cardColor < b.cardColor
        end
        -- 颜色相同，按类型排序（cardType 越小优先级越高）
        if a.cardType ~= b.cardType then
        
            return a.cardType < b.cardType
        end
        -- 颜色和类型都相同，按照cardId排序（cardId 越小优先级越高）
        return a.cardId < b.cardId
    end)
end

function UnoGameLogic:AddCardToSelf(cardId,cardType,cardColor,cardTransform)
    table.insert(self.m_PlayerCardList[self.m_MyPlayerId],{cardId = cardId, cardType = cardType, cardColor = cardColor, cardTransform = cardTransform})
    self:SortHandCards()
end

function UnoGameLogic:SetCardTransformToSelf(cardId,cardTransform)
    for _, cardData in ipairs(self.m_PlayerCardList[self.m_MyPlayerId]) do
        if cardData.cardId == cardId then
            cardData.cardTransform = cardTransform
            break
        end
    end
end

function UnoGameLogic:RemoveCardFromPlayer(cardIndex)
    table.remove(self.m_PlayerCardList[self.m_MyPlayerId], cardIndex)
end

function UnoGameLogic:AddCardToDiscard(cardType, cardColor)
    table.insert(self.m_DiscardList, {cardType = cardType, cardColor = cardColor})
end

-- function UnoGameLogic:HandleDrawCard(cardType, cardColor)
--     -- 抽牌逻辑
--     local cardId = self:GetCardId()
--     self:AddCardToSelf(cardId, cardType, cardColor)
--     -- return cardId
-- end

-- 处理出牌
function UnoGameLogic:HandleSelfPlayCard(cardType, cardColor)
    local cardIndex, cardData = self:FindCardIndexByCardData(cardType, cardColor)
    if cardIndex then
        local cardTransform = cardData.cardTransform
        self:RemoveCardFromPlayer(cardIndex)
        return cardTransform
    -- elseif self.confirmshow and self.m_TempConfirmCard ~= nil then
    --     if self.m_TempConfirmCard.cardType == cardType and self.m_TempConfirmCard.cardColor == cardColor then
    --         return self.m_TempConfirmCard.cardTransform
    --     end
    end
end
function UnoGameLogic:HandleOtherPlayCard(playerId)
    self.m_initCardCnt[playerId] = self.m_initCardCnt[playerId] - 1
end


function UnoGameLogic:CheckPlayCardRules(cardType, cardColor)
    -- 检查是否是当前玩家的轮次
    if not self:IsSelf(self.m_currentPlayerId) then
        return false, self.messages.NOT_YOUR_TURN
    end

    -- 检查是否符合出牌规则
    if not self:IsValidPlay(cardType, cardColor) then
        return false, self.messages.INVALID_PLAY
    end

    -- 如果是万能牌，返回需要选择颜色的标志
    if self:IsWildCard(cardType) then
        print("万能牌")
        return true, self.messages.NEED_COLOR
    end

    -- 非万能牌，直接出牌
    return true, self.messages.CAN_PLAY
end

function UnoGameLogic:IsNeedToShoutUno(playerId)
    if #self.m_PlayerCardList[playerId] == 1 and self.m_hasUno[playerId]==false then
        return playerId
    end
    return nil
end


function UnoGameLogic.NotifyServerToSuspicionDrawFour(isCancel)
    if isCancel then
        C2S.UnoPlayPlayerResponseDrawFour(true)
    else
        C2S.UnoPlayPlayerResponseDrawFour(false)
    end
end

function UnoGameLogic.NotifyServerToPlayDrawnCard(cardColor)
    C2S.UnoPlayPlayerConfirmOut(true,cardColor)
end

function UnoGameLogic.NotifyServerToKeepDrawnCard(cardColor)
    C2S.UnoPlayPlayerConfirmOut(false,cardColor)
end

function UnoGameLogic.NotifyServerToPlayCard(cardType,cardColor)
    C2S.UnoPlayPlayerPlayCard(cardType,cardColor)
end

function UnoGameLogic.NotifyServerToShoutUno()
    C2S.UnoPlayPlayerShoutUno()
end

function UnoGameLogic.NotifyServerToDrawCard()
    C2S.UnoPlayPlayerDrawCard()
end

function UnoGameLogic:NotifyServerToCatchUno(playerId)
    C2S.UnoPlayPlayerCatchNoUno(playerId)
end
return UnoGameLogic