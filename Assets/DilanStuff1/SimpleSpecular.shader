Shader "Custom/SimpleSpecular"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,0)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
            Tags { "RenderType" = "Opaque" }
         CGPROGRAM
    #pragma surface surf SimpleSpecular

    half4 LightingSimpleSpecular(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
        half3 h = normalize(lightDir + viewDir);

        half diff = max(0, dot(s.Normal, lightDir));

        float nh = max(0, dot(s.Normal, h));
        float spec = pow(nh, 48.0);

        half4 c;
        c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
        c.a = s.Alpha;
        return c;
    }

    struct Input {
        float2 uv_MainTex;
    };

    sampler2D _MainTex;
    float4 _Color;

    void surf(Input IN, inout SurfaceOutput o) {
        o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color.rgb;
    }
    ENDCG
    }
    FallBack "Simple Specular"
}
