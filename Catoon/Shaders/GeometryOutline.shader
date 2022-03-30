Shader "Custom/Geometry Outline"
{
    Properties{
        _LineColor("Line Color", Color) = (0,0,0,1)
        _LineWidth("Line Width", range(0, 1)) = 0.02
        _SqrCosin("Sqr Cosin", range(0, 1)) = 0.5
    }

    SubShader{
        Pass{
            Cull Back
            Tags{"RenderType"="Opaque" "LightMode"="ForwardBase"}
            CGPROGRAM  
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            struct Line{
                int p1,p2,p3,p4;
            };

            fixed _LineWidth;
            fixed3 _LineColor;
            fixed _SqrCosin;
            StructuredBuffer<float3> _Vertices;
            StructuredBuffer<float3> _Normals;
            StructuredBuffer<Line> _DRects;

            struct v2g{
                float4 vert1:POSITION;
                float4 vert2:COLOR;
            };

            struct g2f{
                float4 pos:SV_POSITION;
            };

            v2g vert(uint id: SV_VERTEXID, uint inst:SV_INSTANCEID){
                v2g o;
                Line l = _DRects[id];
                float3 p1 = _Vertices[l.p1];
                float3 p2 = _Vertices[l.p2];
                
                float3 n1 = _Normals[l.p1];
                float3 n2 = _Normals[l.p2];

                float3 p3 = _Vertices[l.p3];

                bool bEdge = 0;
                if (l.p4 >= 0){
                    float3 p4 = _Vertices[l.p4];
                    
                    float3 v1 = p2 - p1;
                    float3 v2 = p3 - p1;
                    float3 v3 = p4 - p1;

                    float3 normal1 = cross(v1, v2);
                    float3 normal2 = cross(v3, v1);

                    float3 center1 = (p1 + p2 + p3) / 3.0f;
                    float3 viewDir1 = ObjSpaceViewDir(float4(center1, 1.0f));

                    float3 center2 = (p1 + p2 + p4) / 3.0f;
                    float3 viewDir2 = ObjSpaceViewDir(float4(center2, 1.0f));

                    bool bContour = step(0, -dot(normal1, viewDir1) * dot(normal2, viewDir2));
                    float N1dotN2 = dot(normal1, normal2);
                    bool bCrease = step(N1dotN2 * N1dotN2 / _SqrCosin, dot(normal1, normal1) * dot(normal2, normal2));

                    bEdge = bContour || bCrease;
                }
                o.vert1 = UnityObjectToClipPos(float4(p1 + n1 * _LineWidth * 0.005f, 1.0f)) * bEdge;
                o.vert2 = UnityObjectToClipPos(float4(p2 + n2 * _LineWidth * 0.005f, 1.0f)) * bEdge;
                return o;
            }


            [maxvertexcount(6)]
            void geom(point v2g input[1], inout TriangleStream<g2f> stream){
                float3 p1 = input[0].vert1.xyz / input[0].vert1.w;
                float3 p2 = input[0].vert2.xyz / input[0].vert2.w;
                float2 l = (p2.xy - p1.xy);
                float ext = l * 0.01f;
                l = normalize(l);
                float2 n = float2(-l.y, l.x) * _LineWidth * 0.5f;
                float4 v1 = float4(p1.xy - ext + n, p1.z, 1.0f);
                float4 v2 = float4(p2.xy + ext + n, p2.z, 1.0f);
                float4 v3 = float4(p2.xy + ext - n, p2.z, 1.0f);
                float4 v4 = float4(p1.xy - ext - n, p1.z, 1.0f);
                
                // triangle 1
                g2f o;
                o.pos = v1;
                stream.Append(o);
                o.pos = v3;
                stream.Append(o);
                o.pos = v2;
                stream.Append(o);
                stream.RestartStrip();

                // triangle2;
                o.pos = v1;
                stream.Append(o);
                o.pos = v4;
                stream.Append(o);
                o.pos = v3;
                stream.Append(o);
                stream.RestartStrip();      
            }

            fixed4 frag(g2f i):SV_TARGET{
                return fixed4(_LineColor.rgb, 1.0f);
            }

            ENDCG

        }
    }

    Fallback Off
}
