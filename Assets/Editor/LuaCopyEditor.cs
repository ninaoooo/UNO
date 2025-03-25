using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.IO;

public class LuaCopyEditor : Editor
{
    [MenuItem("XLua/CopyLuaToTxt")]
    public static void CopyLuaToTxt()
    {
        // 源文件夹路径
        string sourcePath = Path.Combine(Application.dataPath, "Lua");
        if (!Directory.Exists(sourcePath))
        {
            Debug.LogError($"Source directory does not exist: {sourcePath}");
            return;
        }

        // 目标文件夹路径
        string targetPath = Path.Combine(Application.dataPath, "LuaTxt");
        if (!Directory.Exists(targetPath))
        {
            Directory.CreateDirectory(targetPath);
        }
        else
        {
            // 清空目标文件夹
            ClearDirectory(targetPath);
        }

        // 获取所有 Lua 文件
        string[] sourceFiles = Directory.GetFiles(sourcePath, "*.lua", SearchOption.AllDirectories);
        List<string> targetFiles = new List<string>();

        // 复制并重命名文件，保留文件夹结构
        foreach (string sourceFile in sourceFiles)
        {
            // 获取相对路径（相对于 sourcePath）
            string relativePath = Path.GetRelativePath(sourcePath, sourceFile);

            // 构建目标文件路径
            string targetFile = Path.Combine(targetPath, relativePath) + ".txt"; // 添加 .txt 后缀

            // 确保目标文件夹存在
            string targetDir = Path.GetDirectoryName(targetFile);
            if (!Directory.Exists(targetDir))
            {
                Directory.CreateDirectory(targetDir);
            }

            try
            {
                File.Copy(sourceFile, targetFile);
                targetFiles.Add(targetFile);
            }
            catch (System.Exception ex)
            {
                Debug.LogError($"Failed to copy file: {sourceFile}. Error: {ex.Message}");
            }
        }

        // 刷新 AssetDatabase
        AssetDatabase.Refresh();

        // 将 LuaTxt 文件夹标记为 lua AssetBundle
        // 将 LuaTxt 文件夹整体标记为 lua AssetBundle
        string targetRelativePath = "Assets" + targetPath.Substring(Application.dataPath.Length);
        AssetImporter importer = AssetImporter.GetAtPath(targetRelativePath);
        if (importer != null)
        {
            importer.assetBundleName = "lua";
            Debug.Log($"Set AssetBundleName for folder: {targetRelativePath}");
        }
        else
        {
            Debug.LogError($"Failed to get AssetImporter for folder: {targetRelativePath}");
        }

        Debug.Log("Lua files copied and renamed successfully!");

    }



    /// <summary>
    /// 清空文件夹中的所有文件和子文件夹
    /// </summary>
    private static void ClearDirectory(string path)
    {
        foreach (string file in Directory.GetFiles(path))
        {
            File.Delete(file);
        }

        foreach (string dir in Directory.GetDirectories(path))
        {
            Directory.Delete(dir, true);
        }
    }
}