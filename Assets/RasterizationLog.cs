using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RasterizationLog : MonoBehaviour
{
    public Camera camera;
    public Transform t;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void GetWorldPos(Vector4 pos)
    {
        //模型坐标转换为世界坐标
        pos = t.transform.localToWorldMatrix * pos;


     
        //世界坐标转换为相机坐标
        pos = camera.worldToCameraMatrix * pos;
       

        //乘以投影矩阵 变为齐次坐标
        pos = camera.projectionMatrix * pos;
        

        //归一化齐次坐标
        pos = new Vector4(pos.x / pos.w, pos.y / pos.w, pos.z / pos.w, pos.w / pos.w);

        float viewPortX = pos.x * 0.5f + 0.5f; //这个就是 viewPort 坐标 x
        float viewPortY = pos.y * 0.5f + 0.5f; //这个就是 viewPort 坐标 y

        float screenX = viewPortX * Screen.width; // 屏幕像素坐标 X
        float screenY = viewPortY * Screen.height; // 屏幕像素坐标 Y



    }
}
