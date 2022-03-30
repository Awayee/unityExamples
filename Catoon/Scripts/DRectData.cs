using System.Collections;
using System.Collections.Generic;
using UnityEngine;

struct DLine{
    float x1, y1, z1;
    float x2, y2, z2;
    public DLine(Vector3 point1, Vector3 point2){
        if(point1.sqrMagnitude < point2.sqrMagnitude){
            x1 = point1.x; y1 = point1.y; z1 = point1.z;
            x2 =point2.x; y2 = point2.y; z2 = point2.z;
        }
        else{
            x1 = point2.x; y1 = point2.y; z1 = point2.z;
            x2 = point1.x; y2 = point1.y; z2 = point1.z;
        }
    }
}

[System.Serializable]
public struct DRect{
    int p1, p2, p3, p4;
    public DRect(int point1, int point2, int point3, int point4){
        p1 = point1; p2 = point2; p3 = point3; p4 = point4;
    }

    // public static bool operator==(DRect r1, DRect r2){
    //     return r1.x1 == r2.x1 && r1.x2 == r2.x2 && r1.x3 == r2.x3 && r1.x4 == r2.x4;
    // }
    // public static bool operator!=(DRect r1, DRect r2){
    //     return r1.x1 != r2.x1 || r1.x2 == r2.x2 || r1.x3 == r2.x3 || r1.x4 == r2.x4;
    // }

    public static List<DRect> GenerateDRects(Mesh mesh){
        Dictionary<DLine, DRect> dctRects = new Dictionary<DLine, DRect>();
        Vector3[] vertices = mesh.vertices;
        int[] indices = mesh.triangles;
        int triCount = Mathf.CeilToInt(indices.Length / 3);
        for (int i=0; i < triCount; i++){
            int p1 = indices[i * 3];
            int p2 = indices[i * 3 + 1];
            int p3 = indices[i * 3 + 2];

            Vector3 v1 = vertices[p1];
            Vector3 v2 = vertices[p2];
            Vector3 v3 = vertices[p3];

            DLine l1 = new DLine(v1, v2);
            DLine l2 = new DLine(v2, v3);
            DLine l3 = new DLine(v3, v1);
            if (dctRects.ContainsKey(l1)){
                if (dctRects[l1].p4 < 0){
                    // dctRects[line1].x4 = v3;
                    DRect d = dctRects[l1];
                    dctRects[l1] = new DRect(d.p1, d.p2, d.p3, p3);
                }
            }
            else{
                dctRects[l1] = new DRect(p1, p2, p3, -1);
            }
            
            if (dctRects.ContainsKey(l2)){
                if (dctRects[l2].p4 < 0){
                    DRect d = dctRects[l2];
                    dctRects[l2] = new DRect(d.p1, d.p2, d.p3, p1);
                }
            }
            else{
                dctRects[l2] = new DRect(p2, p3, p1, -1);
            }

            if (dctRects.ContainsKey(l3)){
                if (dctRects[l3].p4 < 0){
                    DRect d = dctRects[l3];
                    dctRects[l3] = new DRect(d.p1, d.p2, d.p3, p2);
                }
            }
            else{
                dctRects[l3] = new DRect(p3, p1, p2, -1);
            }

        }

        List<DRect> dRects = new List<DRect>();
        foreach(DRect d in dctRects.Values){
            dRects.Add(d);
        }
        return dRects;
    }
}


[CreateAssetMenu(fileName ="DRectData", menuName ="Geometry Outline")]
public class DRectData : ScriptableObject
{
    // Start is called before the first frame update
    public List<DRect> m_DRects;
    [SerializeField] private Mesh m_Mesh;
    [ContextMenu("Create DRectData")]
    private void CreateDRectData(){
        m_DRects = DRect.GenerateDRects(m_Mesh);
        Debug.Log("生成成功! 四边形数量 = "+m_DRects.Count);
    }
    
}
