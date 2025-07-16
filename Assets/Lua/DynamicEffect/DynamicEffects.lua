DynamicEffects = {}

local DOTween = CS.DG.Tweening.DOTween
local PathType = CS.DG.Tweening.PathType
local PathMode = CS.DG.Tweening.PathMode
local RotateMode = CS.DG.Tweening.RotateMode
local Ease = CS.DG.Tweening.Ease
local Random = CS.UnityEngine.Random

local UnoCardSpriteAltas = ABMgr:LoadRes("UI", "UnoCard")

DynamicEffects.randomRotation = math.random(-30, 30)
-- 默认卡牌宽度和间距
DynamicEffects.cardWidth = 180
DynamicEffects.cardSpacing = 30
DynamicEffects.cardPosY = 20 
DynamicEffects.targetRotationZ = 0 

function DynamicEffects.SetCardImg(cardImage,cardType, cardColor)
    local cardString = string.format("card%d_%s", cardType, cardColor)
    cardImage.sprite = UnoCardSpriteAltas:GetSprite(cardString)
end

function DynamicEffects.FirstCardToDiscardPile(cardTransform, discardPile, doScale, cardType, cardColor)
    -- 获取世界坐标
    local discardPilePos = discardPile.transform.position
    local sequence = DOTween.Sequence()
    local cardImage = cardTransform:GetComponent(typeof(Image))
    DynamicEffects.SetCardImg(cardImage, cardType, cardColor)
    sequence:Append(
        -- 抛物线动画 DOJump(discardPilePos,jumpPower, 1, jumpDuration )
        cardTransform:DOJump(discardPilePos,3, 1, 1)
        :SetEase(Ease.OutQuad) -- 落地时减速
        :OnComplete(function()
            cardTransform:SetParent(discardPile)
        end)
    )
    sequence:Join(
        cardTransform:DORotate(Vector3(0, 0, DynamicEffects.randomRotation), 0.1)
            :SetEase(Ease.InOutQuad)
    )
    if doScale then
        sequence:Join(
            cardTransform:DOScale(Vector3(0.8, 0.8, 1), 0.3)
                :SetEase(Ease.InOutQuad)
        )
    end
end
DynamicEffects.microOffsetX = 40
-- DynamicEffects.microOffsetZ  = -0.01
DynamicEffects.InitCardCnt = 0
function DynamicEffects.InitCardFromDrawPileToHand(currentCardCnt,cardTransform,handCntTrans,cardType,cardColor,sortedCardsList)
    local cardImage = cardTransform:GetComponent(typeof(Image))
    DynamicEffects.SetCardImg(cardImage, 15, 6) 
    local handCntPos = handCntTrans.transform.position
    local handCntPosParent = handCntTrans.transform.parent
    
    -- 根据当前是第几张初始牌来计算偏移,如果有 7 张牌，中心点在第 4 张。
    -- (currentInitialCardCount - 1) 得到的是 0 到 6 的索引
    -- 减去 (GameState.EXPECTED_INITIAL_CARDS - 1) / 2 是为了让中心牌的偏移接近 0
    local offsetX = (currentCardCnt - 1 - (7 - 1) / 2) * DynamicEffects.microOffsetX 
    local worldOffsetX = handCntPosParent:TransformVector(Vector3(offsetX, 0, 0))
    local targetMidPosition = Vector3(handCntPos.x + worldOffsetX.x,DynamicEffects.cardPosY, handCntPos.z)

    local sequence = DOTween.Sequence()
    sequence:Append(
        cardTransform:DOJump(targetMidPosition, 5, 1, 0.5)
            :SetEase(Ease.OutQuad)
    )
    -- 图片揭示：在飞入动画快结束时揭示牌面
    local revealTime = 0.1
    sequence:InsertCallback(revealTime, function()
        DynamicEffects.SetCardImg(cardImage, cardType, cardColor) 
    end)
    sequence:OnComplete(function()
        print(string.format("第 %d 张初始牌飞入动画完成。", currentCardCnt))
        cardTransform:SetParent(handCntTrans) -- 动画完成后，设置父对象为手牌堆
        DynamicEffects.InitCardCnt = DynamicEffects.InitCardCnt+1
        if(DynamicEffects.InitCardCnt == 7) then 
            DynamicEffects.OrganizeInitCards(sortedCardsList,handCntTrans)
        end
    end)
    sequence:Play()
    
