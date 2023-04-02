Shader "Custom/Terrain"
{
    Properties
    {
        _Colour ("Colour", color) = (1, 1, 1, 1)
        _AmbientStrength ("Ambient Strength", float) = 0.0
        _DiffuseStrength ("Diffuse Strength", float) = 0.0
        
        _Tessellation ("Maximum Tessellation", Range(1, 64)) = 0.0
        
        _MaxDistance("Maximum Distance (Tessellation)", float) = 0.0
        
        _Octaves("Octaves", int) = 0
        _OctaveAmplitudeFalloff("Octave Ampliude Falloff", float) = 0.0
        _OctaveUVFalloff("Octave UV Falloff", float) = 0.0
        _BaseScale("Base Scale", Range(2, 5)) = 0.0
        _MapScale("Map Scale", float) = 0.0
        _HeightScale("Height Scale", float) = 0.0
        _Compensation("Compensation", float) = 0.0
        
        _NormalStrength("Normal Strength", float) = 0.0
        [HideInInspector]
        _DoLighting("Do Lighting", int) = 1
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" }
            CGPROGRAM
            
            #pragma target 5.0
            
            #pragma vertex vert
            #pragma hull hull
            #pragma domain domain
            #pragma fragment frag
            
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

            };
            
            struct TesselationControlPoints
            {
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 positionOS : INTERNALTESSPOS;
            };

            TesselationControlPoints vert (appdata IN)
            {
                TesselationControlPoints output;
                
                output.normal = mul(unity_ObjectToWorld, IN.normal);
                output.tangent = mul(unity_ObjectToWorld, IN.tangent);
                output.positionOS = IN.vertex;
                
                return output;
            }
            
            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("fractional_odd")]
            [UNITY_patchconstantfunc("patchFunction")]
            TesselationControlPoints hull(InputPatch<TesselationControlPoints, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            struct TesselationFactors
            {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
            };

            float _Tessellation;
            float _MaxDistance;

            float GetEdgeFactor(TesselationControlPoints cp0, TesselationControlPoints cp1)
            {
                float4 p0 = mul(unity_ObjectToWorld, cp0.positionOS);
                float4 p1 = mul(unity_ObjectToWorld, cp1.positionOS);
                
                float edgeDistanceToCamera = (distance(p0, _WorldSpaceCameraPos) + distance(p1, _WorldSpaceCameraPos))/2;
                float interpolator = edgeDistanceToCamera/_MaxDistance;
                interpolator = clamp(interpolator, 0, 1);

                float lerp = (1 - interpolator) * _Tessellation + interpolator;
                return lerp;
            }

            TesselationFactors patchFunction(InputPatch<TesselationControlPoints, 3> patch)
            {
                TesselationFactors factors;
                
                factors.edge[0] = GetEdgeFactor(patch[1], patch[2]);
                factors.edge[1] = GetEdgeFactor(patch[2], patch[0]);
                factors.edge[2] = GetEdgeFactor(patch[0], patch[1]);
                factors.inside = (factors.edge[0] + factors.edge[1] + factors.edge[2]) * 0.33f;
                
                return factors;
            }

            struct Interpolators
            {
                float3 normal : NORMAL;
                float4 positionOS : TEXCOORD0;
                float4 tangent : TANGENT;
                float4 pos : SV_POSITION;
            };
            
            int _Octaves;
            float _OctaveAmplitudeFalloff;
            float _OctaveUVFalloff;
            float _BaseScale;
            float _MapScale;
            float _Compensation;
            float _HeightScale;
            
            sampler2D _HeightMap;
            
            [UNITY_domain("tri")]
            Interpolators domain(TesselationFactors factors, OutputPatch<TesselationControlPoints, 3> patch,
                float3 barycentricCoordinates : SV_DomainLocation)
            {
                Interpolators output;
                
                output.normal = patch[0].normal * barycentricCoordinates.x +
                        patch[1].normal * barycentricCoordinates.y +
                        patch[2].normal * barycentricCoordinates.z;

                output.tangent = patch[0].tangent * barycentricCoordinates.x +
                        patch[1].tangent * barycentricCoordinates.y +
                        patch[2].tangent * barycentricCoordinates.z;
                
                output.positionOS = patch[0].positionOS * barycentricCoordinates.x +
                        patch[1].positionOS * barycentricCoordinates.y +
                        patch[2].positionOS * barycentricCoordinates.z;

                float displacement = tex2Dlod(_HeightMap, float4(-output.positionOS.xz * 0.5f + 0.5f, 0, 0)).r;
                output.pos = UnityObjectToClipPos(output.positionOS + float4(0, displacement, 0, 0));
                
                return output;
            }

            float _AmbientStrength;
            float _DiffuseStrength;
            float _NormalStrength;
            int _DoLighting;
            float4 _Colour;

            float4 frag (Interpolators IN) : SV_Target
            {
                float3 newNormal;
                float tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
                float3 wBitangent = cross(IN.normal, IN.tangent) * tangentSign;
                float3x3 tangentSpaceMatrix = float3x3
                (
                    float3(IN.tangent.x, wBitangent.x, IN.normal.x),
                    float3(IN.tangent.y, wBitangent.y, IN.normal.y),
                    float3(IN.tangent.z, wBitangent.z, IN.normal.z)
                );

                float displacement = tex2D(_HeightMap, -IN.positionOS.xz * 0.5f + 0.5f).r;

                Unity_NormalFromHeight_Tangent_float(displacement,
                    _NormalStrength, IN.positionOS, tangentSpaceMatrix, newNormal);


                float3 diffuse = max(0, dot(newNormal, normalize(_WorldSpaceLightPos0)) * _DiffuseStrength);
                float3 ambient = float3(1, 1, 1) * _AmbientStrength;

                float3 colour = float4(1, 1, 1, 1);
                
                if(_DoLighting == 1)
                    colour = ambient + diffuse;
                
                return float4(colour.rgb * _Colour, 0);
            }
            
            ENDCG
        }
        Pass 
        {
            //Horrible code duplication here
			Tags {
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM
            #pragma target 5.0
            
            #pragma vertex vert
            #pragma hull hull
            #pragma domain domain
            #pragma fragment frag

			#pragma multi_compile_shadowcaster
			#include "UnityStandardShadow.cginc"

			
			struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };
            
            struct TesselationControlPoints
            {
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 positionOS : INTERNALTESSPOS;
            };

            TesselationControlPoints vert (appdata IN)
            {
                TesselationControlPoints output;
                
                output.normal = mul(unity_ObjectToWorld, IN.normal);
                output.tangent = mul(unity_ObjectToWorld, IN.tangent);
                output.positionOS = IN.vertex;
                
                return output;
            }
            
            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("fractional_odd")]
            [UNITY_patchconstantfunc("patchFunction")]
            TesselationControlPoints hull(InputPatch<TesselationControlPoints, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            struct TesselationFactors
            {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
            };

            float _Tessellation;
            float _MaxDistance;

            float GetEdgeFactor(TesselationControlPoints cp0, TesselationControlPoints cp1)
            {
                float4 p0 = mul(unity_ObjectToWorld, cp0.positionOS);
                float4 p1 = mul(unity_ObjectToWorld, cp1.positionOS);
                
                float edgeDistanceToCamera = (distance(p0, _WorldSpaceCameraPos) + distance(p1, _WorldSpaceCameraPos))/2;
                float interpolator = edgeDistanceToCamera/_MaxDistance;
                interpolator = clamp(interpolator, 0, 1);

                float lerp = (1 - interpolator) * _Tessellation + interpolator;
                return lerp;
            }

            TesselationFactors patchFunction(InputPatch<TesselationControlPoints, 3> patch)
            {
                TesselationFactors factors;
                
                factors.edge[0] = GetEdgeFactor(patch[1], patch[2]);
                factors.edge[1] = GetEdgeFactor(patch[2], patch[0]);
                factors.edge[2] = GetEdgeFactor(patch[0], patch[1]);
                factors.inside = (factors.edge[0] + factors.edge[1] + factors.edge[2]) * 0.33f;
                
                return factors;
            }

            struct Interpolators
            {
                float4 positionOS : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            
            sampler2D _HeightMapS;
            
            [UNITY_domain("tri")]
            Interpolators domain(TesselationFactors factors, OutputPatch<TesselationControlPoints, 3> patch,
                float3 barycentricCoordinates : SV_DomainLocation)
            {
                Interpolators output;

                output.positionOS = patch[0].positionOS * barycentricCoordinates.x +
                        patch[1].positionOS * barycentricCoordinates.y +
                        patch[2].positionOS * barycentricCoordinates.z;

                float displacement = tex2Dlod(_HeightMapS, float4(-output.positionOS.xz * 0.5f + 0.5f, 0, 0)).r;
                output.pos = UnityObjectToClipPos(output.positionOS + float4(0, displacement, 0, 0));
                
                return output;
            }

            float4 frag (Interpolators IN) : SV_Target
            {
                return float4(1, 1, 1, 1);
            }
            
            ENDCG
		}
    }
}