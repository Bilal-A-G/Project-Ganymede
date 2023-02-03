Shader "Unlit/LUT"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector]
        _LUTType("LUT Type {1, 2, 3}", int) = 1
        
        _Contribution("Contribution", float) = 1
        
        _LUT0("Warm LUT", 2D) = "white"{}
        _LUT1("Cold LUT", 2D) = "white"{}
        _LUT2("Cinematic LUT", 2D) = "white"{}
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
            #define COLORS 32.0
            
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
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 _LUT0_TexelSize;
            float4 _LUT1_TexelSize;
            float4 _LUT2_TexelSize;
            float _Contribution;
            sampler2D _LUT0;
            sampler2D _LUT1;
            sampler2D _LUT2;
            int _LUTType;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float maxColor = COLORS - 1.0;
                fixed4 col = saturate(tex2D(_MainTex, i.uv));
                
                float4 lutTexelSize = _LUT0_TexelSize;
                if(_LUTType == 2)
                {
                    lutTexelSize = _LUT1_TexelSize;
                }
                else if(_LUTType == 3)
                {
                    lutTexelSize = _LUT2_TexelSize;
                }
                
                float halfColX = 0.5 / lutTexelSize.z;
                float halfColY = 0.5 / lutTexelSize.w;
                float threshold = maxColor / COLORS;
 
                float xOffset = halfColX + col.r * threshold / COLORS;
                float yOffset = halfColY + col.g * threshold / COLORS;
                float cell = floor(col.b * maxColor);
 
                float2 lutPos = float2(cell / COLORS + xOffset, yOffset);

                float4 lut = tex2D(_LUT0, lutPos);
                if(_LUTType == 2)
                {
                    lut = tex2D(_LUT1, lutPos);
                }
                else if(_LUTType == 3)
                {
                    lut = tex2D(_LUT2, lutPos);
                }
                 
                return lerp(col, lut, _Contribution);
            }
            ENDCG
        }
    }
}
