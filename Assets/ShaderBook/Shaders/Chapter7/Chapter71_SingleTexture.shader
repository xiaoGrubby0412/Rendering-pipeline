Shader "UnityShaderBook/Chapter71_SingleTexture"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "White" {}
        _Color("Color", Color) = (1,1,1,1)
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
            Cull back
            Tags 
            {
                "LightMode" = "ForwardBase"
            }
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v
            {
                float4 pos : POSITION;
                fixed3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v data)
            {
                v2f r;
                r.pos = UnityObjectToClipPos(data.pos);
                r.worldPos = (float3)mul(unity_ObjectToWorld, float4(data.pos.xyz, 1));
                r.worldNormal = UnityObjectToWorldNormal(data.normal);
                r.uv = data.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //世界法线归一
                fixed3 worldNormal = normalize(i.worldNormal);
                //漫反射 纹理采样
                fixed4 col = tex2D(_MainTex, i.uv)* _Color;
                //视角方向
                fixed3 vDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //灯光方向
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * col.rgb * (dot(worldNormal, lightDir) * 0.5 + 0.5) ;
                //计算高光
                fixed3 halfDir = normalize(vDir + lightDir);
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                fixed3 result = diffuse + specular;
                return fixed4(result.rgb, 1);
            }
            
            ENDCG
        }
    }

    FallBack "Diffuse"
}