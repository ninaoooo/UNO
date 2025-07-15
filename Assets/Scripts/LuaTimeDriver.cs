using UnityEngine;
using XLua;
using System;
public class LuaTimeDriver : MonoBehaviour
{
    public LuaEnv luaEnv;
    public LuaTable updateManager;

    void Start()
    {
        // 加载管理器
        LuaMgr.GetInstance().DoString("require('Base/UpdateTimeMgr')");
        updateManager = LuaMgr.GetInstance().Global.Get<LuaTable>("UpdateTimeMgr");
    }

    void Update()
    {
        var updateFunc = updateManager?.Get<Action<float>>("UpdateTime");
        updateFunc?.Invoke(Time.deltaTime);
    }

    void OnDestroy()
    {
        luaEnv?.Dispose();
    }
}
