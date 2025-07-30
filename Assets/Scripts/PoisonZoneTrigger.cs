using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoisonZoneTrigger : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("玩家进入毒圈内");
            // 通知Lua停止掉血
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("玩家进入毒圈外");
            // 通知Lua开始掉血
        }
    }
}
