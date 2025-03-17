DynamicEffects = {}


local DOTween = CS.DG.Tweening.DOTween
local PathType = CS.DG.Tweening.PathType
local PathMode = CS.DG.Tweening.PathMode
local Ease = CS.DG.Tweening.Ease

-- 默认卡牌宽度和间距
DynamicEffects.cardWidth = 180

-- 设置卡牌宽度
function DynamicEffects:SetCardWidth(width)
    self.cardWidth = width
end

-- 默认卡牌偏移量
DynamicEffects.fixedOffsetX = 50  -- 固定偏移量（空间足够时使用）
DynamicEffects.minOffsetX = 10    -- 最小偏移量（空间不足时使用）

-- 设置固定偏移量
function DynamicEffects:SetFixedOffsetX(offsetX)
    self.fixedOffsetX = offsetX
end

-- 设置最小偏移量
function DynamicEffects:SetMinOffsetX(offsetX)
    self.minOffsetX = offsetX
end

-- 设置卡牌偏移量
function DynamicEffects:SetCardOffset(offsetX)
    self.cardOffsetX = offsetX
end

function DynamicEffects:DrawCard(cardTransform, drawPilePos, handContainerPos)
    -- 设置卡牌的初始位置
    cardTransform.localPosition = drawPilePos
    local path = { drawPilePos, Vector3((drawPilePos.x + handContainerPos.x) / 2, drawPilePos.y + 100, 0), handContainerPos }
    cardTransform:DOLocalPath(path, 3.0, PathType.CatmullRom, PathMode.Full3D, 10)
        :SetEase(Ease.OutQuad)
end


-- 排序手牌数据
function DynamicEffects:SortHandCards(cardList)
    table.sort(cardList, function(a, b)
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

-- 更新手牌布局（自适应偏移量）
function DynamicEffects:UpdateHandLayout(playerId,handContainer)
    local playerCardList = GameMatch1V1Panel.m_PlayerCardList[playerId]
    local cardCount = #playerCardList
    if cardCount == 0 then return end  -- 如果没有牌，直接返回

    -- 获取 HandContainer 的宽度
    local containerWidth = handContainer:GetComponent(typeof(RectTransform)).rect.width

    -- 计算每张牌需要的总宽度
    local totalWidthNeeded = cardCount * self.fixedOffsetX

    -- 如果总宽度超过容器宽度，则使用自适应偏移量
    local offsetX = self.fixedOffsetX
    if totalWidthNeeded > containerWidth then
        offsetX = math.max(self.minOffsetX, containerWidth / cardCount)
    end

    -- 计算中间位置的索引
    local middleIndex = math.floor(cardCount / 2)

    for i,cardData in ipairs(playerCardList) do
        local cardTransform = cardData.cardTransform
        local offsetFromMiddle = i - 1 - middleIndex  -- 当前牌距离中间位置的偏移
        local posX = offsetFromMiddle * offsetX  -- 计算 X 轴位置

        -- 保持 Y 和 Z 轴位置不变，只调整 X 轴位置
        local currentPosition = cardTransform.localPosition
        cardTransform.localPosition = Vector3(posX, currentPosition.y, currentPosition.z)
        -- 设置卡牌的层级顺序
        cardTransform:SetSiblingIndex(i-1)
    end
end



-- 手牌被选中后 往上移动20个单位
function DynamicEffects:SelectCard(cardTransform)
    local currentPosition = cardTransform.localPosition
    cardTransform.localPosition = Vector3(currentPosition.x, currentPosition.y + 20, currentPosition.z)
end

-- 取消选中状态 手牌恢复原始位置
function DynamicEffects:ResetCard(cardTransform)
    local currentPosition = cardTransform.localPosition
    cardTransform.localPosition = Vector3(currentPosition.x, currentPosition.y - 20, currentPosition.z)
end

function DynamicEffects:PlayCard(card)
    print("Play card: ", card.name)
end

function DynamicEffects:AddCardToDiscardPile(cardTransform)
    -- 设置随机旋转角度
    local randomRotation = math.random(-15,15)
    cardTransform.rotation = Quaternion.Euler(0,0,randomRotation)
end




return DynamicEffects