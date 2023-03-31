Shader "Custom/WaterDisplacement"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _DisplacementMap("Displacement Map", 2D) = "white" {}
        _WaveParams("Wave Parameters", Vector) = (0.1, 1.0, 1.0, 0.0)
        _Color("Tint Color", Color) = (1, 1, 1, 1)
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

                float4 _WaveParams;
                sampler2D _MainTex;
                sampler2D _DisplacementMap;
                float4 _Color;

                v2f vert(appdata v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target {
                    // Sample the displacement map
                    float4 displacement = tex2D(_DisplacementMap, i.uv);

                    // Calculate the wave displacement using the wave parameters
                    float time = _Time.y;
                    float amplitude = _WaveParams.x;
                    float speed = _WaveParams.y;
                    float frequency = _WaveParams.z;
                    float w = _WaveParams.w + time * 5;
                    float waveDisplacement = displacement.r * amplitude * sin(2 * 3.141592 * frequency * dot(i.uv, float2(1, 1)) + w * speed);

                    // Sample the main texture
                    float4 color = tex2D(_MainTex, i.uv + waveDisplacement);

                    color *= _Color;

                    return color;
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
