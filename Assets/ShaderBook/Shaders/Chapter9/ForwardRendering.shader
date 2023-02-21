Shader "UnityShaderBook/Chapter9/ForwardRendering"
{
    Properties
    {
        _Diffuse("_Diffuse", Color) = (1,1,1,1)
        _Specular("_Specular", Color) = (1,1,1,1)
        _Gloss("_Gloss", Range(20, 100)) = 20
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase" "Queue" = "Geometry"
            }

            CGPROGRAM
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            float3 _Diffuse;
            float3 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v o)
            {
                v2f v;
                v.pos = UnityObjectToClipPos(o.vertex);
                v.worldPos = mul(unity_ObjectToWorld, o.vertex);
                v.worldNormal = UnityObjectToWorldNormal(o.normal);
                return v;
            }

            fixed4 frag(v2f v) : SV_Target
            {
                float3 worldNormal = normalize(v.worldNormal);
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
                float3 halfDir = normalize(worldLightDir + worldViewDir);

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                return fixed4(diffuse.rgb + specular.rgb, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd" "Queue" = "Geometry"
            }
            
            Blend one one
            
            CGPROGRAM

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma  multi_compile_fwdadd

            float3 _Diffuse;
            float3 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v o)
            {
                v2f v;
                v.pos = UnityObjectToClipPos()
            }
            
            
            ENDCG


        }

    }

    Fallback "Diffuse"
}