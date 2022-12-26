Shader "UnityShaderBook/Chapter73RampTexture"
{
    Properties
    {
        _RampTex("RampTex", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", float) = 20
    }

    SubShader
    {
        Tags
        {
            "LightMode" = "ForwardBase"
            "Queue" = "Geometry"
        }
        
        Pass 
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert;
            #pragma fragment frag;

            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Color;
            float4 _Specular;
            float _Gloss;
            
            
            
            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                i.worldNormal = normalize(i.worldNormal);
                float dotValue = dot(worldLightDir, i.worldNormal) * 0.5f + 0.5f;
                fixed4 col = tex2D(_RampTex, fixed2(dotValue, dotValue));
                fixed3 diffuse = _LightColor0.rgb * col.rgb * _Color.rgb;

                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 halfDir = normalize(worldViewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, i.worldNormal)), _Gloss);
                
                return fixed4(diffuse + specular, 1);
            }

            
            ENDCG
        }
    }

    FallBack "Diffuse"
}