Shader "Custom/Outline"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
        _OutlineColour ("Outline Colour", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", float) = 1
        [HideInInspector]
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float2 uv_MainTex;
        };
        
        sampler2D _MainTex;
        float4 _Colour;

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Colour;
            o.Albedo = c.rgb;
        }
        ENDCG
        
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float4 colour : COLOR;
            };

            float4 _OutlineColour; 
            float _OutlineWidth;

            v2f vert (appdata i)
            {
                v2f o;
                o.position = UnityObjectToClipPos(i.position);
                float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, i.normal));
                float2 offset = TransformViewToProjection(normal.xy);

                o.position.xy += offset * o.position.z * _OutlineWidth;
                o.colour = _OutlineColour;

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return i.colour;
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
