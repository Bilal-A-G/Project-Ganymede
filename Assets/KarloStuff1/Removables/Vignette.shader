Shader "Custom/Vignette"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _VignetteIntensity("Vignette Intensity", Range(0, 1)) = 0.5
        _VignetteRadius("Vignette Radius", Range(0, 1)) = 0.5
        _CenterSize("Center Size", Range(0.5, 1.5)) = 1
        _VignetteColor("Vignette Color", Color) = (0,0,0,1)
    }

    SubShader
    {
        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _VignetteIntensity;
            float _VignetteRadius;
            float _CenterSize;
            float4 _VignetteColor;

            v2f vert(appdata v) 
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target 
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 center = (i.uv - 0.5) * _CenterSize;
                float vignette = 1.0 - smoothstep(_VignetteRadius, 1.0, length(center) * 2.0);
                col.rgb *= vignette * (1.0 - _VignetteIntensity);
                col.rgb += _VignetteColor.rgb * (1.0 - vignette) * _VignetteIntensity;
                return col;
            }
            ENDCG
        }
    }
}
