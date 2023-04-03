Shader "Custom/Decal"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Colour ("Colour", Color) = (1, 1, 1, 1)
        _DecalTex ("Decal Albedo (RGB)", 2D) = "white" {}
        _DecalPosition ("Decal Position", vector) = (0, 0, 0, 0)
        _DecalScale ("Decal Scale", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        sampler2D _DecalTex;

        float _DecalScale;
        float4 _DecalPosition;
        float4 _Colour;
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex * 1/_DecalScale + float2(_DecalPosition.yx);
            float3 decal = tex2D(_DecalTex, uv).rgb;
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * _Colour + decal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
