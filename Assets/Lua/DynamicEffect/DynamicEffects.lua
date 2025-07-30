DynamicEffects = {}

local DOTween = CS.DG.Tweening.DOTween
local PathType = CS.DG.Tweening.PathType
local PathMode = CS.DG.Tweening.PathMode
local RotateMode = CS.DG.Tweening.RotateMode
local Ease = CS.DG.Tweening.Ease
local Random = CS.UnityEngine.Random

local UnoCardSpriteAltas = ABMgr:LoadRes("UI", "UnoCard")


-- 默认卡牌宽度和间距
DynamicEffects.cardWidth = 160
DynamicEffects.cardSpacing = 30

DynamicEffects.cardLocalPosY = nil
DynamicEffects.targetRotationZ = 0 
DynamicEffects.microOffsetX = 40
DynamicEffects.InitCardCnt = 0
function DynamicEffects.SetCardImg(cardImage,cardType, cardColor)
    local cardString = string.format("card%d_%s", cardType, cardColor)
    cardImage.sprite = UnoCardSpriteAltas:GetSprite(cardString)
end



function DynamicEffects.FirstCardToDiscardPile(cardTransform, discardPile, doScale, cardType, cardColor)
    -- 获取世界坐标
    local discardPilePos = discardPile.transform.position
    local sequence = DOTween.Sequence()
    local cardImage = cardTransform:GetComponent(typeof(Image))
    
    sequence:Append(
        -- 抛物线动画 DOJump(discardPilePos,jumpPower, 1, jumpDuration )
        cardTransform:DOJump(discardPilePos,3, 1, 0.8)
        :SetEase(Ease.OutQuad) -- 落地时减速
        :OnStart(function()
            cardTransform:SetParent(discardPile)
            if cardType and  cardColor then
                DynamicEffects.SetCardImg(cardImage, cardType, cardColor)
            end
            cardTransform:DORotate(Vector3(0, 0, math.random(-30, 30)), 0.1)
                :SetEase(Ease.OutQuad)
            if doScale then
                cardTransform:DOScale(Vector3(0.8, 0.8, 1),0.1)
                :SetEase(Ease.OutQuad)
            end
        end)
    )
end

function DynamicEffects.InitCardFromDrawPileToHand(currentCardCnt,cardTransform,handCntTrans,cardType,cardColor,sortedCardsList)
    local cardImage = cardTransform:GetComponent(typeof(Image))
    DynamicEffects.SetCardImg(cardImage, 15, 6) 
    local handCntPos = handCntTrans.transform.position
    local handCntParent = handCntTrans.transform.parent
    
    -- 根据当前是第几张初始牌来计算偏移,如果有 7 张牌，中心点在第 4 张。
    -- (currentInitialCardCount - 1) 得到的是 0 到 6 的索引
    -- 减去 (GameState.EXPECTED_INITIAL_CARDS - 1) / 2 是为了让中心牌的偏移接近 0
    local offsetX = (currentCardCnt - 1 - (7 - 1) / 2) * DynamicEffects.microOffsetX 
    local worldOffsetX = handCntParent:TransformVector(Vector3(offsetX, 0, 0))
    local targetMidPosition = Vector3(handCntPos.x + worldOffsetX.x,handCntPos.y, handCntPos.z)

    local sequence = DOTween.Sequence()
    sequence:Append(
        cardTransform:DOJump(targetMidPosition, 5, 1, 0.5)
            :SetEase(Ease.OutQuad)
            :OnStart(function ()
                DynamicEffects.SetCardImg(cardImage, cardType, cardColor) 
                cardTransform:SetParent(handCntTrans)
            end)
    )
    sequence:OnComplete(function()
        print(string.format("第 %d 张初始牌飞入动画完成。", currentCardCnt))
        DynamicEffects.InitCardCnt = DynamicEffects.InitCardCnt+1
        if(DynamicEffects.InitCardCnt == 7) then 
            DynamicEffects.OrganizeInitCards(handCntTrans,sortedCardsList)
        end
    end)
end

