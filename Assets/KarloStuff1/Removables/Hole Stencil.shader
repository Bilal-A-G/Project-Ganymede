Shader "Custom/Hole Stencil"
{
    Properties
    {
        _MainTex("Diffuse", 2D) = "white" {}
    }

    SubShader
    {
        // Use the "Geometry-1" rendering queue, which is a low-priority queue
        Tags { "Queue" = "Geometry-1" }

        // Disable writing to the color buffer and to the depth buffer
        ColorMask 0
        ZWrite off

        // Configure the stencil buffer
        Stencil
        {
            // Set the stencil reference value to 1
            Ref 1

            // Always pass the stencil test
            Comp always

            // Replace the stencil buffer value with the reference value
            Pass replace
        }

    CGPROGRAM
    #pragma surface surf Lambert
    sampler2D _MainTex;

    struct Input
    {
        float2 uv_MainTex;
    };

    void surf(Input IN, inout SurfaceOutput o)
    {
        fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
        o.Albedo = c.rgb;
    }
    ENDCG
    }
    FallBack "Diffuse"
}
