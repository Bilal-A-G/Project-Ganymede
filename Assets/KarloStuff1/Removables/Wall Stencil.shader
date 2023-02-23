Shader "Custom/Wall Stencil"
{
    Properties
    {
        _MainTex("Diffuse", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
        SubShader
    {
        Tags { "Queue" = "Geometry" }

        Stencil
        {
            // Set the stencil reference value to 1
            Ref 1

            // Pass the stencil test if the reference value is not equal to the current value
            Comp notequal

            // Keep the current value in the stencil buffer
            Pass keep
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        float4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * _Color.rgb;
        }
        ENDCG
    }
        FallBack "Diffuse"
}
