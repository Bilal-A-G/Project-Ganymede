Shader "Custom/Vignette"
{
    Properties
    {
        // Main texture used for the vignette effect
        _MainTex("Texture", 2D) = "white" {}

        // Intensity of the effect
        _VignetteIntensity("Vignette Intensity", Range(0, 1)) = 0.5

        // Radius of the effect
        _VignetteRadius("Vignette Radius", Range(0, 1)) = 0.5

        // Size of the center of the effect
        _CenterSize("Center Size", Range(0.5, 1.5)) = 1

        // Color of the effect
        _VignetteColor("Vignette Color", Color) = (0,0,0,1)
    }

     SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include Unity's Common Graphics Library
            #include "UnityCG.cginc"

            struct appdata
            {
                // Vertex position
                float4 vertex : POSITION;

                // Texture coordinates
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                // Texture coordinates
                float2 uv : TEXCOORD0;

                // Screen space position
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
                // Transform vertex position to screen space
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Copy texture coordinates
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // Calculate position of current pixel relative to center of screen
                float2 center = (i.uv - 0.5) * _CenterSize;

                // Calculate vignette strength using smoothstep function
                float vignette = 1.0 - smoothstep(_VignetteRadius, 1.0, length(center) * 2.0);

                // Multiply the color by the vignette strength and intensity
                col.rgb *= vignette * (1.0 - _VignetteIntensity);

                // Add the vignette color to the color based on the vignette strength and intensity
                col.rgb += _VignetteColor.rgb * (1.0 - vignette) * _VignetteIntensity;

                return col;
            }
            ENDCG
        }
    }
}
