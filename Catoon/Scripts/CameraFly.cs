using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFly : MonoBehaviour
{
    // Start is called before the first frame update
    private Transform m_Camera;
    [SerializeField] private int m_Sensitivity = 1;
    private Vector2 m_LastMouse;
    void Start(){
        m_Camera = Camera.main.transform;
    }

    // Update is called once per frame
    void Update(){
        if (null == m_Camera){
            return;
        }

        // 按键移动
        float fX = (Input.GetKey(KeyCode.A) ? -1.0f : 0.0f) + (Input.GetKey(KeyCode.D) ? 1.0f : 0.0f);
        float fZ = (Input.GetKey(KeyCode.S) ? -1.0f : 0.0f) + (Input.GetKey(KeyCode.W) ? 1.0f : 0.0f);
        float fY = (Input.GetKey(KeyCode.LeftControl) ? -1.0f : 0.0f + (Input.GetKey(KeyCode.Space) ? 1.0f : 0.0f));
        if (fX != 0.0f || fY != 0.0f || fZ != 0.0f){
            m_Camera.Translate(m_Sensitivity * 0.01f * new Vector3(fX, fY, fZ), Space.Self);
        }

        // 旋转
        Vector2 mouse = Input.mousePosition;
        if (mouse != m_LastMouse){
            if (Input.GetMouseButton(1)){
                Vector2 delta = mouse - m_LastMouse;
                float k = m_Sensitivity * 0.01f;
                float angleRange = 89.0f;
                Vector3 euler = new Vector3(-delta.y * k, delta.x * k, 0.0f);
                euler += m_Camera.eulerAngles;
                if (euler.x > 180.0f){
                    euler.x = Mathf.Max(euler.x, 360.0f - angleRange);
                }
                else{
                    euler.x = Mathf.Min(euler.x, angleRange);
                }
                m_Camera.eulerAngles= euler;
            }
            m_LastMouse = mouse;
        }
    }
}
