Shader "UnityShaderBook/Chapter72NormalMapInWorldSpace"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "" {}
        _BumpMap("BumpMap", 2D) = "normal" {}
        _Color("Color", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 256)) = 8
        _BumpScale("BumpScale", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
        }

        Pass
        {
            cull back
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
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            float _BumpScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : Tangent;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 posWorld : COLOR;
                float4 uv : TEXCOORD3;
                float3 TtoW0 : TEXCOORD0;
                float3 TtoW1 : TEXCOORD1;
                float3 TtoW2 : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

                // in ShaderBook Project start
                // fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                // fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                //
                // // Compute the matrix that transform directions from tangent space to world space
                // // Put the world position in w component for optimization
                // o.TtoW0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
                // o.TtoW1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
                // o.TtoW2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);
                // in ShaderBook Project end
                
                float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
                //切线到模型 3X3
                float3x3 rotation = transpose(float3x3(v.tangent.xyz, binormal.xyz, v.normal.xyz));
                //切线到世界
                float3x3 rotation1 = mul((float3x3)unity_ObjectToWorld, rotation);
                o.TtoW0 = float3(rotation1[0][0], rotation1[1][0], rotation1[2][0]);
                o.TtoW1 = float3(rotation1[0][1], rotation1[1][1], rotation1[2][1]);
                o.TtoW2 = float3(rotation1[0][2], rotation1[1][2], rotation1[2][2]);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                 //世界灯光方向归一
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.posWorld));
                //世界视角方向归一
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
                
                //切线到世界
                float3x3 rotation = float3x3(i.TtoW0.x, i.TtoW1.x, i.TtoW2.x,
                                             i.TtoW0.y, i.TtoW1.y, i.TtoW2.y,
                                             i.TtoW0.z, i.TtoW1.z, i.TtoW2.z);
                
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
                
                //计算世界切线归一
                bump = normalize(mul(rotation, bump.xyz));

                // in shaderBook project start
                //bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                // in shaderBook project end

                
                float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(bump, lightDir));
                //计算高光
                fixed3 halfDir = normalize((lightDir + viewDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);
                //计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

                fixed3 color = diffuse + specular;
                return fixed4(color, 1);
            }
            ENDCG
        }

    }

//    FallBack "Diffuse"
}