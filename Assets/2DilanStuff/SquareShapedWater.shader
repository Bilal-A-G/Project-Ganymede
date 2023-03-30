Shader "Custom/SquareShapedWater"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _WaveAmplitude("Wave Amplitude", Range(0.01, 0.5)) = 0.1
        _WaveFrequency("Wave Frequency", Range(0.01, 2)) = 0.5
        _WaveSpeed("Wave Speed", Range(0.01, 0.5)) = 0.1
        _WaveSharpness("Wave Sharpness", Range(1, 10)) = 2
        _UseColor("Use Color", Range(0, 1)) = 0
        _RGBColor("RGB Color", Color) = (0,0,0,1)
    }

        SubShader{
            Tags {"Queue" = "Transparent" "RenderType" = "Opaque"}
            LOD 100

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
                float _WaveAmplitude;
                float _WaveFrequency;
                float _WaveSpeed;
                float _WaveSharpness;
                float4 _Color;
                float _UseColor;
                float4 _RGBColor;

                v2f vert(appdata v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                float4 frag(v2f i) : SV_Target {
                    float2 p = i.uv;
                    p -= 0.5;

                    float3 n = float3(0,0,1);
                    float d = dot(n, float3(0,1,0));
                    float3 r = float3(2 * d * n.x, 2 * d * n.y - 1, 2 * d * n.z);
                    r = normalize(r);

                    float wave = _WaveAmplitude * sin(_WaveFrequency * (p.x * r.x + p.y * r.y - _Time.y * _WaveSpeed));

                    float mask = pow(max(0, abs(wave) - (1.0 / _WaveSharpness)), 2);

                    float4 tex = tex2D(_MainTex, i.uv);
                    float4 color = _UseColor == 0 ? _Color : _RGBColor;

                    return tex * color * mask;
                }
                ENDCG
            }
        }
}
