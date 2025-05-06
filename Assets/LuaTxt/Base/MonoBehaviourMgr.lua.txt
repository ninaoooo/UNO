MonoBehaviourMgr = {}

function MonoBehaviourMgr:Register(module)
    print(module.panelObj)
    print(module.panelObj and module.panelObj.transform)
    local component = module.panelObj.transform:GetComponent(typeof(LuaBehaviour))
    component.luaObject = module
    component.luaStart = module.Start
    component.luaUpdate = module.Update
    component.luaOnDestroy = module.OnDestroy
end