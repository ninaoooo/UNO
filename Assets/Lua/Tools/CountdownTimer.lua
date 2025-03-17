-- CountdownTimer.lua
CountdownTimer = {}

-- 创建支持时间戳的计时器
function CountdownTimer.New()
    local timer = {
        endTimestamp = 0,  -- 服务器给的结束时间戳（秒）
        isRunning = false,
        onUpdate = nil,
        onFinish = nil,
        format = "mm:ss"
    }
    
    -- 启动计时器（参数为服务器给的结束时间戳）
    function timer:Start(endTimeStamp,format)
        self.endTimestamp = endTimeStamp
        self.isRunning = true
        self.format = format or "mm:ss"
        self:_updateTime()
    end
    
    -- 每帧更新
    function timer:Update()
        if not self.isRunning then return end
        self:_updateTime()
    end
    
    -- 计算剩余时间（核心方法）
    function timer:_updateTime()
        local now = os.time()  -- 获取客户端当前时间戳
        local remaining = self.endTimestamp - now

        -- 强制触发一次更新，即使剩余时间为 0
        if self.onUpdate then
            local formattedTime = self:_formatTime(math.max(remaining, 0))  -- 确保剩余时间不小于 0
            self.onUpdate(formattedTime)
        end
        
        -- 时间已到
        if remaining <= 0 then
            self.isRunning = false
            if self.onFinish then self.onFinish() end
            return
        end
        
        -- 更新显示
        -- if self.onUpdate then
        --     local formattedTime = self:_formatTime(remaining)
        --     self.onUpdate(formattedTime)
        -- end
    end

    -- 格式化时间
    function timer:_formatTime(seconds)
        if self.format == "ss" then
            return tostring(seconds)  -- 仅显示秒
        else
            local mins = math.floor(seconds / 60)
            local secs = seconds % 60
            return string.format("%02d:%02d", mins, secs)  -- 显示分:秒
        end
    end
    
    return timer
end