function DynamicEffects.OrganizeInitCards(handCntTrans,sortedCardsList)
    local GATHER_DURATION = 0.4    -- 聚拢动画持续时间
    local SPREAD_DURATION = 0.4    -- 展开动画持续时间

    local handCntPos = handCntTrans.transform.position
    -- 聚拢中心
    local mainSequence = DOTween.Sequence()

    -- 聚拢动画
    local gatherSequence = DOTween.Sequence()
    gatherSequence:SetEase(Ease.InQuad)

    local cardCnts = handCntTrans.transform.childCount
    for i = 0, cardCnts-1 do
        local cardTransform = handCntTrans.transform:GetChild(i);
        local cardLocalPos = cardTransform.localPosition
        gatherSequence:Join(cardTransform:DOLocalMove(Vector3(0, 0, 0), GATHER_DURATION))
    end
    mainSequence:Append(gatherSequence)
    mainSequence:AppendInterval(0.2) -- 聚拢完成后，停顿

    -- -- 展开动画
    local spreadSequence = DOTween.Sequence()
    spreadSequence:SetEase(Ease.OutBack)

    local cardNums = #sortedCardsList
    for i, cardData in ipairs(sortedCardsList) do
        local cardTransform = cardData.cardTransform
        cardTransform:SetSiblingIndex(i-1)
        local offsetX = DynamicEffects.CalFinalCardOffsetX(i, cardNums)
        local cardLocalPos = cardTransform.localPosition
        spreadSequence:Join(cardTransform:DOLocalMove(Vector3(offsetX,0,0), SPREAD_DURATION))   
    end
    mainSequence:Append(spreadSequence)
    mainSequence:Play()
end

function DynamicEffects.CardFromDrawPileToOtherHand(cardTransform,handCntTrans,toward)
    local cardImage = cardTransform:GetComponent(typeof(Image))
    DynamicEffects.SetCardImg(cardImage, 15, 6) 

    local handCntPos = handCntTrans.transform.position
    local handCntParent = handCntTrans.transform.parent

    local cardCnts = handCntTrans.transform.childCount
    local newCardOffsetX = DynamicEffects.CalFinalCardOffsetX(cardCnts, cardCnts+1)
    local worldOffsetX = handCntParent:TransformVector(Vector3(newCardOffsetX, 0, 0))

    local sequence = DOTween.Sequence()
    sequence:Append(
        cardTransform:DOJump(Vector3(handCntPos.x + worldOffsetX.x, handCntPos.y, 0), 5, 1, 0.5)
        :SetEase(Ease.OutQuad)
        :OnStart(function ()
            cardTransform:SetParent(handCntTrans)
            print("toward",toward)
            if (toward == "Left" or toward == "Right") then
                cardTransform:GetComponent("RectTransform").localRotation = CS.UnityEngine.Quaternion.identity
            end
        end)
    )
    sequence:AppendCallback(function ()
        DynamicEffects.UpdateHandLayout(handCntTrans)
    end)
end

function DynamicEffects.CalFinalCardOffsetX(index, cardNums)
    local midIndex = (cardNums + 1) / 2
    local offsetX = (index - midIndex) * DynamicEffects.microOffsetX
    return offsetX
end


function DynamicEffects.CardFromDrawPileToSelfHand(newCardIndex,newCardData,handCntTrans)
    local cardTransform = newCardData.cardTransform
    local cardImage = cardTransform:GetComponent(typeof(Image))
    DynamicEffects.SetCardImg(cardImage, newCardData.cardType, newCardData.cardColor) 

    local handCntPos = handCntTrans.transform.position
    local handCntParent = handCntTrans.transform.parent

    local cardCnts = handCntTrans.transform.childCount
    local newCardOffsetX = DynamicEffects.CalFinalCardOffsetX(cardCnts, cardCnts+1)
    local worldOffsetX = handCntParent:TransformVector(Vector3(newCardOffsetX, 0, 0))

    local sequence = DOTween.Sequence()
    sequence:Append(
        cardTransform:DOJump(Vector3(handCntPos.x + worldOffsetX.x, handCntPos.y, 0), 5, 1, 0.5)
        :SetEase(Ease.OutQuad)
        :OnStart(function()
            cardTransform:SetParent(handCntTrans)
        end)
    )  
    sequence:AppendCallback(function ()
        cardTransform.transform:SetSiblingIndex(newCardIndex-1)
        DynamicEffects.UpdateHandLayout(handCntTrans)
        end
    )
end

function DynamicEffects.CardFromDrawPileToShow(showTrans, cardTransform, cardType, cardColor)
    local cardImage = cardTransform:GetComponent(typeof(Image))
    DynamicEffects.SetCardImg(cardImage, cardType, cardColor) 

    local showTransPos = showTrans.transform.position

    local sequence = DOTween.Sequence()
    sequence:Append(
        cardTransform:DOJump(Vector3(showTransPos.x-50, showTransPos.y, 0), 5, 1, 0.5)
        :SetEase(Ease.OutQuad)
        :OnStart(function()
            cardTransform:SetParent(showTrans)
            cardTransform:DOScale(Vector3(0.8, 0.8, 1),0.1)
                :SetEase(Ease.OutQuad)
        end)
    )  
end

