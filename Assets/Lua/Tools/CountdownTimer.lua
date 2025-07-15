-- CountdownTimer.lua
CountdownTimer = {}

function CountdownTimer.New(name)
    local timer = {
        name = name,
        serverEndTime = nil,-- 服务器结束时间戳
        duration = nil,    
        elapsed = nil, -- 已经过去的时间
        updateElasped = nil, -- 更新间隔
        isRunning = false,
        onUpdate = nil,
        onFinish = nil,
        format = "mm:ss"
    }

    -- 启动计时器
    function timer:StartTimer(endTimeStamp, format)
        self.elapsed = 0
        self.updateElasped = 0
        self.duration = endTimeStamp - os.time()  -- 得到的是秒
        self.serverEndTime = endTimeStamp
        self.isRunning = true
        self.format = format or "mm:ss"

        local initialRemaining = math.max(self.duration, 0)
        local formatted = self:_formatTime(initialRemaining)
        if self.onUpdate then
            self.onUpdate(formatted, math.floor(initialRemaining))
        end
    end

    function timer:Update(dt)
        if not self.isRunning then return end
        self.elapsed = self.elapsed + dt
        self.updateElasped = self.updateElasped + dt
        local remaining = math.max(self.duration - self.elapsed, 0)
        
         -- 触发更新
        if self.onUpdate and self.updateElasped >= 1 then
            self.updateElasped = 0  -- 重置更新间隔
            local formatted = self:_formatTime(math.floor(remaining))
            self.onUpdate(formatted, remaining)
        end

        -- 结束检查
        if remaining <= 0 then
            self.isRunning = false
            if self.onFinish then self.onFinish() end
        end
    end

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