end

function DynamicEffects.OrganizeInitCards(sortedCardsList,handCntTrans)
    local GATHER_DURATION = 0.2    -- 聚拢动画持续时间
    local SPREAD_DURATION = 0.4    -- 展开动画持续时间

    local cardNums = #sortedCardsList
    -- 聚拢中心
    local gatherCenterPos = Vector3(0,DynamicEffects.cardPosY,0)
    local mainSequence = DOTween.Sequence()

    -- 聚拢动画
    local gatherSequence = DOTween.Sequence()
    gatherSequence:SetEase(Ease.InQuad)

    for _, cardData in ipairs(sortedCardsList) do
        local cardTransform = cardData.cardTransform
        gatherSequence:Join(cardTransform:DOLocalMove(Vector3(gatherCenterPos.x, gatherCenterPos.y, 0), GATHER_DURATION))
    end
    mainSequence:Append(gatherSequence)
    mainSequence:AppendInterval(0.05) -- 聚拢完成后，停顿0.05秒

    -- 展开动画
    local spreadSequence = DOTween.Sequence()
    spreadSequence:SetEase(Ease.OutBack)
    for i, cardData in ipairs(sortedCardsList) do
        local cardTransform = cardData.cardTransform
        local finalPos = DynamicEffects.CalculateFinalCardPosition(i, cardNums)
        print("check 110",finalPos)
        
        spreadSequence:Join(cardTransform:DOLocalMove(finalPos, SPREAD_DURATION))
        cardTransform:SetSiblingIndex(i-1)
    end

    mainSequence:Append(spreadSequence)
    mainSequence:Play()
end

function DynamicEffects.CalculateFinalCardPosition(index, cardNums)
    local midIndex = (cardNums + 1) / 2
    local offsetX = (index - midIndex) * DynamicEffects.microOffsetX
    local finalPos = Vector3(offsetX, DynamicEffects.cardPosY, 0)
    return finalPos
end


