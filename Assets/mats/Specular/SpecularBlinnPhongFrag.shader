// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/WM/SpecularBlinnPhongFrag"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
      
    SubShader
    {
        //顶点插值 漫反射
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0; //世界法线
                fixed3 worldPos : TEXCOORD1; //世界坐标
            };

            v2f vert (a2v v)
            {
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject); //计算世界法线
                f.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex); //计算该顶点的世界坐标
                return f;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //环境光
                
                fixed3 normalDir = normalize(mul(i.worldNormal, (float3x3)unity_WorldToObject)); 
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //获取光源方向
                fixed3 diffuse = _LightColor0 * max(0, dot(normalDir, lightDir)) * _Diffuse; //获得漫反射颜色强度
                 
                //获取视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(viewDir + lightDir);
                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(normalDir, halfDir)), _Gloss);
                             
                fixed3 color = diffuse + specular;
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
       
    }
}
