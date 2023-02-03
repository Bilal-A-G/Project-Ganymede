Shader "Unlit/Fog"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white"{}
        _FogColour("Fog Colour", Color) = (1, 1, 1, 1)
        _FogFalloff("Fog Falloff", float) = 0
        _FogStrength("Fog Strength", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite Off ZTest Always
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionCS : POSITION;
                float2 uv : TEXCOORD0;
                float4 positionOS : TEXCOORD1;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 positionOS : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
                o.positionOS = v.positionOS;
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _FogColour;
            float _FogFalloff;
            float _FogStrength;

            fixed4 frag (v2f i) : SV_Target
            {
                float sceneDepth = tex2D(_CameraDepthTexture, i.uv).r * 4000;
                float fogFactor = pow(2, -pow(sceneDepth * (1/_FogFalloff), 2))/(1/_FogStrength);
                return (1 - fogFactor) * tex2D(_MainTex, i.uv) + fogFactor * _FogColour;
            }
            ENDCG
        }
    }
}
