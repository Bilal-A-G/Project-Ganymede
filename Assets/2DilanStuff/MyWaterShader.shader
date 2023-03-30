Shader "Custom/MyWaterShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _WaveAmplitude("Wave Amplitude", float) = 0.1
        _WaveFrequency("Wave Frequency", float) = 0.5
        _WaveSpeed("Wave Speed", float) = 0.1
        _UseColor("Use Color", Range(0, 1)) = 0
        _RGBColor("RGB Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma vertex vert

        sampler2D _MainTex;

        float _WaveAmplitude;
        float _WaveFrequency;
        float _WaveSpeed;

        half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten) {
            half NdotL = dot(s.Normal, lightDir);//dot product of the surface normal and light direction, its the cosine angle between them
            half diff = NdotL * 0.5 + 0.5;//diffuse lighting 
            half3 ramp = tex2D(_MainTex, float(diff)).rgb;//ramp effect with the colors of the diffuse lighting
            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;//the creation of the final outputted colors
            c.a = s.Alpha;
            return c;
        }

        void vert(inout appdata_full i) {
            float displacement = _WaveAmplitude * sin((i.vertex.x + _Time.x * _WaveSpeed) * _WaveFrequency);
            if (displacement > 0) {
                displacement = 1;
            }
            else if (displacement < 0) {
                displacement = -1;
            }
            else if (displacement == 0) {
                displacement = 0;
            }
            i.vertex = float4(i.vertex.x, i.vertex.y + displacement, i.vertex.z, i.vertex.w);
        }

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
