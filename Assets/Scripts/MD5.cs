using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Security.Cryptography;
using System.Text; // 需要添加这个命名空间来使用StringBuilder

public class MD5Utility : MonoBehaviour
{
    void Update()
    {
        print(GetMD5Hash(Application.streamingAssetsPath + "/lua"));
    }

    private string GetMD5Hash(string filepath)
    {
        try
        {
            // 检查文件是否存在
            if (!File.Exists(filepath))
            {
                Debug.LogError("File not found: " + filepath);
                return string.Empty;
            }

            // 将文件以流的形式打开
            using (FileStream file = new FileStream(filepath, FileMode.Open))
            using (System.Security.Cryptography.MD5 md5 = System.Security.Cryptography.MD5.Create())
            {
                byte[] md5Info = md5.ComputeHash(file);
                StringBuilder sb = new StringBuilder();
                foreach (byte b in md5Info)
                {
                    sb.Append(b.ToString("x2"));
                }
                return sb.ToString();
            }
        }
        catch (System.Exception e)
        {
            Debug.LogError("Error calculating MD5 hash: " + e.Message);
            return string.Empty;
        }
    }
}