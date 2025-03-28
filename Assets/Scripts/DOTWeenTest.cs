using UnityEngine;
using DG.Tweening;

public class DOTweenTest : MonoBehaviour
{
    public RectTransform targetRectTransform; // 拖拽一个 UI 对象到 Inspector 里
    public Vector2 targetPosition = new Vector2(100, 100);
    public float duration = 1f;

    void Start()
    {
        if (targetRectTransform == null)
        {
            Debug.LogError("请拖拽一个 RectTransform 对象到脚本上！");
            return;
        }

        // 测试 DOAnchorPos 是否可用
        targetRectTransform.DOAnchorPos(targetPosition, duration)
            .SetEase(Ease.InOutQuad)
            .OnComplete(() =>
            {
                Debug.Log("DOTween 动画完成！");
            });
    }
}