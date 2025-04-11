using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
public class HotUpdateWindow: EditorWindow 
{
    
    private string luaModuleName = ""; 
    [MenuItem("Tools/Lua模块热更面板")]
    public static void ShowWindow() {
        var window = GetWindow<HotUpdateWindow>();
        window.Show();
    }

    /// <summary>
    /// Renders the GUI for hot reloading Lua modules.
    /// Displays a button for each loaded Lua module that allows reloading the module at runtime.
    /// Uses the global Lua environment to access the package.loaded table and triggers HotReload function.
    /// </summary>
    void OnGUI() {
        GUILayout.Label("Lua 热更工具", EditorStyles.boldLabel);
        luaModuleName = EditorGUILayout.TextField("模块名", luaModuleName);

        if (GUILayout.Button("热更该 Lua 模块"))
        {
            ReloadLua(luaModuleName);
        }
    }
    private static void ReloadLua(string module)
    {
        UnityEngine.Debug.Log($"[Lua] 热更模块：{module}");
        string reloadCode = $@"
        HotReloadLuaModule.ReloadLuaModule('{module}')";
       UnityEngine.Debug.Log($"[Lua] 代码：{reloadCode}");
        try
        {
            // luaEnv.DoString(reloadCode);
            LuaMgr.GetInstance().DoString(reloadCode);
        }
        catch (System.Exception ex)
        {
            UnityEngine.Debug.LogError($"[Lua 热更失败] {ex.Message}");
        }
    }
}
