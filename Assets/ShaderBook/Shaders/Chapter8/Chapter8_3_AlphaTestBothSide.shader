Shader "UnityShaderBook/Chapter8_3_AlphaTestBothSide"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("CutOff", float) = 0.5
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
            Cull Off
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Cutoff;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : COLOR;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // v.worldNormal = normalize(v.worldNormal);
                // float3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPos));
                //
                // float4 _texColor = tex2D(_MainTex, v.uv);
                // clip(_texColor.a - _CutOff);
                //
                // fixed3 albedo = _texColor.rgb * _Color.rgb;
                //
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
                //
                // fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(v.worldNormal, worldLightDir));
                // return fixed4(diffuse + ambient, _texColor.a);

                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed4 texColor = tex2D(_MainTex, i.uv);
				
				// Alpha test
				clip (texColor.a - _Cutoff);
				// Equal to 
//				if ((texColor.a - _Cutoff) < 0.0) {
//					discard;
//				}
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				
				return fixed4(ambient + diffuse, 1.0);
            }
            
            ENDCG
        }    
    }
    
    FallBack "Transparent/Cutoff/VertexLit"
}