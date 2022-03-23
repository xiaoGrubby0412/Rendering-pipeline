// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/WM/DiffuseFragHalf"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
      }
      
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        //像素插值 漫反射 lambertHalf
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _Diffuse;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject); //获取世界坐标系下的法线 处理法线 逆矩阵的转置矩阵                 
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //获取环境光
                fixed3 worldNormal = normalize(i.worldNormal); //世界法线
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz); //世界灯光
                
                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                fixed3 color = diffuse;
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
       
    }
}
