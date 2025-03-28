using XLua;
using DG.Tweening;
using System.Collections.Generic;
[LuaCallCSharp]
public static class DOTweenExtention
{
    [LuaCallCSharp]
    public static List<System.Type> LuaCallCSharp = new List<System.Type>
    {
        typeof(DG.Tweening.Tween),
        typeof(DG.Tweening.DOTween),
        typeof(DG.Tweening.Tweener),
        typeof(DG.Tweening.Sequence),

        typeof(DG.Tweening.TweenExtensions),
        typeof(DG.Tweening.ShortcutExtensions),
        typeof(DG.Tweening.TweenSettingsExtensions),

        typeof(DG.Tweening.Core.DOTweenExternalCommand),
        typeof(DG.Tweening.DOTweenModuleUI), // 包含所有UI动画方法
        typeof(DG.Tweening.DOTweenModuleUnityVersion) // 版本兼容
    };
}