function DynamicEffects.CardFromShowToDiscardPile(cardTransform,discardPile,cardType,cardColor)
    local discardPilePos = discardPile.transform.position
    local sequence = DOTween.Sequence()
    local cardImage = cardTransform:GetComponent(typeof(Image))
    sequence:Append(
        -- 抛物线动画 DOJump(discardPilePos,jumpPower, 1, jumpDuration )
        cardTransform:DOJump(discardPilePos,3, 1, 0.8)
        :SetEase(Ease.OutQuad) -- 落地时减速
        :OnStart(function ()
            if cardType and cardColor then
                DynamicEffects.SetCardImg(cardImage, cardType, cardColor)
            end
            cardTransform:SetParent(discardPile)
            cardTransform:DORotate(Vector3(0, 0, math.random(-30, 30)), 0.1)
                :SetEase(Ease.OutQuad)
        end)
    )
end

function DynamicEffects.CardFromShowToSelfHand(newCardIndex,newCardData,handCntTrans)
    local cardTransform = newCardData.cardTransform

    local handCntPos = handCntTrans.transform.position
    local handCntParent = handCntTrans.transform.parent

    local cardCnts = handCntTrans.transform.childCount
    local newCardOffsetX = DynamicEffects.CalFinalCardOffsetX(cardCnts, cardCnts+1)
    local worldOffsetX = handCntParent:TransformVector(Vector3(newCardOffsetX, 0, 0))

    local sequence = DOTween.Sequence()
    sequence:Append(
        cardTransform:DOJump(Vector3(handCntPos.x + worldOffsetX.x, handCntPos.y, 0), 5, 1, 0.5)
        :SetEase(Ease.OutQuad)
        :OnStart(function()
            cardTransform:SetParent(handCntTrans)
            cardTransform:DOScale(Vector3(1, 1, 1),0.1)
            :SetEase(Ease.OutQuad)
        end)
    )  
    sequence:AppendCallback(function ()
        cardTransform.transform:SetSiblingIndex(newCardIndex-1)
        DynamicEffects.UpdateHandLayout(handCntTrans)
        end
    )
end
function DynamicEffects.CardFromHandToDiscardPile(cardTransform, handCntTrans, discardPile, doScale, cardType, cardColor)
    -- 获取世界坐标
    local discardPilePos = discardPile.transform.position
    local sequence = DOTween.Sequence()
    local cardImage = cardTransform:GetComponent(typeof(Image))
    
    sequence:Append(
        -- 抛物线动画 DOJump(discardPilePos,jumpPower, 1, jumpDuration )
        cardTransform:DOJump(discardPilePos,3, 1, 0.8)
        :SetEase(Ease.OutQuad) -- 落地时减速
        :OnStart(function ()
            cardTransform:SetParent(discardPile)
            DynamicEffects.UpdateHandLayout(handCntTrans)
            if cardType and  cardColor then
                DynamicEffects.SetCardImg(cardImage, cardType, cardColor)
            end
            if doScale then
                cardTransform:DOScale(Vector3(0.8, 0.8, 1),0.1)
                :SetEase(Ease.OutQuad)
            end
            cardTransform:DORotate(Vector3(0, 0, math.random(-30, 30)), 0.1)
            :SetEase(Ease.OutQuad)
        end)
    )
    -- sequence:InsertCallback(0.3, function()
        
        
    -- end)
end

function DynamicEffects.UpdateHandLayout(handCntTrans)
    local cardCnts = handCntTrans.transform.childCount
    for i = 0, cardCnts-1 do
        local oldCardTrans = handCntTrans.transform:GetChild(i);
        local cardLocalPos = oldCardTrans.localPosition
        local offsetX = DynamicEffects.CalFinalCardOffsetX(i+1, cardCnts)
        oldCardTrans:DOLocalMove(Vector3(offsetX, 0, 0), 0.3)
            :SetEase(Ease.OutQuad)
    end
end

-- 手牌被选中后 往上移动20个单位
function DynamicEffects.SelectCard(cardTransform)
    local currentPosition = cardTransform.localPosition
    cardTransform.localPosition = Vector3(currentPosition.x, currentPosition.y + 20, currentPosition.z)
end

-- 取消选中状态 手牌恢复原始位置
function DynamicEffects.ResetCard(cardTransform)
    local currentPosition = cardTransform.localPosition
    cardTransform.localPosition = Vector3(currentPosition.x, currentPosition.y - 20, currentPosition.z)
end

function DynamicEffects.SelfDropCardToDiscardPile(cardTransform, discardPile, doScale, cardType, cardColor)
    
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
function DynamicEffects:UpdateHandLayout1(playerId,playerCardList,handContainer)
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
    
    sequence:Join(cardTransform:DORotate(Vector3(0, 0, math.random(-30, 30)), 0.1)
        :SetEase(CS.DG.Tweening.Ease.InOutQuad))
    
    -- 3. 根据参数决定是否添加缩小动画
    if doScale then
        sequence:Join(cardTransform:DOScale(Vector3(0.8, 0.8, 1), 0.1)
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



