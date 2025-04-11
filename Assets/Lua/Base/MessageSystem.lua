MessageSystem = {}

local listeners = {}

function MessageSystem.RegisterListener(message, callback)
    if not listeners[message] then
        listeners[message] = {}  -- 内层表不使用弱引用！
    end
    listeners[message][callback] = true
end

-- 移除监听器
function MessageSystem.RemoveListener(message, callback)
    if listeners[message] then
        listeners[message][callback] = nil
    end
end

-- 事件分发
function MessageSystem.Dispatch(message, ...)
    if listeners[message] then
        local count = 0
        for _ in pairs(listeners[message]) do count = count + 1 end
        print("[Dispatch] 当前监听器数量:", count)  -- 现在会显示真实数量
        for callback in pairs(listeners[message]) do
            print("[Dispatch] 执行监听器:", tostring(callback))
            local ok, err = pcall(callback, ...)
            if not ok then
                print("MessageSystem Error:", err)
            end
        end
    else
        print("[Dispatch] 未找到监听器:", message)
    end
end

return MessageSystem