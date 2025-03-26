-- 协程管理器
local CoroutineMgr = {
    coroutines = {} -- 存储所有协程
}

-- 启动协程
function CoroutineMgr:StartCoroutine(func, ...)
    local co = coroutine.create(func)
    table.insert(self.coroutines, co)
    coroutine.resume(co, ...)
end

-- 更新协程
function CoroutineMgr:Update()
    for i = #self.coroutines, 1, -1 do
        local co = self.coroutines[i]
        if coroutine.status(co) ~= "dead" then
            local ok, msg = coroutine.resume(co)
            if not ok then
                print("协程出错: " .. msg)
            end
        else
            table.remove(self.coroutines, i) -- 移除已完成的协程
        end
    end
end

-- 停止所有协程
function CoroutineMgr:StopAllCoroutines()
    self.coroutines = {}
end

-- 停止指定协程
function CoroutineMgr:StopCoroutine(co)
    for i = #self.coroutines, 1, -1 do
        if self.coroutines[i] == co then
            table.remove(self.coroutines, i)
            break
        end
    end
end

return CoroutineMgr