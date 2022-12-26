Shader "UnityShaderBook/Chapter72NormalMapInTangentSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
    }

    SubShader
    {
        Tags
        {
            "LightMode" = "ForwardBase" "Queue" = "Geometry"
        }
        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

            #pragma vertex vert
            #pragma fragment frag

            struct a2v
            {
                float4 pos : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL; //记录顶点原始法线
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXTOORD0;
                fixed3 viewDirInTangent : TEXTOORD1; //切线空间的视角方向
                fixed3 lightDirInTangent : TEXTOORD2; //切线空间的灯光方向
            };

            v2f vert(a2v data)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(data.pos);
                
                o.uv.xy = data.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //TRANSFORM_TEX()
                //uv 针对主帖图和法线贴图都需要采偏移
                o.uv.zw = data.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                fixed3 worldNormal = UnityObjectToWorldNormal(data.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(data.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * data.tangent.w;

                float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

				// Transform the light and view dir from world space to tangent space
				o.lightDirInTangent = mul(worldToTangent, WorldSpaceLightDir(data.pos));
				o.viewDirInTangent = mul(worldToTangent, WorldSpaceViewDir(data.pos));
            	
                // //定义模型到切线矩阵
                // //求副切线
                // float3 binormal = cross(normalize(data.normal), normalize(data.tangent.xyz)) * data.tangent.w;
                // float3x3 rotation = float3x3(data.tangent.xyz, binormal, data.normal);
                // //TANGENT_SPACE_ROTATION
                // //r.lightDirInTangent = mul(rotation, UnityWorldToObjectDir(_WorldSpaceLightPos0.xyz));
                // o.lightDirInTangent = mul(rotation, ObjSpaceLightDir(data.pos)).xyz;
                // //r.viewDirInTangent = mul(rotation, UnityWorldToObjectDir(_WorldSpaceCameraPos) - data.pos.xyz);
                // o.viewDirInTangent = mul(rotation, ObjSpaceViewDir(data.pos)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 viewDir = normalize(i.viewDirInTangent);
                fixed3 lightDir = normalize(i.lightDirInTangent);

            	fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
            	fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
            	
                // float3 normal = tex2D(_BumpMap, i.uv.zw).xyz;
                // //转换为切线空间坐标值
                // normal = (normal * 2 - 1) * _BumpScale;
                // //切线空间 z 恒为正
                // normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
                
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
                
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo.rgb * (saturate(dot(tangentNormal, lightDir)));
                //计算高光
                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
                
                fixed3 col = diffuse + specular;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }

    //FallBack "Diffuse"
}