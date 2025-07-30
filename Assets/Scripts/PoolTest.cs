using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoolTest : MonoBehaviour
{
    private MonsterPool monsterPool;
    public string abPackage = "Modes";   // 你的AB包名
    public string prefabName = "snowman-hat";   // 预制体名
    public string poolName = "Monster";      // 池子名字
    public string parentName = "MonsterRoot";   // 场景中挂怪物的空物体名
    public int initCount = 5;                      // 预先生成几个怪物

    private List<GameObject> activeMonsters = new List<GameObject>();

    void Start()
    {
        monsterPool = new MonsterPool();
        monsterPool.InitPool(abPackage, prefabName, poolName, parentName, initCount);
        Debug.Log("Monster pool initialized.");

        // 先从池子里拿几个怪物出来放场景中
        for (int i = 0; i < initCount; i++)
        {
            Vector3 pos = new Vector3(i * 2f, 0, 0); // 横排放
            GameObject monster = monsterPool.Get(poolName, pos);
            activeMonsters.Add(monster);
            Debug.Log($"Spawn monster {i + 1} at {pos}");
        }

    }
}