function DynamicEffects.CardFromDrawPileToHand(handCntRect,cardList,newCardData)
    local cardNum = #cardList
    if cardNum == 0 then return end
    
    local totalLayoutWidth = (cardNum - 1) * DynamicEffects.cardSpacing + DynamicEffects.cardWidth
    local startX = -totalLayoutWidth / 2 + DynamicEffects.cardWidth / 2

    -- print(string.format("开始布局 %d 张手牌 (直线排列，新牌直接飞入)...", cardNum))

    for i, cardData in ipairs(cardList) do
        local cardTransform = cardData.cardTransform 
        local cardRect = cardTransform:GetComponent(RectTransform)
        local cardImage = cardTransform:GetComponent(Image)
        -- 计算该牌在最终布局中的目标位置 (本地坐标)
        local targetX = startX + (i - 1) * DynamicEffects.cardSpacing
        -- local currentCardStartPos = cardRect.localPosition -- 默认起始点是当前位置
        local animationDuration = 0.4 -- 默认动画时长
        -- *** 区分新旧牌，设置各自的动画起点和图片状态 ***
        if cardData.cardId == newCardData.cardId then
            print("新卡牌")
            -- 如果是新牌：
            -- 1. 动画起点：牌堆的本地位置
            -- cardRect:SetParent(commonPanelRect) -- 暂时设置到共同父级
            -- currentCardStartPos = deckPileRect.localPosition
            -- cardRect.localPosition = currentCardStartPos -- 将新牌的实际位置瞬移到牌堆

            -- 2. 图片：动画开始时显示牌背
            
            cardImage.sprite = DynamicEffects.SetCardImg(cardImage,15,6)
            print("新牌从牌堆开始动画，显示牌背。")

            
            animationDuration = 0.6 -- 新牌的飞入动画可以稍长
            -- initialRotation = CS.UnityEngine.Vector3(0, 0, CS.UnityEngine.Random.Range(-15.0, 15.0)) -- 给新牌一个初始随机旋转
            -- cardRect.localEulerAngles = initialRotation -- 将新牌的实际旋转瞬移到初始旋转
        -- else
        --     -- 如果是旧牌：
        --     -- 1. 动画起点：它当前的位置 (cardRect.localPosition 已经是正确的值)
        --     -- 2. 图片：确保它们已经显示牌面 (如果是旧牌，通常已经显示)
        --     -- 如果有打出后回手的情况，可能需要在这里再次调用 SetCardImg
        --     if cardImage and cardData then
        --         DynamicEffects.SetCardImg(cardImage, cardData.cardType, cardData.cardColor)
        --     end
        end

        -- *** 构建动画 Sequence ***
        local cardSequence = DOTween.Sequence()

        -- 移动动画 (所有牌同时开始，从各自起点到各自目标)
        cardSequence:Append(
            cardRect:DOLocalMove(targetLocalPosition, animationDuration)
                :SetEase(Ease.OutQuad)
        )

        -- 旋转动画 (所有牌同时开始，从各自起点到各自目标)
        -- cardSequence:Join(
        --     cardRect:DOLocalRotate(CS.UnityEngine.Vector3(0, 0, targetRotationZ), animationDuration):SetEase(Ease.OutQuad)
        -- )

        -- *** 新牌的图片揭示逻辑 (只对新牌执行) ***
        if cardData == newCardData then
            local revealTimeOffset = 0.1 -- 动画结束前0.1秒切换图片
            local revealTime = math.max(0, animationDuration - revealTimeOffset) -- 确保时间不为负

            cardSequence:InsertCallback(revealTime, function()
                if cardImage and cardData then
                    DynamicEffects.SetCardImg(cardImage, cardData.cardType, cardData.cardColor)
                    print("新牌动画途中，切换到牌面。")
                end
            end)
        end
        
        -- 动画完成后的回调 (所有牌都会执行，确保最终父对象正确)
        cardSequence:OnComplete(function()
            cardRect:SetParent(handCntRect) -- 最终父对象设置为手牌堆
            cardRect.localPosition =Vector3(cardRect.localPosition.x, cardRect.localPosition.y, 0) 
            -- Z轴可能需要再次精确设置，因为SetParent可能会重置它
        end)
        
        cardSequence:Play()
    end
    print("所有手牌布局动画已触发。")
end




-- 设置卡牌宽度
function DynamicEffects:SetCardWidth(width)
    self.cardWidth = width
end

-- 默认卡牌偏移量
DynamicEffects.fixedOffsetX = 50  -- 固定偏移量（空间足够时使用）
DynamicEffects.minOffsetX = 5    -- 最小偏移量（空间不足时使用）

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

-- 根据手牌容器余量来计算偏移量
function DynamicEffects:CalculateCardOffset(cardCount, handContainer)
    -- 获取 HandContainer 的宽度
    local containerWidth = handContainer:GetComponent(typeof(RectTransform)).rect.width

    -- 计算每张牌需要的总宽度
    local totalWidthNeeded = cardCount * self.fixedOffsetX

    -- 如果总宽度超过容器宽度，则使用自适应偏移量
    local offsetX = self.fixedOffsetX
    if totalWidthNeeded > containerWidth then
        offsetX = math.max(self.minOffsetX, containerWidth / cardCount)
    end
    return offsetX
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
function DynamicEffects:UpdateHandLayout(playerId,playerCardList,handContainer)
    local cardCount = #playerCardList
    if cardCount == 0 then return end  -- 如果没有牌，直接返回

    local offsetX = self:CalculateCardOffset(cardCount, handContainer)

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

