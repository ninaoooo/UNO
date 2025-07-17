-- 顶部导入 (确保所有必要的 CS.UnityEngine 模块已导入)
local Vector3 = CS.UnityEngine.Vector3
local RectTransform = CS.UnityEngine.RectTransform 
local Ease = CS.DG.Tweening.Ease
local DOTween = CS.DG.Tweening.DOTween
local Image = CS.UnityEngine.UI.Image 
local Mathf = CS.UnityEngine.Mathf -- 如果是扇形布局，需要 Mathf

--- 统一处理手牌布局和动画。
--- 新牌直接从牌堆飞入到最终位置，旧牌同时挪动。
--- @param handPileRect UnityEngine.RectTransform 该玩家手牌堆的RectTransform
--- @param sortedCardDataList table<any> 已经根据游戏规则排序好的所有手牌数据列表 (包含新牌和旧牌)
--- @param deckPileRect UnityEngine.RectTransform 牌堆的RectTransform，用于新牌的起始点
--- @param commonPanelRect UnityEngine.RectTransform 共同Panel的RectTransform
--- @param newCardData table 可选参数：刚刚加入的新卡牌数据，用于识别其动画起点和图片设置
function HandManager.CalculateAndLayoutHandCards(handPileRect, sortedCardDataList, deckPileRect, commonPanelRect, newCardData)
    local numCards = #sortedCardDataList
    if numCards == 0 then
        print("手牌为空，无需布局。")
        -- 此时可以隐藏手牌堆的视觉效果等
        return
    end

    -- === 布局参数 (这里以直线排列为例，如果你需要扇形，请替换为扇形计算逻辑) ===
    local cardWidth = 100        
    local cardSpacing = 70       
    local verticalY = 0          
    local targetRotationZ = 0    

    local totalLayoutWidth = (numCards - 1) * cardSpacing + cardWidth
    local startX = -totalLayoutWidth / 2 + cardWidth / 2

    print(string.format("开始布局 %d 张手牌 (直线排列，新牌直接飞入)...", numCards))

    for i, cardData in ipairs(sortedCardDataList) do
        local cardTransform = cardData.cardTransform 
        if cardTransform == nil then
            print("Error: 布局时 cardData 中缺少 cardTransform。")
            continue
        end
        local cardRect = cardTransform:GetComponent(CS.UnityEngine.RectTransform)
        local cardImage = cardTransform:GetComponent(Image)

        -- 计算该牌在最终布局中的目标位置 (本地坐标)
        local targetX = startX + (i - 1) * cardSpacing
        local targetZ = -(i - 1) * 0.01 
        local targetLocalPosition = CS.UnityEngine.Vector3(targetX, verticalY, targetZ)

        local currentCardStartPos = cardRect.localPosition -- 默认起始点是当前位置
        local animationDuration = 0.4 -- 默认动画时长
        local initialRotation = cardRect.localEulerAngles -- 默认起始旋转

        -- *** 区分新旧牌，设置各自的动画起点和图片状态 ***
        if cardData == newCardData then
            -- 如果是新牌：
            -- 1. 动画起点：牌堆的本地位置
            cardRect:SetParent(commonPanelRect) -- 暂时设置到共同父级
            currentCardStartPos = deckPileRect.localPosition
            cardRect.localPosition = currentCardStartPos -- 将新牌的实际位置瞬移到牌堆

            -- 2. 图片：动画开始时显示牌背
            if cardImage then
                cardImage.sprite = DynamicEffects.GetCardBackSprite()
                print("新牌从牌堆开始动画，显示牌背。")
            end
            
            animationDuration = 0.6 -- 新牌的飞入动画可以稍长
            initialRotation = CS.UnityEngine.Vector3(0, 0, CS.UnityEngine.Random.Range(-15.0, 15.0)) -- 给新牌一个初始随机旋转
            cardRect.localEulerAngles = initialRotation -- 将新牌的实际旋转瞬移到初始旋转
        else
            -- 如果是旧牌：
            -- 1. 动画起点：它当前的位置 (cardRect.localPosition 已经是正确的值)
            -- 2. 图片：确保它们已经显示牌面 (如果是旧牌，通常已经显示)
            -- 如果有打出后回手的情况，可能需要在这里再次调用 SetCardImg
            if cardImage and cardData then
                DynamicEffects.SetCardImg(cardImage, cardData.cardType, cardData.cardColor)
            end
        end

        -- *** 构建动画 Sequence ***
        local cardSequence = DOTween.Sequence()

        -- 移动动画 (所有牌同时开始，从各自起点到各自目标)
        cardSequence:Append(
            cardRect:DOLocalMove(targetLocalPosition, animationDuration)
                :SetEase(Ease.OutQuad)
        )

        -- 旋转动画 (所有牌同时开始，从各自起点到各自目标)
        cardSequence:Join(
            cardRect:DOLocalRotate(CS.UnityEngine.Vector3(0, 0, targetRotationZ), animationDuration):SetEase(Ease.OutQuad)
        )

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
            cardRect:SetParent(handPileRect) -- 最终父对象设置为手牌堆
            cardRect.localPosition = CS.UnityEngine.Vector3(cardRect.localPosition.x, cardRect.localPosition.y, targetZ) 
            -- Z轴可能需要再次精确设置，因为SetParent可能会重置它
        end)
        
        cardSequence:Play()
    end
    print("所有手牌布局动画已触发。")
end