// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Phong"{
    Properties {
        _MainTex("Main Tex", 2D) = "white"{}
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(0, 64)) = 16.0
    }
    SubShader{
        Pass{
            Tags {"LightMode" = "ForwardBase"}
            LOD 200
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            half4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed d = max(0.0f, dot(worldNormal, worldLightDir));
                fixed3 diffuse = d * _Diffuse * albedo;

                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed s = pow(max(0.0f, dot(halfDir, worldNormal)), _Gloss);
                fixed3 specular = s * _Specular;

                fixed3 result = ambient + diffuse + specular;
                return fixed4(result, 1.0f);
            }
            ENDCG
        }
    }
    Fallback Off
}