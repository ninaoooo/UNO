UpdateTimeMgr = {
    modules = {},
}

function UpdateTimeMgr:Register(module,moudleName)
    if moudleName ~= nil then
        print("[UpdateTimeMgr] Registering module: " .. moudleName.."地址是: "..tostring(module))
    end
    
    table.insert(self.modules, module)
end

function UpdateTimeMgr.UpdateTime(dt)
    for _, m in ipairs(UpdateTimeMgr.modules) do
        if m.UpdateTime then
            m:UpdateTime(dt)
        end
    end
end
