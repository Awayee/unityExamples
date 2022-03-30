using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

// 几何描边法
public class GeometryOutline : MonoBehaviour
{
    // Start is called before the first frame update
    private Camera m_Camera;
    
    private SkinnedMeshRenderer m_Renderer;
    private Mesh m_Mesh;
    [SerializeField]private DRectData m_DRectData;
    public List<DRect> m_DRects{ get{return m_DRectData.m_DRects;}}
    [SerializeField]private Material m_MaterialPrefab;
    private Material m_Material;

    private CommandBuffer m_CommandBuffer;
    private CameraEvent m_Event = CameraEvent.AfterForwardOpaque;
    // 缓冲
    private ComputeBuffer m_VerticesBuffer;
    private ComputeBuffer m_NormalsBuffer;
    private ComputeBuffer m_DRectsBuffer;
    private void Awake(){
        InitResources();
        CreateBuffers();
        Draw();
    }

    private void OnDestroy(){
        ReleaseBuffers();
    }

    private void InitResources(){
        m_Camera = Camera.main;
        m_Renderer = GetComponentInChildren<SkinnedMeshRenderer>();
        m_Material = Instantiate(m_MaterialPrefab);
    }

    private void CreateBuffers(){
        if (null == m_DRects){
            return;
        }
        m_Mesh = new Mesh();
        m_Renderer.BakeMesh(m_Mesh);

        // 顶点
        Vector3[] vertices = m_Mesh.vertices;
        if (vertices.Length > 0){
            m_VerticesBuffer = new ComputeBuffer(vertices.Length, 3 * sizeof(float), ComputeBufferType.Default);
            m_VerticesBuffer.SetData(vertices);
        }

        // 法线
        Vector3[] normals = m_Mesh.normals;
        if (normals.Length > 0){
            m_NormalsBuffer = new ComputeBuffer(normals.Length, 3 * sizeof(float), ComputeBufferType.Default);
            m_NormalsBuffer.SetData(normals); 
        }

        // 邻接四边形
        if (m_DRects.Count > 0){
            m_DRectsBuffer = new ComputeBuffer(m_DRectData.m_DRects.Count, 4 * sizeof(int), ComputeBufferType.Default);
            m_DRectsBuffer.SetData(m_DRectData.m_DRects);
        }
        
        // CommandBuffer
        m_CommandBuffer = new CommandBuffer();
        m_CommandBuffer.name = "Geometry Outline";
    }

    private void Draw(){
        m_Material.SetBuffer("_Vertices", m_VerticesBuffer);
        m_Material.SetBuffer("_Normals", m_NormalsBuffer);
        m_Material.SetBuffer("_DRects", m_DRectsBuffer);
        Matrix4x4 mat = m_Renderer.transform.localToWorldMatrix;
        m_CommandBuffer.DrawProcedural(mat, m_Material, 0, MeshTopology.Points, m_DRectData.m_DRects.Count);
        m_Camera.AddCommandBuffer(m_Event, m_CommandBuffer);
    }

    private void ReleaseBuffers(){
        if (null != m_VerticesBuffer){
             m_VerticesBuffer.Release();
             m_VerticesBuffer = null;
        }
        if (null != m_NormalsBuffer){
            m_NormalsBuffer.Release();
            m_NormalsBuffer = null;
        } 
        if (null != m_DRectsBuffer){
            m_DRectsBuffer.Release();
            m_DRectsBuffer = null;
        } 
        if (null != m_Camera)m_Camera.RemoveCommandBuffer(m_Event, m_CommandBuffer);
    }
}
