using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixTransform : MonoBehaviour
{
    public Transform cubeA;

    public Transform cubeB;
    
    //假设B坐标系下面的 111点
    public Vector4 PosInB = Vector4.one;

    public Vector3 PosInA = Vector3.zero;
    
    public Vector4 PosInA_MAtoB = Vector4.one;
    
    public Vector3 PosInB_MAtoB = Vector3.zero;
    // Start is called before the first frame update
    void Start()
    {


    }

    // Update is called once per frame
    void Update()
    {
        //获取B点在A坐标系之下的坐标
        Vector3 posBtoA = cubeA.InverseTransformPoint(cubeB.TransformPoint(Vector3.zero));
        //获取B的基坐标单位化之后 在A坐标系下的表示
        Vector3 baseCoordBToA_X = cubeA.InverseTransformDirection(cubeB.TransformDirection(new Vector3(1, 0, 0)));
        Vector3 baseCoordBToA_Y = cubeA.InverseTransformDirection(cubeB.TransformDirection(new Vector3(0, 1, 0)));
        Vector3 baseCoordBToA_Z = cubeA.InverseTransformDirection(cubeB.TransformDirection(new Vector3(0, 0, 1)));
        //构造矩阵
        Matrix4x4 matrixBtoA = new Matrix4x4();
        matrixBtoA.m00 = baseCoordBToA_X.x;
        matrixBtoA.m10 = baseCoordBToA_X.y;
        matrixBtoA.m20 = baseCoordBToA_X.z;
        matrixBtoA.m30 = 0;

        matrixBtoA.m01 = baseCoordBToA_Y.x;
        matrixBtoA.m11 = baseCoordBToA_Y.y;
        matrixBtoA.m21 = baseCoordBToA_Y.z;
        matrixBtoA.m31 = 0;
        
        matrixBtoA.m02 = baseCoordBToA_Z.x;
        matrixBtoA.m12 = baseCoordBToA_Z.y;
        matrixBtoA.m22 = baseCoordBToA_Z.z;
        matrixBtoA.m32 = 0;
        
        matrixBtoA.m03 = posBtoA.x;
        matrixBtoA.m13 = posBtoA.y;
        matrixBtoA.m23 = posBtoA.z;
        matrixBtoA.m33 = 1;
        
        
        PosInA = matrixBtoA * PosInB;
        
        //求matrixAtoB
        Matrix4x4 matrixAtoB = new Matrix4x4();
        matrixAtoB.m00 = baseCoordBToA_X.x;
        matrixAtoB.m01 = baseCoordBToA_X.y;
        matrixAtoB.m02 = baseCoordBToA_X.z;
        
        matrixAtoB.m10 = baseCoordBToA_Y.x;
        matrixAtoB.m11 = baseCoordBToA_Y.y;
        matrixAtoB.m12 = baseCoordBToA_Y.z;
        
        matrixAtoB.m20 = baseCoordBToA_Z.x;
        matrixAtoB.m21 = baseCoordBToA_Z.y;
        matrixAtoB.m22 = baseCoordBToA_Z.z;
        
        matrixAtoB.m30 = 0;
        matrixAtoB.m31 = 0;
        matrixAtoB.m32 = 0;
        
        matrixAtoB.m03 = -posBtoA.x;
        matrixAtoB.m13 = -posBtoA.y;
        matrixAtoB.m23 = -posBtoA.z;
        matrixAtoB.m33 = 1;


        PosInB_MAtoB = matrixAtoB * PosInA_MAtoB;
        //PosInB_MAtoB = matrixBtoA.inverse * PosInA_MAtoB;
    }
}
