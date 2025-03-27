using UnityEngine;
using System.Collections.Generic;

public class AudioMgr : MonoBehaviour
{
    private static AudioMgr _instance;
    private AudioSource musicSource; // 背景音乐
    private AudioSource soundSource; // 音效
    private Dictionary<string, AudioClip> audioCache = new Dictionary<string, AudioClip>(); // 音频缓存

    public static AudioMgr GetInstance()
    {
        if (_instance == null)
        {
            _instance = FindObjectOfType<AudioMgr>();
            if (_instance == null){
                GameObject obj = new GameObject("AudioManager");
                _instance = obj.AddComponent<AudioMgr>();
                DontDestroyOnLoad(obj);
            }
        }
        return _instance;
    }

    private void Awake()
    {
        // 创建两个 AudioSource 组件
        musicSource = gameObject.AddComponent<AudioSource>();
        musicSource.loop = true; // 背景音乐循环播放

        soundSource = gameObject.AddComponent<AudioSource>();
        soundSource.loop = false; // 音效单次播放
    }


    // 从 ABMgr 异步加载音频
    public void LoadAudio(string clipName, string abName, System.Action<AudioClip> callback)
    {
        if (audioCache.TryGetValue(clipName, out AudioClip cachedClip))
        {
            callback?.Invoke(cachedClip); //  直接使用缓存
            Debug.Log("使用缓存的Aduio");
        }
        else
        {
            //  从 ABMgr 加载（异步）
            ABMgr.GetInstance().LoadResAsync<AudioClip>(abName, clipName, (clip) =>
            {
                if (clip != null)
                {
                    audioCache[clipName] = clip; // 存入缓存
                    callback?.Invoke(clip); //  加载完成后自动播放
                }
            });
        }
    }


    // 播放背景音乐（优先使用缓存）
    public void PlayMusic(string abName,string clipName, bool loop = true)
    {
        LoadAudio(clipName, abName, (clip) =>
        {
            musicSource.clip = clip;
            musicSource.loop = loop;
            musicSource.Play();
        });
    }


    /// 播放音效（优先使用缓存）
    public void PlaySound(string abName,string clipName)
    {
        LoadAudio(clipName, abName, (clip) =>
        {
            soundSource.PlayOneShot(clip);
        });
    }


    /// 设置背景音乐音量
    public void SetMusicVolume(float volume)
    {
        musicSource.volume = Mathf.Clamp01(volume); // 限制范围 0~1
    }

    /// 设置音效音量
    public void SetSoundVolume(float volume)
    {
        soundSource.volume = Mathf.Clamp01(volume);
    }

    /// 暂停背景音乐
    public void PauseMusic()
    {
        musicSource.Pause();
    }


    /// 恢复背景音乐
    public void ResumeMusic()
    {
        musicSource.UnPause();
    }

    /// 停止背景音乐
    public void StopMusic()
    {
        musicSource.Stop();
    }

    /// 音乐静音
    public void MuteMusic(bool mute)
    {
        musicSource.mute = mute;
    }

    // 音效静音
    public void MuteSound(bool mute){
        soundSource.mute = mute;
    }
}
