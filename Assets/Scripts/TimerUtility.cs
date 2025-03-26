using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

public class TimerUtility : MonoBehaviour{
    // 单例实例
    private static TimerUtility _instance;
    // 获取计时器实例（属性方式）
    public static TimerUtility Instance{
        get{
            if (_instance == null){
                Initialize();
            }
            return _instance;
        }
    }
    
    //获取计时器实例（函数方式，兼容Lua等）
    public static TimerUtility GetInstance(){
        return Instance; 
    }

    // 初始化单例
    private static void Initialize(){
        _instance = new GameObject("[TimerUtility]").AddComponent<TimerUtility>();
        DontDestroyOnLoad(_instance.gameObject);
    }

    private Dictionary<string, Coroutine> _activeTimers = new Dictionary<string, Coroutine>();

    public void StartTimer(string id, float delay, Action onComplete){
        if (_activeTimers.ContainsKey(id)){
            StopCoroutine(_activeTimers[id]);
            _activeTimers.Remove(id);
        }
        Coroutine timerCoroutine = StartCoroutine(RunTimer(id, delay, onComplete));
        _activeTimers.Add(id, timerCoroutine);
    }

    public void CancelTimer(string id){
        if (_activeTimers.TryGetValue(id, out Coroutine coroutine)){
            StopCoroutine(coroutine);
            _activeTimers.Remove(id);
        }
    }

    public void ClearAllTimers(){
        foreach (var timer in _activeTimers){
            StopCoroutine(timer.Value);
        }
        _activeTimers.Clear();
    }

    private IEnumerator RunTimer(string id, float delay, Action onComplete){
        yield return new WaitForSeconds(delay);
        onComplete?.Invoke();
        if (_activeTimers.ContainsKey(id)){
            _activeTimers.Remove(id);
        }
    }

    private void OnDestroy(){
        ClearAllTimers();
    }
}