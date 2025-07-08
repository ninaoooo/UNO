using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using XLua;
public class Main : MonoBehaviour
{
    // Start is called before the first frame update
    private LuaTable rpcMgrTable;
    private LuaFunction recvAllRpcFunc;
    void Start()
    {
        LuaMgr.GetInstance().Init();
        LuaMgr.GetInstance().DoLuaFile("Main");
        DOTween.Init();
        rpcMgrTable = LuaMgr.GetInstance().Global.Get<LuaTable>("RpcMgr");
        if (rpcMgrTable != null)
            recvAllRpcFunc = rpcMgrTable.Get<LuaFunction>("RecvAllRpc");
    }

    // Update is called once per frame
    void Update()
    {
        // LuaMgr.GetInstance().DoString("RpcMgr:RecvAllRpc()");
        if(recvAllRpcFunc != null)
            recvAllRpcFunc.Call(rpcMgrTable);
    }
}
