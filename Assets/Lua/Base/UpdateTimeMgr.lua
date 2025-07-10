UpdateTimeMgr = {
    modules = {}
}

function UpdateTimeMgr:Register(module)
    print("[UpdateTimeMgr] Registering module: " .. tostring(module))
    table.insert(self.modules, module)
end

function UpdateTimeMgr.Update(dt)
    -- print("[UpdateTimeMgr] tick")
    for _, m in ipairs(UpdateTimeMgr.modules) do
        if m.Update then
            m:Update(dt)
        end
    end
end