function DynamicEffects:AddCardToDiscardPile(cardTransform, discardPile, doScale)
    -- 设置父对象
    cardTransform:SetParent(discardPile.transform)
    
    -- 获取目标位置
    local discardPilePos = discardPile.transform.localPosition
    local newPos = Vector2(discardPilePos.x, discardPilePos.y)
    
    -- 创建动画序列
    local sequence = CS.DG.Tweening.DOTween.Sequence()
    
    -- 1. 移动动画
    sequence:Append(cardTransform:DOAnchorPos(newPos, 0.3)
        :SetEase(CS.DG.Tweening.Ease.InOutQuad))
    
    -- 2. 旋转动画（随机角度）
    
    sequence:Join(cardTransform:DORotate(Vector3(0, 0, DynamicEffects.randomRotation), 0.1)
        :SetEase(CS.DG.Tweening.Ease.InOutQuad))
    
    -- 3. 根据参数决定是否添加缩小动画
    if doScale then
        sequence:Join(cardTransform:DOScale(Vector3(0.8, 0.8, 1), 0.3)
            :SetEase(CS.DG.Tweening.Ease.InOutQuad))
    end
    
    -- 动画完成回调
    sequence:OnComplete(function()
        -- 可以在这里添加动画完成后的逻辑
    end)
    
    return sequence
end

function DynamicEffects:DrawCardToHandContainer(cardTransform, handContainer,location,onCompleteCallBack)
    -- 1. 记录卡牌当前的世界坐标（切换父对象前）
    local worldPos = cardTransform.position
    cardTransform:SetParent(handContainer.transform)
    cardTransform.gameObject:SetActive(true)
     -- 2. 强制重置RectTransform状态（关键！）
     cardTransform.anchorMin = Vector2(0.5, 0)  -- 底部居中锚点
     cardTransform.anchorMax = Vector2(0.5, 0)
     cardTransform.pivot = Vector2(0.5, 0)     -- 轴心点在卡牌底部中心
     cardTransform.anchoredPosition = Vector2(0, 0)  -- 紧贴锚点
    if location == "Left" or location == "Right" then
        print("154")
        cardTransform.localRotation = Quaternion.Euler(0, 0, 0)
        -- cardTransform.rotation = Vector3(0,0,0)
    end
    local handContainerChildCout = handContainer.transform.childCount
    -- local handContainerPos = handContainer.transform.localPosition
    local offset = self:CalculateCardOffset(handContainerChildCout, handContainer)

    -- 如果手牌堆中没有牌，则牌发到手牌堆的中间位置
    local newPos = Vector2.zero
    -- 如果手牌堆中有牌，则发到手牌堆中最右侧牌的右侧
    if handContainerChildCout > 0 then
        local lastCard = handContainer.transform:GetChild(handContainerChildCout - 1)
        -- local lastCardPos = lastCard.localPosition

        newPos = Vector2(lastCard.anchoredPosition.x + offset,0)
        cardTransform:SetAsLastSibling()
    end

    cardTransform:DOAnchorPos(newPos, 0.3)
    :SetEase(CS.DG.Tweening.Ease.InOutQuad)
    :OnComplete(function()
        if onCompleteCallBack then
            onCompleteCallBack()
        end
    end)
end

function DynamicEffects:ShowText(textTransform)
    textTransform.gameObject:SetActive(true)
    textTransform:DOScale(Vector3(2, 2, 1), 1)
    :SetEase(CS.DG.Tweening.Ease.InOutQuad)
    :OnComplete(function()
        textTransform.gameObject:SetActive(false)
    end)
end


local breathTweens = {}
local breathStates = {}
function DynamicEffects:StartBreath(glowImage)
    if glowImage == nil then return end
    if breathStates[glowImage] == true then return end
    

    local color = glowImage.color
    color.a = 0.8
    glowImage.color = color

    if  breathTweens[glowImage] then
        breathTweens[glowImage]:Kill()
        breathTweens[glowImage] = nil
    end

    glowImage.gameObject:SetActive(true)

    local tween = glowImage:DOFade(0,1)
    :SetLoops(-1, CS.DG.Tweening.LoopType.Yoyo)
    :SetAutoKill(false)
    :Play()
    
    breathTweens[glowImage] = tween
    breathStates[glowImage] = true
end

function DynamicEffects:StopBreath(glowImage)
    if glowImage == nil then return end
    if breathTweens[glowImage] == nil then return end
    breathStates[glowImage] = false
    breathTweens[glowImage]:Kill()
    breathTweens[glowImage] = nil
    glowImage.gameObject:SetActive(false)
end

return DynamicEffects



