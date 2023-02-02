Shader "Custom/Terrain"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
        _AmbientStrength ("Ambient Strength", float) = 0.0
        _DiffuseStrength ("Diffuse Strength", float) = 0.0
        
        _Tessellation ("Tessellation", float) = 0.0
        
        _MinDistance("Minimum Distance (Tesselation)", float) = 0.0
        _MaxDistance("Maximum Distance (Tesselation)", float) = 0.0
        
        _Octaves("Octaves", int) = 0
        _OctaveAmplitudeFalloff("Octave Ampliude Falloff", float) = 0.0
        _OctaveUVFalloff("Octave UV Falloff", float) = 0.0
        _FirstOctaveScale("First Octave Scale", float) = 0.0
        _BaseScale("Base Scale", Range(2, 5)) = 0.0
        _MapScale("Map Scale", float) = 0.0
        
        _NormalStrength("Normal Strength", float) = 0.0
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            float _Tessellation;
            float _MinDistance;
            float _MaxDistance;

            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }
            float3 SafeNormalize(float3 inVec)
            {
                float dp3 = max(1.175494351e-38, dot(inVec, inVec));
                return inVec * rsqrt(dp3);
            }
            float3 TransformWorldToTangent(float3 dirWS, float3x3 tangentToWorld)
            {
                // Note matrix is in row major convention with left multiplication as it is build on the fly
                float3 row0 = tangentToWorld[0];
                float3 row1 = tangentToWorld[1];
                float3 row2 = tangentToWorld[2];

                // these are the columns of the inverse matrix but scaled by the determinant
                float3 col0 = cross(row1, row2);
                float3 col1 = cross(row2, row0);
                float3 col2 = cross(row0, row1);

                float determinant = dot(row0, col0);
                float sgn = determinant<0.0 ? (-1.0) : 1.0;

                // inverse transposed but scaled by determinant
                // Will remove transpose part by using matrix as the first arg in the mul() below
                // this makes it the exact inverse of what TransformTangentToWorld() does.
                float3x3 matTBN_I_T = float3x3(col0, col1, col2);

                return SafeNormalize( sgn * mul(matTBN_I_T, dirWS) );
            }
            void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
            {
                float3 worldDerivativeX = ddx(Position);
                float3 worldDerivativeY = ddy(Position);
                    
                float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
                float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
                float d = dot(worldDerivativeX, crossY);
                float sgn = d < 0.0 ? (-1.0f) : 1.0f;
                float surface = sgn / max(0.000000000000001192093f, abs(d));
                    
                float dHdx = ddx(In);
                float dHdy = ddy(In);
                float3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
                Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
                Out = TransformWorldToTangent(Out, TangentMatrix);
            }
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 normal : TEXCOORD0;
                float3 objectSpacePosition : TEXCOORD1;
                float4 tangent : TANGENT;

                float4 vertex : SV_POSITION;
            };
            
            int _Octaves;
            float _OctaveAmplitudeFalloff;
            float _OctaveUVFalloff;
            float _BaseScale;
            float _MapScale;
            
            float _NormalStrength;

            v2f vert (appdata IN)
            {
                v2f output;
                float displacement = 0.0f;
                
                for(int i = 1; i < _Octaves + 1; i++)
                {
                    float noise = 0.0f;
                    float4 worldSpaceVertex = mul(unity_ObjectToWorld, IN.vertex) /_MapScale;
                    
                    Unity_GradientNoise_float(float2(worldSpaceVertex.x, worldSpaceVertex.z) * _OctaveUVFalloff, pow(_BaseScale, i + 1), noise);
                    displacement += noise * 1/pow(_BaseScale, i) * _OctaveAmplitudeFalloff;
                }
                
                output.vertex = UnityObjectToClipPos(IN.vertex + float4(0, displacement, 0, 0));
                output.normal = mul(unity_ObjectToWorld, IN.normal);
                output.tangent = mul(unity_ObjectToWorld, IN.tangent);
                output.objectSpacePosition = IN.vertex;
                return output;
            }

            float4 _Colour;
            float _AmbientStrength;
            float _DiffuseStrength;

            float4 frag (v2f IN) : SV_Target
            {
                float displacement = 0.0f;
                
                for(int i = 1; i < _Octaves + 1; i++)
                {
                    float noise = 0.0f;
                    float4 worldSpaceVertex = mul(unity_ObjectToWorld, IN.objectSpacePosition) /_MapScale;
                    
                    Unity_GradientNoise_float(float2(worldSpaceVertex.x, worldSpaceVertex.z) * _OctaveUVFalloff, pow(_BaseScale, i + 1), noise);
                    displacement += noise * 1/pow(_BaseScale, i) * _OctaveAmplitudeFalloff;
                }

                float3 newNormal;
                float tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
                float3 wBitangent = cross(IN.normal, IN.tangent) * tangentSign;
                float3x3 tangentSpaceMatrix = float3x3
                (
                    float3(IN.tangent.x, wBitangent.x, IN.normal.x),
                    float3(IN.tangent.y, wBitangent.y, IN.normal.y),
                    float3(IN.tangent.z, wBitangent.z, IN.normal.z)
                );

                Unity_NormalFromHeight_Tangent_float(displacement, _NormalStrength, IN.objectSpacePosition, tangentSpaceMatrix, newNormal);


                float3 diffuse = max(0, dot(newNormal, normalize(_WorldSpaceLightPos0)) * _DiffuseStrength);
                float3 ambient = float3(1, 1, 1) * _AmbientStrength;
                
                float3 colour = ambient + diffuse;
                return float4(colour.rgb * _Colour, 0);
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}