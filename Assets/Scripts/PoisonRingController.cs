using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PoisonRingController : MonoBehaviour
{
    public float shrinkDuration = 20f;    // 缩圈时间
    public float endScale = 0.1f;         // 缩到多小

    private float timer = 0f;
    private float startScale;             // 起始大小动态计算

    void Start()
    {
        // 获取当前球体在世界空间的最大尺寸（x,z方向）
        Renderer rend = GetComponent<Renderer>();
        if (rend != null)
        {
            Vector3 size = rend.bounds.size;
            // 取x和z轴最大尺寸作为直径
            startScale = Mathf.Max(size.x, size.z);
        }
        else
        {
            Debug.LogWarning("没有找到Renderer组件，使用默认起始大小1");
            startScale = 1f;
        }

        // 设置初始缩放，使球体大小为startScale
        // 这里假设球体原始尺寸是1，所以直接设置为startScale
        transform.localScale = Vector3.one * startScale;
    }

    void Update()
    {
        if (timer < shrinkDuration)
        {
            timer += Time.deltaTime;
            float t = timer / shrinkDuration;
            // 缩放从startScale变到endScale
            float scale = Mathf.Lerp(startScale, endScale, t);
            transform.localScale = Vector3.one * scale;
        }
    }
}

