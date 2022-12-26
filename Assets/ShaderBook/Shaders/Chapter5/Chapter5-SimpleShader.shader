// Upgrade NOTE: replaced 'glstate_matrix_projection' with 'UNITY_MATRIX_P'

// Upgrade NOTE: replaced 'glstate_matrix_projection' with 'UNITY_MATRIX_P'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UnityShaderBook/Chapter5-SimpleShader"
{
    Properties
    {
        //_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
//        Tags
//        {
//            "Queue" = "Transparent"
//        }
        Pass
        {
//            ZWrite Off
//            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;

            struct a2v
            {
                float4 pos : POSITION;
                float4 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };

            //矩阵和向量相乘的函数
            //CG语言中 *号 代表简单的把各个分量进行相乘 而不是 我们想要的矩阵相乘 或者 向量点积 叉积 等等
            float4 mulMatrix_V(float4x4 m, float4 vf)
            {
                float4 uo1 = float4(m[0][0], m[0][1], m[0][2], m[0][3]);
                float4 uo2 = float4(m[1][0], m[1][1], m[1][2], m[1][3]);
                float4 uo3 = float4(m[2][0], m[2][1], m[2][2], m[2][3]);
                float4 uo4 = float4(m[3][0], m[3][1], m[3][2], m[3][3]);

                vf = float4(dot(uo1, vf), dot(uo2, vf), dot(uo3, vf), dot(uo4, vf));
                return vf;
            }

            v2f vert(a2v v)
            {
                float4 vf = float4(v.pos.x, v.pos.y, v.pos.z, 1);
                //mvp
                vf = mulMatrix_V(unity_ObjectToWorld, vf);
                vf = mulMatrix_V(UNITY_MATRIX_V, vf);
                vf = mulMatrix_V(UNITY_MATRIX_P, vf);

                v2f r;
                r.pos = vf;
                r.color = v.normal * 0.5f + fixed3(0.5f, 0.5f, 0.5f); 
                return r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }

    Fallback "VertexLit"
}