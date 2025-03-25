using UnityEngine;
using System;

public class ABInspector : MonoBehaviour
{
    void Start()
    {
        // 加载AB包
        AssetBundle ab = AssetBundle.LoadFromFile(Application.streamingAssetsPath + "/lua.ab");
        Debug.Log("StreamingAssets 路径: " + Application.streamingAssetsPath);
        string path = Application.streamingAssetsPath + "/lua.ab";
        Debug.Log("AB包路径: " + path);
        if (ab == null)
        {
            Debug.LogError("AB包加载失败");
            return;
        }

        // 获取AB包中的所有文件路径
        string[] assetNames = ab.GetAllAssetNames();
        foreach (string name in assetNames)
        {
            Debug.Log("AB包中的文件路径: " + name);
        }

        // 释放AB包
        ab.Unload(false);
    }
}