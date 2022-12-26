Shader "UnityShaderBook/Chapter6_diffuse_frag_halfLambert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
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
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            fixed3 _Diffuse;

            struct a2v
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
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
                //法线
                i.worldNormal = normalize(i.worldNormal);
                //灯光方向
                fixed3 lightDirWorld = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color = _Diffuse.rgb * _LightColor0.rgb * (dot(i.worldNormal, lightDirWorld) * 0.5 + 0.5);
                //color += UNITY_LIGHTMODEL_AMBIENT.rgb;
                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"

}