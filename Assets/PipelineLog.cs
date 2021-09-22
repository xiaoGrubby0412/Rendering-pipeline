using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PipelineLog : MonoBehaviour
{
    public Camera camera;
    public Transform t;
    public Vector4 v = new Vector4(1, 1, 1, 0);
    private Vector3 temp = Vector3.one;
    // Start is called before the first frame update

    private Vector3 vRight = Vector3.right;
    private Vector3 vUp45 = new Vector3(0, 1, 1);


    private void Awake()
    {
   
    }

    void Start()
    {
      

    }

    // Update is called once per frame
    void Update()
    {
        if (t != null)
        {
            //v = new Vector4(1, 1, 1, 0);
            //v = t.localToWorldMatrix * v;

            //Vector3 v1 = new Vector3(t.localToWorldMatrix.m00, t.localToWorldMatrix.m10, t.localToWorldMatrix.m20);
            //Vector3 v2 = new Vector3(t.localToWorldMatrix.m01, t.localToWorldMatrix.m11, t.localToWorldMatrix.m21);
            //Vector3 v3 = new Vector3(t.localToWorldMatrix.m02, t.localToWorldMatrix.m12, t.localToWorldMatrix.m22);

            //Debug.LogError("v1.magnitude == " + v1.magnitude + " v2.magnitude == " + v2.magnitude + " v3.magnitude == " + v3.magnitude);

        }

        if (Input.GetMouseButtonDown(0))
        {
            mousePos = Input.mousePosition;
        }
    }

    private void OnDrawGizmos()
    {
        //Gizmos.DrawRay(t.position, vRight);
        //Gizmos.DrawRay(t.position, vUp45);

        //var m = (t.localToWorldMatrix.transpose).inverse;

        //Vector3 tLeft = m * vRight;
        //Vector3 tUp = m * vUp45;
        //Gizmos.DrawRay(Vector3.zero, tLeft);
        //Gizmos.DrawRay(Vector3.zero, tUp);

        //if (mesh == null) { return; }

        //for (int i = 0; i < mesh.normals.Length; i++)
        //{
        //    Gizmos.DrawRay(t.TransformPoint(mesh.vertices[i]), t.TransformDirection(mesh.normals[i]));
        //}

        //for (int j = 0; j < mesh.normals.Length; j++)
        //{
        //    Gizmos.DrawRay(t.transform.TransformVector(mesh.vertices[j]), t.TransformDirection(mesh.normals[j]));
        //}


        //Gizmos.DrawRay(Vector3.zero, temp);
       
    }

    private const float startX = 20;
    private const float startY = 100;

    private const float width = 50;
    private const float height = 20;
    private const float rowSpace = 20;
    private const float colSpace = 50;

    private Vector3 mousePos = Vector3.zero;

    private void OnGUI()
    {
        //矩阵测试
        GUI.TextField(new Rect(startX, startY, width, height), t.localToWorldMatrix.m00.ToString());
        GUI.TextField(new Rect(startX, startY + rowSpace, width, height), t.localToWorldMatrix.m10.ToString());
        GUI.TextField(new Rect(startX, startY + 2 * rowSpace, width, height), t.localToWorldMatrix.m20.ToString());
        GUI.TextField(new Rect(startX, startY + 3 * rowSpace, width, height), t.localToWorldMatrix.m30.ToString());

        GUI.TextField(new Rect(startX + colSpace, startY, width, height), t.localToWorldMatrix.m01.ToString());
        GUI.TextField(new Rect(startX + colSpace, startY + rowSpace, width, height), t.localToWorldMatrix.m11.ToString());
        GUI.TextField(new Rect(startX + colSpace, startY + 2 * rowSpace, width, height), t.localToWorldMatrix.m21.ToString());
        GUI.TextField(new Rect(startX + colSpace, startY + 3 * rowSpace, width, height), t.localToWorldMatrix.m31.ToString());

        GUI.TextField(new Rect(startX + 2 * colSpace, startY, width, height), t.localToWorldMatrix.m02.ToString());
        GUI.TextField(new Rect(startX + 2 * colSpace, startY + rowSpace, width, height), t.localToWorldMatrix.m12.ToString());
        GUI.TextField(new Rect(startX + 2 * colSpace, startY + 2 * rowSpace, width, height), t.localToWorldMatrix.m22.ToString());
        GUI.TextField(new Rect(startX + 2 * colSpace, startY + 3 * rowSpace, width, height), t.localToWorldMatrix.m32.ToString());

        GUI.TextField(new Rect(startX + 3 * colSpace, startY, width, height), t.localToWorldMatrix.m03.ToString());
        GUI.TextField(new Rect(startX + 3 * colSpace, startY + rowSpace, width, height), t.localToWorldMatrix.m13.ToString());
        GUI.TextField(new Rect(startX + 3 * colSpace, startY + 2 * rowSpace, width, height), t.localToWorldMatrix.m23.ToString());
        GUI.TextField(new Rect(startX + 3 * colSpace, startY + 3 * rowSpace, width, height), t.localToWorldMatrix.m33.ToString());

        temp = t.localToWorldMatrix * v;
        GUI.TextField(new Rect(startX + 4 * colSpace, startY, width * 3, height), temp.ToString());

        //渲染管线描述

        Mesh mesh = t.GetComponent<MeshFilter>().mesh;
        if (mesh == null) return;

        //打印投影矩阵
        GUI.TextField(new Rect(startX + 4 * colSpace, startY + rowSpace, width * 5, height * 4), camera.projectionMatrix.ToString());

        //获取模型坐标
        Vector4 pos = new Vector4(mesh.vertices[0].x, mesh.vertices[0].y, mesh.vertices[0].z, 1);
        //打印模型坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + rowSpace, width * 4, height), "模型坐标 : " + pos.ToString());

        //模型坐标转换为世界坐标
        pos = t.transform.localToWorldMatrix * pos;

        Vector3 wpos = t.TransformPoint(mesh.vertices[0]);
        Vector3 w2screenPoint = camera.WorldToScreenPoint(pos); //Z的位置是以世界单位衡量的到 相机 的距离。
        Vector3 w2viewPort = camera.WorldToViewportPoint(pos); //Z的位置是以世界单位衡量的到 相机 的距离。

        //打印世界坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + 2 * rowSpace, width * 4, height), "世界坐标 : " + pos.ToString());

        //世界坐标转换为相机坐标
        pos = camera.worldToCameraMatrix * pos;
        //打印相机坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + 3 * rowSpace, width * 4, height), "相机坐标 : " + pos.ToString());

        //乘以投影矩阵 变为齐次坐标
        pos = camera.projectionMatrix * pos;
        //打印齐次坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + 4 * rowSpace, width * 4, height), "齐次坐标 : " + pos.ToString());

        float screenX = (pos.x * Screen.width) / (2 * pos.w) + Screen.width / 2;
        float screenY = (pos.y * Screen.height) / (2 * pos.w) + Screen.height / 2;

        float fx = screenX / Screen.width; //这个就是 viewPort 坐标 x
        float fy = screenY / Screen.height;//这个就是 viewPort 坐标 y

        //打印屏幕坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + 5 * rowSpace, width * 4, height), "屏幕坐标 x : " + screenX + " y : " + screenY);

        //打印点击坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + 6 * rowSpace, width * 4, height), "点击坐标 : " + mousePos.ToString());

        //归一化齐次坐标
        pos = new Vector4(pos.x / pos.w, pos.y / pos.w, pos.z / pos.w, pos.w / pos.w);
        //打印归一化齐次坐标
        GUI.TextField(new Rect(startX + 9 * colSpace, startY + 7 * rowSpace, width * 4, height), "归一齐次 : " + pos.ToString());

        
    }
}
