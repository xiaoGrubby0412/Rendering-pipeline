Shader "UnityShaderBook/Chapter6_specular_vert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 256)) = 20
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "Queue" = "Geometry" "LightMode" = "ForwardBase"
            }

            Cull Back

            CGPROGRAM
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert;
            #pragma fragment frag;

            struct a2v
            {
                float4 pos : POSITION;
                fixed3 normal : NORMAL;
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

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                //世界坐标下灯光方向 归一化
                fixed3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);
                //世界坐标下法线方向 归一化
                fixed3 worldNormal = normalize(mul(data.normal, (float3x3)unity_WorldToObject));
                //计算漫反射 halfLambert模型
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal, lightDirWorld) * 0.5 + 0.5);

                //计算世界坐标下反射方向
                fixed3 rDir = reflect(-lightDirWorld, worldNormal);
                //计算世界坐标系下视角方向
                float3 posWorld = mul(unity_ObjectToWorld, float4(data.pos.xyz, 1)).xyz;
                //计算视角方向
                fixed3 vDir = normalize(_WorldSpaceCameraPos.xyz - posWorld);
                //halfLambert模型
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(dot(rDir, vDir) * 0.5 + 0.5, _Gloss);
                //Lambert模型
                //specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(rDir, vDir)), _Gloss);
                
                r.color = diffuse + specular;
                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color.rgb, 1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}