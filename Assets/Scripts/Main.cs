using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class Main : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        LuaMgr.GetInstance().Init();
        LuaMgr.GetInstance().DoLuaFile("Main");
        DOTween.Init();
    }

    // Update is called once per frame
    void Update()
    {
        LuaMgr.GetInstance().DoString("RpcMgr:RecvAllRpc()");
    }
}
