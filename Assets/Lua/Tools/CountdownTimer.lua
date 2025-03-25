-- CountdownTimer.lua
CountdownTimer = {}

function CountdownTimer.New()
    local timer = {
        serverEndTime = 0,    -- 服务器结束时间戳
        isRunning = false,
        onUpdate = nil,
        onFinish = nil,
        format = "mm:ss"
    }

    -- 启动计时器
    function timer:Start(endTimeStamp, format)
        self.serverEndTime = endTimeStamp
        self.isRunning = true
        self.format = format or "mm:ss"
        self:_update()  -- 立即触发首次更新
    end

    -- 每帧更新（无需参数）
    function timer:Update()
        if not self.isRunning then return end
        self:_update()
    end

    -- 核心逻辑：实时计算剩余时间
    function timer:_update()
        local now = os.time()
        local remaining = self.serverEndTime - now
        remaining = math.max(remaining, 0)

        -- 触发更新
        if self.onUpdate then
            local formatted = self:_formatTime(remaining)
            self.onUpdate(formatted, remaining)
        end

        -- 结束检查
        if remaining <= 0 then
            self.isRunning = false
            if self.onFinish then self.onFinish() end
        end
    end

    -- 格式化方法（保持不变）
    function timer:_formatTime(seconds)
        if self.format == "ss" then
            return tostring(seconds)
        else
            local mins = math.floor(seconds / 60)
            local secs = seconds % 60
            return string.format("%02d:%02d", mins, secs)
        end
    end

    return timer
end