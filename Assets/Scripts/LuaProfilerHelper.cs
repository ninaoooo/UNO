using UnityEngine;
using UnityEngine.Profiling; 


using XLua; 
[LuaCallCSharp] // 这个是xLua的特性，告诉xLua这个类要导出给Lua使用

public static class LuaProfilerHelper
{
    public static void BeginSample(string name)
    {
        Profiler.BeginSample(name);
    }

    public static void EndSample()
    {
        Profiler.EndSample();
    }
}