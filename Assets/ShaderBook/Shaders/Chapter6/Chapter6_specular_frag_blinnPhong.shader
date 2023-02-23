Shader "UnityShaderBook/Chapter6_specular_frag_blinnPhong"
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
            Cull Back
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0; //世界法线
                fixed3 worldPos : TEXCOORD1; //世界坐标
            };

            v2f vert(a2v data)
            {
                v2f r;
                r.pos = UnityObjectToClipPos(data.vertex);
                r.worldPos = mul(unity_ObjectToWorld, fixed4(data.vertex.xyz, 1));
                r.worldNormal = mul(data.normal, (float3x3)unity_WorldToObject);

                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //世界灯光归一
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //世界法线归一
                fixed3 normal = normalize(i.worldNormal);
                // //反射方向归一
                // fixed3 rDir = normalize(reflect(-lightDir, normal));
                //视角方向归一
                fixed3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 blinnPhongDir = normalize(lightDir + vDir);

                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, normal));

                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(blinnPhongDir, normal)), _Gloss);

                fixed3 col = diffuse + specular;
                return fixed4(col.rgb, 1);
            }
            
            ENDCG
        }
    }

    FallBack "Diffuse"
}