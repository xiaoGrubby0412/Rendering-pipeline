Shader "UnityShaderBook/Chapter6_diffuse_frag"
{
    Properties
    {
        _ColorDiffuse("Diffuse", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            Cull Back
            Tags
            {
                "LightMode" = "ForwardBase"
                "Queue" = "Geometry"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            //漫反射颜色
            fixed4 _ColorDiffuse;
            
            struct a2v
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXTOORD0;
            };

            v2f vert(a2v data)
            {
                v2f r;
                r.pos = UnityObjectToClipPos(data.pos);
                r.worldNormal = mul(data.normal, (float3x3)unity_WorldToObject);
                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //漫反射颜色 灯光颜色 灯光方向 法线方向 环境光颜色
                fixed3 lightColor = _LightColor0.rgb;
                fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 normalWorld = normalize(i.worldNormal);
                fixed3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);
                
                float3 color = _ColorDiffuse.rgb * lightColor * saturate(dot(normalWorld, lightDirWorld));
                //color += ambientColor;
                return fixed4(color.rgb, 1);
            }
            
            ENDCG
        }
    }

    FallBack "Diffuse"

}