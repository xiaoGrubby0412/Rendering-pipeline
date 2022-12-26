Shader "UnityShaderBook/Chapter8_4_AlphaBlendZWrite"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _AlphaScale("AlphaScale", Range(0, 1)) = 1
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(0, 100)) = 20
        _BumpMap("BumpMap", 2D) = "normal" {}
        _BumpScale("BumpScale", float) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        Pass
        {
            ZWrite On
            ColorMask 0
//            Tags
//            {
//                "LightMode" = "ForwardBase"
//            }
        }
        
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Color;
            float _AlphaScale;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _BumpMap;
            float _BumpScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float3 TtoW0 : TEXCOORD3;
                float3 TtoW1 : TEXCOORD4;
                float3 TtoW2 : TEXCOORD5;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                //法线
                float3 binormal = cross(normalize(v.normal.xyz), normalize(v.tangent.xyz)) * v.tangent.w;
                //转换为切线到世界
                float3 tangentToWorld_Tangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
                float3 tangentToWorld_Binormal = mul((float3x3)unity_ObjectToWorld, binormal);
                float3 tangentToWorld_Normal = mul((float3x3)unity_ObjectToWorld, v.normal.xyz);
                
                //由于只能在像素着色器中采样贴图 所以必须构造切线到世界的矩阵传递过去 然后从那边采样出切线空间下的法线纹理 然后和这个矩阵相乘 转化为世界坐标系下的法线 欧耶！！！！！
                o.TtoW0 = float3(tangentToWorld_Tangent.x, tangentToWorld_Binormal.x, tangentToWorld_Normal.x);
                o.TtoW1 = float3(tangentToWorld_Tangent.y, tangentToWorld_Binormal.y, tangentToWorld_Normal.y);
                o.TtoW2 = float3(tangentToWorld_Tangent.z, tangentToWorld_Binormal.z, tangentToWorld_Normal.z);

    //             fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				// fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				// fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				//
				// // Compute the matrix that transform directions from tangent space to world space
				// // Put the world position in w component for optimization
				// o.TtoW0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
				// o.TtoW1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
				// o.TtoW2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //法线贴图
                fixed4 packedNormal = tex2D(_BumpMap, i.uv);
                //切线空间下的法线
                fixed3 normalTangent = UnpackNormal(packedNormal);
                normalTangent.xy *= _BumpScale;
                normalTangent.z = sqrt(1 - saturate(dot(normalTangent.xy, normalTangent.xy)));
                fixed3 bump = normalize(fixed3(dot(i.TtoW0, normalTangent), dot(i.TtoW1, normalTangent), dot(i.TtoW2, normalTangent)));

    //             // Get the normal in tangent space
				// fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				// bump.xy *= _BumpScale;
				// bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				// // Transform the narmal from tangent space to world space
				// bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                
                //世界灯光方向
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                // //世界法线归一
                // fixed3 worldNormal = normalize(i.worldNormal);
                
                //UV 采样
                fixed4 albedo = tex2D(_MainTex, i.uv);
                fixed3 color = albedo.rgb * _Color.rgb;
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * color;
                //漫反射
                fixed3 diffuse = _LightColor0.rgb * color * saturate(dot(worldLightDir, bump));
                //世界视角方向归一
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //halfDir
                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                //高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, bump)), _Gloss);
                
                
                fixed3 finalColor = diffuse + specular;
                return fixed4(finalColor, albedo.a * _AlphaScale);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}