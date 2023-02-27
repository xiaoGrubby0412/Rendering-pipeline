Shader "UnityShaderBook/Chapter10/ReflectionShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        _ReflectColor("ReflectColor", Color) = (1,1,1,1)
        _ReflectAmount("ReflectAmount", Range(0, 1)) = 0.5
        _Cubemap("Cubemap", Cube) = "_Skybox" {}
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
                "Queue" = "Geometry"
            }

            CGPROGRAM
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            float4 _MainColor;
            float4 _ReflectColor;
            float _ReflectAmount;
            samplerCUBE _Cubemap;
            
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
                float3 worldReflectDir : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldLightDir = UnityWorldSpaceLightDir(o.worldPos);
                o.worldReflectDir = reflect(-o.worldViewDir, o.worldNormal);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //i.worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 reflectColor = texCUBE(_Cubemap, i.worldReflectDir) * _ReflectColor.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                i.worldNormal = normalize(i.worldNormal);
                i.worldLightDir = normalize(i.worldLightDir);
                float3 diffuse = _LightColor0.rgb * _MainColor.rgb * saturate(dot(i.worldNormal, i.worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                diffuse = ambient + lerp(diffuse, reflectColor, _ReflectAmount) * atten;
                return fixed4(diffuse, 1);
            }

            
            
            ENDCG
        }
    }
    
    FallBack "Reflective/VertexLit"
}