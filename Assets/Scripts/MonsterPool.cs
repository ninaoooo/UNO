using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MonsterPool
{
    private Dictionary<string, Queue<GameObject>> poolDict = new Dictionary<string, Queue<GameObject>>();
    public string parentName;
    public GameObject parentObj;

    public void InitPool(string package, string prefabName, string poolName, string parentName, int initCnt){
        if (poolDict.ContainsKey(poolName)) return;
        this.parentName = parentName;
        GameObject prefab = ABMgr.GetInstance().LoadRawRes(package, prefabName) as GameObject;
        Queue<GameObject> q = new Queue<GameObject>();
        this.parentObj = GameObject.Find(this.parentName);
        for(int i = 1;i <= initCnt; i++){
            var obj = GameObject.Instantiate(prefab,this.parentObj.transform);
            MonsterId monsterId = obj.GetComponent<MonsterId>();
            monsterId.id = i;
            obj.SetActive(false);
            q.Enqueue(obj);
        }
        poolDict[poolName] = q;
    }

    public GameObject Get(string poolName,Vector3 pos){
        if (!poolDict.ContainsKey(poolName)) {
            Debug.LogError($"Pool : {poolName} not found");
            return null;
        }
        var q = poolDict[poolName];
        if(q.Count == 0){
            Debug.LogError($"Pool : {poolName} is empty");
        }
        var obj = q.Dequeue();
        obj.transform.position = pos;
        obj.SetActive(true);
        return obj;
    }

    public void Put(string poolName, GameObject obj){
        obj.transform.SetParent(this.parentObj.transform);
        obj.SetActive(false);
        poolDict[poolName].Enqueue(obj);
    }
}
