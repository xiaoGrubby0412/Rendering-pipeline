Shader "UnityShaderBook/Chapter10/RefractionShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _RefractionColor("RefractionColor", Color) = (1,1,1,1)
        _RefractionRatio("Ratio", Range(0.1,1)) = 0.5
        _RefractionAmount("Amount", Range(0, 1)) = 0.5
        _CubeMap("CubeMap", Cube) = "_Skybox" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
                "RenderQueue" = "Geometry"
            }

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _MainColor;
            float4 _RefractionColor;
            float _RefractionRatio;
            float _RefractionAmount;
            samplerCUBE _CubeMap;

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
                float3 worldViewDir : TEXCOORD2;
                float3 worldLightDir : TEXCOORD3;
                float3 worldRefractionDir : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldLightDir = UnityWorldSpaceLightDir(o.worldPos);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefractionDir = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractionRatio);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.worldNormal = normalize(i.worldNormal);
                i.worldLightDir = normalize(i.worldLightDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * saturate(dot(i.worldNormal, i.worldLightDir));
                fixed3 refractColor = texCUBE(_CubeMap, i.worldRefractionDir) * _RefractionColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                fixed3 color = ambient + lerp(diffuse, refractColor, _RefractionAmount) * atten;
                return fixed4(color, 1);
            }
            
            ENDCG


        }
    }

    FallBack "Reflective/VertexLit"
}