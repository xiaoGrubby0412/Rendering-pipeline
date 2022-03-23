// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/WM/DiffuseVert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
      
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        //顶点插值 漫反射
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //环境光
                fixed3 normalDir = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //获取光源
                fixed3 diffuse = _LightColor0 * max(0, dot(normalDir, lightDir)) * _Diffuse;
                             
                f.color = diffuse;
                return f;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
       
    }
}
