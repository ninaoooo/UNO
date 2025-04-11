using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Security.Cryptography;
using System.Text; // 需要添加这个命名空间来使用StringBuilder
using UnityEditor;
public class CreateABCompare
{
    [MenuItem("ABTool/CreateABCompareFile")]
    // 获取文件夹信息
    public static void CreateABCompareFile(){
        DirectoryInfo dir = new DirectoryInfo(Application.dataPath + "/ABPackage/PC/");
        FileInfo[] files = dir.GetFiles();

        string abCompareInfo = "";
        
        foreach (FileInfo info in files)
        {
            if(info.Extension == ""){
                abCompareInfo += info.Name + " " + info.Length + " " +GetMD5Hash(info.FullName) + "\n";
            }
        }
        abCompareInfo = abCompareInfo.Substring(0,abCompareInfo.Length-1);
        Debug.Log(abCompareInfo);
        File.WriteAllText(Application.dataPath + "/ABPackage/PC/abCompare.txt",abCompareInfo);
        AssetDatabase.Refresh();
    }
    private static string GetMD5Hash(string filepath)
    {

        // 检查文件是否存在
        if (!File.Exists(filepath))
        {
            
            Debug.LogError("File not found: " + filepath);
            return string.Empty;
        }
        else{
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
    }
}
