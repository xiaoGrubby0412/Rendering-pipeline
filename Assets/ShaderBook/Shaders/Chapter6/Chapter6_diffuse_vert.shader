// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShaderBook/Chapter6_diffuse_vert"
{
    Properties
    {
        _ColorDiffuse("Diffuse", Color) = (1,1,1,1)
        _ColorEmission("Emission", Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            Cull back
            Tags
            {
                "LightMode" = "ForwardBase" "Queue" = "Opaque"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _ColorDiffuse; //漫反射 颜色
            float4 _ColorEmission; //自发光 颜色

            struct a2v
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v data)
            {
                v2f r;
                r.pos = UnityObjectToClipPos(data.pos);
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //获取世界坐标系法线 （X 逆转置矩阵）
                fixed3 normalWorld = normalize(mul(data.normal, (float3x3)unity_WorldToObject));
                //获取世界坐标系灯光方向
                fixed3 lightDirWorld = _WorldSpaceLightPos0.xyz;
                //计算 lambert
                fixed3 diffuse = _LightColor0.rgb * _ColorDiffuse.rgb * saturate(dot(normalWorld, lightDirWorld));
                //最终颜色值 = 环境光加上漫反射
                r.color = diffuse;

                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }

    Fallback "diffuse"
}