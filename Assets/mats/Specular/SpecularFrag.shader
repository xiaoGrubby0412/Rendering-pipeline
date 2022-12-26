﻿Shader "Unlit/WM/SpecularFrag"
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
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
            };

            v2f vert (a2v v)
            {
                v2f f;
                f.pos = UnityObjectToClipPos(v.vertex);
                f.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                f.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return f;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; //环境光
                fixed3 normalDir = normalize(i.worldNormal); 
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //获取光源
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(normalDir, lightDir)) * _Diffuse.rgb; //获得漫反射颜色强度
                
                //获取反射方向
                fixed3 reflectDir = normalize(reflect(-lightDir, normalDir)); 
                //获取视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
               
                             
                fixed3 color = diffuse + specular;
                
                return fixed4(color, 1.0);
            }
            ENDCG
        }
       
    }
}
