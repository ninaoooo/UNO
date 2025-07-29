DEPreMatch = {
    slots = {},     
    cardHeight = 200,
    scrollTime = 0.5,
    rollingCoroutine = nil,
    timer = 0,
    _rolling = false,
}

UpdateTimeMgr:Register(DEPreMatch,"DEPreMatch")

function DEPreMatch:ScrollOnce()
    for _, slot in ipairs(self.slots) do
        slot.CardB.gameObject:SetActive(true)
        local curCard = slot.isAActive and slot.CardA or slot.CardB
        local nextCard = slot.isAActive and slot.CardB or slot.CardA

        curCard:DOAnchorPosY(self.cardHeight, self.scrollTime)
        nextCard:DOAnchorPosY(0, self.scrollTime):OnComplete(function()
            curCard.anchoredPosition = Vector2(0, -self.cardHeight)
            slot.isAActive = not slot.isAActive
        end)
    end
end

function DEPreMatch:StartRolling()
    self._rolling = true
    -- 启动新协程循环滚动
    self.rollingCoroutine = coroutine.create(function()
        while self._rolling do
            self:ScrollOnce()
            coroutine.yield()
        end
    end)
end

function DEPreMatch:StopRolling()
    self._rolling = false
    for _, slot in ipairs(self.slots) do
        CS.DG.Tweening.DOTween.Kill(slot.CardA, false)
        CS.DG.Tweening.DOTween.Kill(slot.CardB, false)

        slot.CardA:GetComponent(typeof(RectTransform)).anchoredPosition = Vector2(0, 0)
        slot.CardB:GetComponent(typeof(RectTransform)).anchoredPosition = Vector2(0, -self.cardHeight)
        print(slot.CardA, slot.CardA:GetComponent(typeof(RectTransform)))

        slot.CardB.gameObject:SetActive(false)
    end
end

function DEPreMatch:TestScroll()
    self:ScrollOnce()
end

function DEPreMatch:UpdateTime(dt)
    if not self._rolling then return end

    self.timer = self.timer + dt
    if self.timer > self.scrollTime then
        self.timer = 0
        if self.rollingCoroutine and coroutine.status(self.rollingCoroutine) == "suspended" then
            local ok, err = coroutine.resume(self.rollingCoroutine)
            if not ok then
                print("[DEPreMatch] 协程 resume 错误:", err)
            end
        end
    end
end

function DEPreMatch:Destory()
    UpdateTimeMgr:Unregister(DEPreMatch)
    self.rollingCoroutine = nil
end