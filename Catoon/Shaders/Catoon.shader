// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Catoon"{
    Properties{
        _MainTex("Main Tex", 2D) = "white"{}
        _Diffuse0("Diffuse0", Color) = (0.1, 0.1, 0.1, 0.1)
        _Diffuse1("Diffuse1", Color) = (0.5, 0.5, 0.5, 0.5)
        _Diffuse2("Diffuse2", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Smooth("Smooth", range(0, 1)) = 0.01
        _Rim("Rim", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader{
        Pass{
            Tags{"LgihtMode" = "ForwardBase"}
            LOD 200
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            half4 _MainTex_ST;
            fixed4 _Diffuse0;
            fixed4 _Diffuse1;
            fixed4 _Diffuse2;
            fixed4 _Specular;
            fixed _Gloss;
            fixed _Smooth;
            fixed4 _Rim;

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed3 StepValue(fixed d){
                fixed g2 = smoothstep(0.0f, 1.0f, (d - _Diffuse1.a + 0.5f * _Smooth) / _Smooth);
                fixed g3 = smoothstep(0.0f, 1.0f, (d - _Diffuse2.a + 0.5f * _Smooth) / _Smooth);
                return _Diffuse0.rgb + g2 * (_Diffuse1.rgb - _Diffuse0.rgb) + g2 * g3 * (_Diffuse2.rgb - _Diffuse1.rgb);
            }

            fixed4 frag(v2f i):SV_TARGET{
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed d = max(0.0f, dot(worldNormal, worldLightDir));
                fixed3 diffuse = StepValue(d) * albedo;

                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed s = pow(max(0.0f, dot(halfDir, worldNormal)), 16.0f);
                s = smoothstep(0.0f, 1.0f, (s - _Specular.a + 0.5f * _Smooth) / _Smooth);
                fixed3 specular = s * _Specular;

                fixed rim = 1.0f - dot(worldNormal, worldViewDir);
                rim = smoothstep(0.0f, 1.0f, (rim - _Rim.a + 0.5f * _Smooth) / _Smooth);

                fixed3 result = ambient + diffuse + specular + rim * _Rim.rgb;
                return fixed4(result, 1.0f);
            }

            ENDCG
        }
    }

    Fallback Off
}