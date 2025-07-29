UpdateTimeMgr = {
    modules = {},
}

function UpdateTimeMgr:Register(module,moudleName)
    if moudleName ~= nil then
        print("[UpdateTimeMgr] Registering module: " .. moudleName.."地址是: "..tostring(module))
    end
    
    table.insert(self.modules, module)
end

function UpdateTimeMgr:Unregister(moduleToRemove)
    -- 从后往前遍历列表，这样在删除元素时不会影响后续的索引
    for i = #self.modules, 1, -1 do
        -- 检查当前模块是否是我们要删除的那个
        if self.modules[i] == moduleToRemove then
            -- 从列表中移除匹配的模块
            table.remove(self.modules, i)
        end
    end
end

function UpdateTimeMgr.UpdateTime(dt)
    for _, m in ipairs(UpdateTimeMgr.modules) do
        if m.UpdateTime then
            m:UpdateTime(dt)
        end
    end
end

