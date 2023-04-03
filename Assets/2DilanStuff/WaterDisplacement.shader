Shader "Custom/WaterDisplacement"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _NormalMap("Displacement Map", 2D) = "white" {}
        _Color("Tint Color", Color) = (1, 1, 1, 1)
        _Scale("Scale", float) = 0
    }

        SubShader{
            Tags { "RenderType" = "Opaque" }

            Pass {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                sampler2D _NormalMap;
                float4 _Color;
                float _Scale;

                v2f vert(appdata v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float time = _Time.y;
                    
                    float4 normal = tex2D(_NormalMap, (i.uv + time * 0.15f) * _Scale);
                    float4 baseColour = tex2D(_MainTex, (i.uv + time * 0.1f) * _Scale);

                    float3 lightDir = WorldSpaceLightDir(i.vertex);
                    float diffuseStrength = dot(lightDir, normal.xyz);

                    baseColour += _Color * diffuseStrength;

                    return baseColour;
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
