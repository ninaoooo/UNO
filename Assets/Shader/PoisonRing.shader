Shader "Shader/PoisonRing"
{
    // 可以在unity面板中显示的材质属性，供你在面板上操作这些数值
    Properties
    {
        _Color ("Color", Color) = (0.2, 0.8, 1.0, 1.0)
        _Radius ("Radius", Float) = 3.0
        _Thickness ("Thickness", Float) = 0.05 //边缘模糊
        _PulseSpeed ("Pulse Speed", Float) = 3.0 // 闪烁速度
        _EnablePulse ("Enable Pulse", Float) = 0.0 //是否开启闪烁（1开启，0关闭）
    }
    SubShader
    {
        //告诉 Unity 这是一个透明材质，放到渲染队列较后的位置（不写会挡住地面等）
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        // Shader渲染的内容写在这里
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha //开启透明混合
            ZWrite Off //不写入深度缓冲区 防止遮挡
            Cull Off //不剔除背面

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            float _Radius;
            float _Thickness;
            float _PulseSpeed;
            float _EnablePulse;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2 - 1;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float dist = length(i.uv);
                float edge = smoothstep(_Radius + _Thickness, _Radius, dist);
                
                // 计算闪烁强度，范围[0.7,1.0]
                float pulse = 1.0;
                if (_EnablePulse > 0.5) {
                    pulse = 0.7 + 0.3 * (sin(_Time.y * _PulseSpeed) * 0.5 + 0.5);
                }

                fixed3 colorPulse = _Color.rgb * pulse;
                return fixed4(colorPulse, edge * _Color.a * pulse);
            }
            ENDCG
        }
    }
}
