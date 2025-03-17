/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

using UnityEngine;

using XLua;

[LuaCallCSharp]
public class LuaBehaviour : MonoBehaviour
{

    public LuaFunction luaStart;
    public LuaFunction luaUpdate;
    public LuaFunction luaOnDestroy;
    public LuaTable luaObject;

    // Use this for initialization
    void Start()
    {
        if (luaStart != null && luaObject != null)
        {
            luaStart.Call(luaObject);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (luaUpdate != null && luaObject != null)
        {
            luaUpdate.Call(luaObject);
        }
    }

    void OnDestroy()
    {
        if (luaOnDestroy != null && luaObject != null)
        {
            luaOnDestroy.Call(luaObject);
        }
        luaOnDestroy = null;
        luaUpdate = null;
        luaStart = null;
    }
    void OnCollisionEnter2D(Collision2D other) {
        if (luaObject != null)
        {
            LuaFunction func = luaObject.Get<LuaFunction>("OnCollisionEnter2D");
            if (func != null)
            {
                func.Call(luaObject, other);
            }
        }
    }
}