Shader "UnityShaderBook/Chapter6_specular_frag"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 256)) = 20
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            Cull Back

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            #pragma vertex vert;
            #pragma fragment frag;

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v data)
            {
                v2f r;
                r.pos = UnityObjectToClipPos(data.pos);
                r.worldNormal  = mul(data.normal, (float3x3)unity_WorldToObject);
                r.worldPos = mul(unity_ObjectToWorld, float4(data.pos.xyz, 1)).xyz;
                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                //世界法线归一
                fixed3 worldNormal = normalize(i.worldNormal);
                //灯光方向归一
                fixed3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);
                
                //计算漫反射颜色
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, lightDirWorld));
                
                //反射方向
                fixed3 rDir = normalize(reflect(-lightDirWorld, worldNormal));
                //视角方向
                fixed3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //计算高光颜色
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(rDir, vDir)), _Gloss);
                fixed3 col = diffuse + specular;
                
                return fixed4(col.rgb, 1);
                
            }
            
            ENDCG
        }
    }

    FallBack "Diffuse"
}