Shader "Terrain"
{
    Properties
    {
        _Scale("Scale", Float) = 0
        _NormalStrength("NormalStrength", Float) = 0
        _BaseColour("BaseColour", Color) = (0, 0, 0, 0)
        _MapScale("MapScale", Float) = 0.3
        _FirstOctaveScale("FirstOctaveScale", Float) = 0.2
        _OctaveUVFalloff("OctaveUVFalloff", Float) = 0.2
        _HighDetailRange("HighDetailRange", Float) = 0
        _MediumDetailRange("MediumDetailRange", Float) = 0
        _PlayerPosition("PlayerPosition", Vector) = (0, 0, 0, 0)
        _MediumDetailFade("MediumDetailFade", Float) = 1
        _HighDetailFade("HighDetailFade", Float) = 0
        _Compensation("Compensation", Float) = 0
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType"="Opaque"
            "BuiltInMaterialType" = "Lit"
            "Queue"="Geometry"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="BuiltInLitSubTarget"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define BUILTIN_TARGET_API 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float4 interp6 : INTERP6;
             float4 interp7 : INTERP7;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
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
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            float3 NormalTS;
            half3 Emission;
            half Metallic;
            half Smoothness;
            half Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_a5cf3bbfe3344e718352683f2b30932e_Out_0 = _BaseColour;
            float _Split_1e09b3e132634eb680b40c51ca0647b2_R_1 = IN.WorldSpacePosition[0];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_G_2 = IN.WorldSpacePosition[1];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_B_3 = IN.WorldSpacePosition[2];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_A_4 = 0;
            float2 _Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0 = float2(_Split_1e09b3e132634eb680b40c51ca0647b2_R_1, _Split_1e09b3e132634eb680b40c51ca0647b2_B_3);
            half _Property_0459a49c37ca43f7a2a549a9b8b9b541_Out_0 = _MapScale;
            float2 _Divide_1954bc6941494390811f1c0e83051e93_Out_2;
            Unity_Divide_float2(_Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0, (_Property_0459a49c37ca43f7a2a549a9b8b9b541_Out_0.xx), _Divide_1954bc6941494390811f1c0e83051e93_Out_2);
            float _GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2;
            Unity_GradientNoise_float(_Divide_1954bc6941494390811f1c0e83051e93_Out_2, 1, _GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2);
            half _Property_64fda81c699e4373817273fcadd26583_Out_0 = _FirstOctaveScale;
            float2 _Multiply_5d84585864044effb05d725895c1cfe0_Out_2;
            Unity_Multiply_float2_float2(_Divide_1954bc6941494390811f1c0e83051e93_Out_2, (_Property_64fda81c699e4373817273fcadd26583_Out_0.xx), _Multiply_5d84585864044effb05d725895c1cfe0_Out_2);
            float _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2;
            Unity_GradientNoise_float(_Multiply_5d84585864044effb05d725895c1cfe0_Out_2, 8, _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2);
            float _Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2;
            Unity_Add_float(_GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2, _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2, _Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2);
            half _Property_6090b46e75314f36a23b1f202cb0ec7d_Out_0 = _MediumDetailRange;
            half2 _Property_283a070b73e344c2a213309a6516266b_Out_0 = _PlayerPosition;
            float _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2;
            Unity_Distance_float2(_Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0, _Property_283a070b73e344c2a213309a6516266b_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2);
            float _Subtract_bf1a9885233546459669f77e7806ac94_Out_2;
            Unity_Subtract_float(_Property_6090b46e75314f36a23b1f202cb0ec7d_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2, _Subtract_bf1a9885233546459669f77e7806ac94_Out_2);
            half _Property_237835a98c15415bbbd79e85cedf9e24_Out_0 = _MediumDetailFade;
            float _Divide_81a8f706daa94fc1accfcd627929e138_Out_2;
            Unity_Divide_float(_Subtract_bf1a9885233546459669f77e7806ac94_Out_2, _Property_237835a98c15415bbbd79e85cedf9e24_Out_0, _Divide_81a8f706daa94fc1accfcd627929e138_Out_2);
            float _Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3;
            Unity_Clamp_float(_Divide_81a8f706daa94fc1accfcd627929e138_Out_2, 0, 1, _Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3);
            half _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0 = _OctaveUVFalloff;
            float _Multiply_023c1f71385b41ca9156a1738d57442d_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_023c1f71385b41ca9156a1738d57442d_Out_2);
            float2 _Multiply_69cd36732c2e4f248412ed7e13428595_Out_2;
            Unity_Multiply_float2_float2(_Multiply_5d84585864044effb05d725895c1cfe0_Out_2, (_Multiply_023c1f71385b41ca9156a1738d57442d_Out_2.xx), _Multiply_69cd36732c2e4f248412ed7e13428595_Out_2);
            float _GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2;
            Unity_GradientNoise_float(_Multiply_69cd36732c2e4f248412ed7e13428595_Out_2, 16, _GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2);
            float _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2, 0.25, _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2);
            float _Add_2a39f64fb34c43f182a7dc01f030817a_Out_2;
            Unity_Add_float(_Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2, _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2, _Add_2a39f64fb34c43f182a7dc01f030817a_Out_2);
            float _Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2);
            float2 _Multiply_71beabef27984bb2be10e0cb743257b3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_69cd36732c2e4f248412ed7e13428595_Out_2, (_Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2.xx), _Multiply_71beabef27984bb2be10e0cb743257b3_Out_2);
            float _GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2;
            Unity_GradientNoise_float(_Multiply_71beabef27984bb2be10e0cb743257b3_Out_2, 36, _GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2);
            float _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2, 0.125, _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2);
            float _Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2;
            Unity_Add_float(_Add_2a39f64fb34c43f182a7dc01f030817a_Out_2, _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2, _Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2);
            float _Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2);
            float2 _Multiply_88967753799d4961ad53ed9a37d330d9_Out_2;
            Unity_Multiply_float2_float2(_Multiply_71beabef27984bb2be10e0cb743257b3_Out_2, (_Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2.xx), _Multiply_88967753799d4961ad53ed9a37d330d9_Out_2);
            float _GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2;
            Unity_GradientNoise_float(_Multiply_88967753799d4961ad53ed9a37d330d9_Out_2, 64, _GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2);
            float _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2;
            Unity_Multiply_float_float(_GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2, 0.0625, _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2);
            float _Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2;
            Unity_Add_float(_Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2, _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2, _Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2);
            float _Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2);
            float2 _Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2;
            Unity_Multiply_float2_float2(_Multiply_88967753799d4961ad53ed9a37d330d9_Out_2, (_Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2.xx), _Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2);
            float _GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2;
            Unity_GradientNoise_float(_Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2, 128, _GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2);
            float _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2;
            Unity_Multiply_float_float(_GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2, 0.03125, _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2);
            float _Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2;
            Unity_Add_float(_Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2, _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2, _Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2);
            half _Property_ca9ef43dd28346ae83cda8dd82d6e58c_Out_0 = _HighDetailRange;
            float _Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2;
            Unity_Subtract_float(_Property_ca9ef43dd28346ae83cda8dd82d6e58c_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2, _Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2);
            half _Property_4795c63855a24091861a4d3f53857628_Out_0 = _HighDetailFade;
            float _Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2;
            Unity_Divide_float(_Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2, _Property_4795c63855a24091861a4d3f53857628_Out_0, _Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2);
            float _Clamp_e10948d71b16445bae2d4003334d0282_Out_3;
            Unity_Clamp_float(_Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2, 0, 1, _Clamp_e10948d71b16445bae2d4003334d0282_Out_3);
            float _Multiply_f05df69af1754adab1328b57c646b534_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_f05df69af1754adab1328b57c646b534_Out_2);
            float2 _Multiply_341d69c5ea584eddaa27c39472018a10_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2, (_Multiply_f05df69af1754adab1328b57c646b534_Out_2.xx), _Multiply_341d69c5ea584eddaa27c39472018a10_Out_2);
            float _GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2;
            Unity_GradientNoise_float(_Multiply_341d69c5ea584eddaa27c39472018a10_Out_2, 256, _GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2);
            float _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2, 0.015625, _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2);
            float _Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2;
            Unity_Add_float(_Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2, _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2, _Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2);
            float _Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2);
            float2 _Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_341d69c5ea584eddaa27c39472018a10_Out_2, (_Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2.xx), _Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2);
            float _GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2;
            Unity_GradientNoise_float(_Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2, 512, _GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2);
            float _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2;
            Unity_Multiply_float_float(_GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2, 0.0078125, _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2);
            float _Add_0027c0b5d889408ab74ec267703c82bb_Out_2;
            Unity_Add_float(_Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2, _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2, _Add_0027c0b5d889408ab74ec267703c82bb_Out_2);
            float _Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2);
            float2 _Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2;
            Unity_Multiply_float2_float2(_Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2, (_Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2.xx), _Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2);
            float _GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2;
            Unity_GradientNoise_float(_Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2, 1024, _GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2);
            float _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2, 0.00390625, _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2);
            float _Add_01e0933b291d4b0c8cb673d48445796f_Out_2;
            Unity_Add_float(_Add_0027c0b5d889408ab74ec267703c82bb_Out_2, _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2, _Add_01e0933b291d4b0c8cb673d48445796f_Out_2);
            float _Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2);
            float2 _Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2;
            Unity_Multiply_float2_float2(_Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2, (_Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2.xx), _Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2);
            float _GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2;
            Unity_GradientNoise_float(_Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2, 2048, _GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2);
            float _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2, 0.001953125, _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2);
            float _Add_cfc5120df0bb475dbbe6e85f08075299_Out_2;
            Unity_Add_float(_Add_01e0933b291d4b0c8cb673d48445796f_Out_2, _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2, _Add_cfc5120df0bb475dbbe6e85f08075299_Out_2);
            half _Property_ad583389c1154bf8923bd0907ce852b0_Out_0 = _Compensation;
            float _Subtract_87bff49254f04f72920410d5af926c2d_Out_2;
            Unity_Subtract_float(_Add_cfc5120df0bb475dbbe6e85f08075299_Out_2, _Property_ad583389c1154bf8923bd0907ce852b0_Out_0, _Subtract_87bff49254f04f72920410d5af926c2d_Out_2);
            half _Property_d36a6083a57743e7ad9fece60b124e86_Out_0 = _Scale;
            float _Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2;
            Unity_Multiply_float_float(_Subtract_87bff49254f04f72920410d5af926c2d_Out_2, _Property_d36a6083a57743e7ad9fece60b124e86_Out_0, _Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2);
            half _Property_ae35c87c298649fcb076da794235f88e_Out_0 = _NormalStrength;
            float3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1;
            float3x3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2,_Property_ae35c87c298649fcb076da794235f88e_Out_0,_NormalFromHeight_0d9db52e52b744149646b35045c24721_Position,_NormalFromHeight_0d9db52e52b744149646b35045c24721_TangentMatrix, _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1);
            surface.BaseColor = (_Property_a5cf3bbfe3344e718352683f2b30932e_Out_0.xyz);
            surface.NormalTS = _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1;
            surface.Emission = half3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
        
        // Render State
        Blend SrcAlpha One, One One
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdadd_fullshadows
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD_ADD
        #define BUILTIN_TARGET_API 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float4 interp6 : INTERP6;
             float4 interp7 : INTERP7;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
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
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            float3 NormalTS;
            half3 Emission;
            half Metallic;
            half Smoothness;
            half Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_a5cf3bbfe3344e718352683f2b30932e_Out_0 = _BaseColour;
            float _Split_1e09b3e132634eb680b40c51ca0647b2_R_1 = IN.WorldSpacePosition[0];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_G_2 = IN.WorldSpacePosition[1];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_B_3 = IN.WorldSpacePosition[2];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_A_4 = 0;
            float2 _Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0 = float2(_Split_1e09b3e132634eb680b40c51ca0647b2_R_1, _Split_1e09b3e132634eb680b40c51ca0647b2_B_3);
            half _Property_0459a49c37ca43f7a2a549a9b8b9b541_Out_0 = _MapScale;
            float2 _Divide_1954bc6941494390811f1c0e83051e93_Out_2;
            Unity_Divide_float2(_Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0, (_Property_0459a49c37ca43f7a2a549a9b8b9b541_Out_0.xx), _Divide_1954bc6941494390811f1c0e83051e93_Out_2);
            float _GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2;
            Unity_GradientNoise_float(_Divide_1954bc6941494390811f1c0e83051e93_Out_2, 1, _GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2);
            half _Property_64fda81c699e4373817273fcadd26583_Out_0 = _FirstOctaveScale;
            float2 _Multiply_5d84585864044effb05d725895c1cfe0_Out_2;
            Unity_Multiply_float2_float2(_Divide_1954bc6941494390811f1c0e83051e93_Out_2, (_Property_64fda81c699e4373817273fcadd26583_Out_0.xx), _Multiply_5d84585864044effb05d725895c1cfe0_Out_2);
            float _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2;
            Unity_GradientNoise_float(_Multiply_5d84585864044effb05d725895c1cfe0_Out_2, 8, _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2);
            float _Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2;
            Unity_Add_float(_GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2, _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2, _Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2);
            half _Property_6090b46e75314f36a23b1f202cb0ec7d_Out_0 = _MediumDetailRange;
            half2 _Property_283a070b73e344c2a213309a6516266b_Out_0 = _PlayerPosition;
            float _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2;
            Unity_Distance_float2(_Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0, _Property_283a070b73e344c2a213309a6516266b_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2);
            float _Subtract_bf1a9885233546459669f77e7806ac94_Out_2;
            Unity_Subtract_float(_Property_6090b46e75314f36a23b1f202cb0ec7d_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2, _Subtract_bf1a9885233546459669f77e7806ac94_Out_2);
            half _Property_237835a98c15415bbbd79e85cedf9e24_Out_0 = _MediumDetailFade;
            float _Divide_81a8f706daa94fc1accfcd627929e138_Out_2;
            Unity_Divide_float(_Subtract_bf1a9885233546459669f77e7806ac94_Out_2, _Property_237835a98c15415bbbd79e85cedf9e24_Out_0, _Divide_81a8f706daa94fc1accfcd627929e138_Out_2);
            float _Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3;
            Unity_Clamp_float(_Divide_81a8f706daa94fc1accfcd627929e138_Out_2, 0, 1, _Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3);
            half _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0 = _OctaveUVFalloff;
            float _Multiply_023c1f71385b41ca9156a1738d57442d_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_023c1f71385b41ca9156a1738d57442d_Out_2);
            float2 _Multiply_69cd36732c2e4f248412ed7e13428595_Out_2;
            Unity_Multiply_float2_float2(_Multiply_5d84585864044effb05d725895c1cfe0_Out_2, (_Multiply_023c1f71385b41ca9156a1738d57442d_Out_2.xx), _Multiply_69cd36732c2e4f248412ed7e13428595_Out_2);
            float _GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2;
            Unity_GradientNoise_float(_Multiply_69cd36732c2e4f248412ed7e13428595_Out_2, 16, _GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2);
            float _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2, 0.25, _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2);
            float _Add_2a39f64fb34c43f182a7dc01f030817a_Out_2;
            Unity_Add_float(_Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2, _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2, _Add_2a39f64fb34c43f182a7dc01f030817a_Out_2);
            float _Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2);
            float2 _Multiply_71beabef27984bb2be10e0cb743257b3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_69cd36732c2e4f248412ed7e13428595_Out_2, (_Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2.xx), _Multiply_71beabef27984bb2be10e0cb743257b3_Out_2);
            float _GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2;
            Unity_GradientNoise_float(_Multiply_71beabef27984bb2be10e0cb743257b3_Out_2, 36, _GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2);
            float _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2, 0.125, _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2);
            float _Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2;
            Unity_Add_float(_Add_2a39f64fb34c43f182a7dc01f030817a_Out_2, _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2, _Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2);
            float _Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2);
            float2 _Multiply_88967753799d4961ad53ed9a37d330d9_Out_2;
            Unity_Multiply_float2_float2(_Multiply_71beabef27984bb2be10e0cb743257b3_Out_2, (_Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2.xx), _Multiply_88967753799d4961ad53ed9a37d330d9_Out_2);
            float _GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2;
            Unity_GradientNoise_float(_Multiply_88967753799d4961ad53ed9a37d330d9_Out_2, 64, _GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2);
            float _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2;
            Unity_Multiply_float_float(_GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2, 0.0625, _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2);
            float _Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2;
            Unity_Add_float(_Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2, _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2, _Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2);
            float _Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2);
            float2 _Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2;
            Unity_Multiply_float2_float2(_Multiply_88967753799d4961ad53ed9a37d330d9_Out_2, (_Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2.xx), _Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2);
            float _GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2;
            Unity_GradientNoise_float(_Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2, 128, _GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2);
            float _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2;
            Unity_Multiply_float_float(_GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2, 0.03125, _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2);
            float _Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2;
            Unity_Add_float(_Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2, _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2, _Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2);
            half _Property_ca9ef43dd28346ae83cda8dd82d6e58c_Out_0 = _HighDetailRange;
            float _Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2;
            Unity_Subtract_float(_Property_ca9ef43dd28346ae83cda8dd82d6e58c_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2, _Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2);
            half _Property_4795c63855a24091861a4d3f53857628_Out_0 = _HighDetailFade;
            float _Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2;
            Unity_Divide_float(_Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2, _Property_4795c63855a24091861a4d3f53857628_Out_0, _Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2);
            float _Clamp_e10948d71b16445bae2d4003334d0282_Out_3;
            Unity_Clamp_float(_Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2, 0, 1, _Clamp_e10948d71b16445bae2d4003334d0282_Out_3);
            float _Multiply_f05df69af1754adab1328b57c646b534_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_f05df69af1754adab1328b57c646b534_Out_2);
            float2 _Multiply_341d69c5ea584eddaa27c39472018a10_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2, (_Multiply_f05df69af1754adab1328b57c646b534_Out_2.xx), _Multiply_341d69c5ea584eddaa27c39472018a10_Out_2);
            float _GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2;
            Unity_GradientNoise_float(_Multiply_341d69c5ea584eddaa27c39472018a10_Out_2, 256, _GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2);
            float _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2, 0.015625, _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2);
            float _Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2;
            Unity_Add_float(_Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2, _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2, _Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2);
            float _Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2);
            float2 _Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_341d69c5ea584eddaa27c39472018a10_Out_2, (_Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2.xx), _Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2);
            float _GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2;
            Unity_GradientNoise_float(_Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2, 512, _GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2);
            float _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2;
            Unity_Multiply_float_float(_GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2, 0.0078125, _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2);
            float _Add_0027c0b5d889408ab74ec267703c82bb_Out_2;
            Unity_Add_float(_Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2, _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2, _Add_0027c0b5d889408ab74ec267703c82bb_Out_2);
            float _Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2);
            float2 _Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2;
            Unity_Multiply_float2_float2(_Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2, (_Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2.xx), _Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2);
            float _GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2;
            Unity_GradientNoise_float(_Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2, 1024, _GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2);
            float _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2, 0.00390625, _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2);
            float _Add_01e0933b291d4b0c8cb673d48445796f_Out_2;
            Unity_Add_float(_Add_0027c0b5d889408ab74ec267703c82bb_Out_2, _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2, _Add_01e0933b291d4b0c8cb673d48445796f_Out_2);
            float _Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2);
            float2 _Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2;
            Unity_Multiply_float2_float2(_Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2, (_Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2.xx), _Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2);
            float _GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2;
            Unity_GradientNoise_float(_Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2, 2048, _GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2);
            float _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2, 0.001953125, _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2);
            float _Add_cfc5120df0bb475dbbe6e85f08075299_Out_2;
            Unity_Add_float(_Add_01e0933b291d4b0c8cb673d48445796f_Out_2, _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2, _Add_cfc5120df0bb475dbbe6e85f08075299_Out_2);
            half _Property_ad583389c1154bf8923bd0907ce852b0_Out_0 = _Compensation;
            float _Subtract_87bff49254f04f72920410d5af926c2d_Out_2;
            Unity_Subtract_float(_Add_cfc5120df0bb475dbbe6e85f08075299_Out_2, _Property_ad583389c1154bf8923bd0907ce852b0_Out_0, _Subtract_87bff49254f04f72920410d5af926c2d_Out_2);
            half _Property_d36a6083a57743e7ad9fece60b124e86_Out_0 = _Scale;
            float _Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2;
            Unity_Multiply_float_float(_Subtract_87bff49254f04f72920410d5af926c2d_Out_2, _Property_d36a6083a57743e7ad9fece60b124e86_Out_0, _Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2);
            half _Property_ae35c87c298649fcb076da794235f88e_Out_0 = _NormalStrength;
            float3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1;
            float3x3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2,_Property_ae35c87c298649fcb076da794235f88e_Out_0,_NormalFromHeight_0d9db52e52b744149646b35045c24721_Position,_NormalFromHeight_0d9db52e52b744149646b35045c24721_TangentMatrix, _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1);
            surface.BaseColor = (_Property_a5cf3bbfe3344e718352683f2b30932e_Out_0.xyz);
            surface.NormalTS = _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1;
            surface.Emission = half3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn Deferred"
            Tags
            {
                "LightMode" = "Deferred"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma multi_compile_instancing
        #pragma exclude_renderers nomrt
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEFERRED
        #define BUILTIN_TARGET_API 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float4 interp6 : INTERP6;
             float4 interp7 : INTERP7;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
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
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            float3 NormalTS;
            half3 Emission;
            half Metallic;
            half Smoothness;
            half Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_a5cf3bbfe3344e718352683f2b30932e_Out_0 = _BaseColour;
            float _Split_1e09b3e132634eb680b40c51ca0647b2_R_1 = IN.WorldSpacePosition[0];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_G_2 = IN.WorldSpacePosition[1];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_B_3 = IN.WorldSpacePosition[2];
            float _Split_1e09b3e132634eb680b40c51ca0647b2_A_4 = 0;
            float2 _Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0 = float2(_Split_1e09b3e132634eb680b40c51ca0647b2_R_1, _Split_1e09b3e132634eb680b40c51ca0647b2_B_3);
            half _Property_0459a49c37ca43f7a2a549a9b8b9b541_Out_0 = _MapScale;
            float2 _Divide_1954bc6941494390811f1c0e83051e93_Out_2;
            Unity_Divide_float2(_Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0, (_Property_0459a49c37ca43f7a2a549a9b8b9b541_Out_0.xx), _Divide_1954bc6941494390811f1c0e83051e93_Out_2);
            float _GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2;
            Unity_GradientNoise_float(_Divide_1954bc6941494390811f1c0e83051e93_Out_2, 1, _GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2);
            half _Property_64fda81c699e4373817273fcadd26583_Out_0 = _FirstOctaveScale;
            float2 _Multiply_5d84585864044effb05d725895c1cfe0_Out_2;
            Unity_Multiply_float2_float2(_Divide_1954bc6941494390811f1c0e83051e93_Out_2, (_Property_64fda81c699e4373817273fcadd26583_Out_0.xx), _Multiply_5d84585864044effb05d725895c1cfe0_Out_2);
            float _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2;
            Unity_GradientNoise_float(_Multiply_5d84585864044effb05d725895c1cfe0_Out_2, 8, _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2);
            float _Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2;
            Unity_Add_float(_GradientNoise_e3222e3029b14775bc29cb85eadbf93d_Out_2, _GradientNoise_94cf460c6f954fa39482e757970fbb3a_Out_2, _Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2);
            half _Property_6090b46e75314f36a23b1f202cb0ec7d_Out_0 = _MediumDetailRange;
            half2 _Property_283a070b73e344c2a213309a6516266b_Out_0 = _PlayerPosition;
            float _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2;
            Unity_Distance_float2(_Vector2_688ff3558d354d118cf7c3d068ed139e_Out_0, _Property_283a070b73e344c2a213309a6516266b_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2);
            float _Subtract_bf1a9885233546459669f77e7806ac94_Out_2;
            Unity_Subtract_float(_Property_6090b46e75314f36a23b1f202cb0ec7d_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2, _Subtract_bf1a9885233546459669f77e7806ac94_Out_2);
            half _Property_237835a98c15415bbbd79e85cedf9e24_Out_0 = _MediumDetailFade;
            float _Divide_81a8f706daa94fc1accfcd627929e138_Out_2;
            Unity_Divide_float(_Subtract_bf1a9885233546459669f77e7806ac94_Out_2, _Property_237835a98c15415bbbd79e85cedf9e24_Out_0, _Divide_81a8f706daa94fc1accfcd627929e138_Out_2);
            float _Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3;
            Unity_Clamp_float(_Divide_81a8f706daa94fc1accfcd627929e138_Out_2, 0, 1, _Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3);
            half _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0 = _OctaveUVFalloff;
            float _Multiply_023c1f71385b41ca9156a1738d57442d_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_023c1f71385b41ca9156a1738d57442d_Out_2);
            float2 _Multiply_69cd36732c2e4f248412ed7e13428595_Out_2;
            Unity_Multiply_float2_float2(_Multiply_5d84585864044effb05d725895c1cfe0_Out_2, (_Multiply_023c1f71385b41ca9156a1738d57442d_Out_2.xx), _Multiply_69cd36732c2e4f248412ed7e13428595_Out_2);
            float _GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2;
            Unity_GradientNoise_float(_Multiply_69cd36732c2e4f248412ed7e13428595_Out_2, 16, _GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2);
            float _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0955c358cb6b40c7ba625a95bcaf0bc8_Out_2, 0.25, _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2);
            float _Add_2a39f64fb34c43f182a7dc01f030817a_Out_2;
            Unity_Add_float(_Add_f3b357ded5e04018a5c8cba21bbeb84b_Out_2, _Multiply_b23574bb9fbc4cd49dc42de90b0c8207_Out_2, _Add_2a39f64fb34c43f182a7dc01f030817a_Out_2);
            float _Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2);
            float2 _Multiply_71beabef27984bb2be10e0cb743257b3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_69cd36732c2e4f248412ed7e13428595_Out_2, (_Multiply_de93f0598f234bc98efb6a8cd9b505e6_Out_2.xx), _Multiply_71beabef27984bb2be10e0cb743257b3_Out_2);
            float _GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2;
            Unity_GradientNoise_float(_Multiply_71beabef27984bb2be10e0cb743257b3_Out_2, 36, _GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2);
            float _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6f2f8a267093455ebbb1e2c82175e97b_Out_2, 0.125, _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2);
            float _Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2;
            Unity_Add_float(_Add_2a39f64fb34c43f182a7dc01f030817a_Out_2, _Multiply_6bfb79b13c1646e1a18c3dfbfa023815_Out_2, _Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2);
            float _Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2);
            float2 _Multiply_88967753799d4961ad53ed9a37d330d9_Out_2;
            Unity_Multiply_float2_float2(_Multiply_71beabef27984bb2be10e0cb743257b3_Out_2, (_Multiply_e00ca1c8c91a41d18239fba9819b0999_Out_2.xx), _Multiply_88967753799d4961ad53ed9a37d330d9_Out_2);
            float _GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2;
            Unity_GradientNoise_float(_Multiply_88967753799d4961ad53ed9a37d330d9_Out_2, 64, _GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2);
            float _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2;
            Unity_Multiply_float_float(_GradientNoise_9b4ac22b1d704613ad3f112f36e123b6_Out_2, 0.0625, _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2);
            float _Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2;
            Unity_Add_float(_Add_74bb0bc2e509421d95f7801bfecd62ac_Out_2, _Multiply_a44e9e032c2d42f0a6c4ed7233c00275_Out_2, _Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2);
            float _Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2;
            Unity_Multiply_float_float(_Clamp_5fe047c595ef4a5cab07b6cff1568e4c_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2);
            float2 _Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2;
            Unity_Multiply_float2_float2(_Multiply_88967753799d4961ad53ed9a37d330d9_Out_2, (_Multiply_ab7a90b4ecde47ceb520ca16b2a4dbe6_Out_2.xx), _Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2);
            float _GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2;
            Unity_GradientNoise_float(_Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2, 128, _GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2);
            float _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2;
            Unity_Multiply_float_float(_GradientNoise_4cc0c25e31da4487a6b006886b788d8c_Out_2, 0.03125, _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2);
            float _Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2;
            Unity_Add_float(_Add_b7e09a53eb4243e4bcf66508449b36a1_Out_2, _Multiply_7b91eee133c4411cb5cc8d8b67954095_Out_2, _Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2);
            half _Property_ca9ef43dd28346ae83cda8dd82d6e58c_Out_0 = _HighDetailRange;
            float _Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2;
            Unity_Subtract_float(_Property_ca9ef43dd28346ae83cda8dd82d6e58c_Out_0, _Distance_16ae20d1b7e14b168abff7aa0293b1a5_Out_2, _Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2);
            half _Property_4795c63855a24091861a4d3f53857628_Out_0 = _HighDetailFade;
            float _Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2;
            Unity_Divide_float(_Subtract_4c67c3bb81ad44a399be80a9d5194dd0_Out_2, _Property_4795c63855a24091861a4d3f53857628_Out_0, _Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2);
            float _Clamp_e10948d71b16445bae2d4003334d0282_Out_3;
            Unity_Clamp_float(_Divide_6a47b7ac78554c13ad72dd0b4a214477_Out_2, 0, 1, _Clamp_e10948d71b16445bae2d4003334d0282_Out_3);
            float _Multiply_f05df69af1754adab1328b57c646b534_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_f05df69af1754adab1328b57c646b534_Out_2);
            float2 _Multiply_341d69c5ea584eddaa27c39472018a10_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c464f25c0244464984ccabe452ddb3aa_Out_2, (_Multiply_f05df69af1754adab1328b57c646b534_Out_2.xx), _Multiply_341d69c5ea584eddaa27c39472018a10_Out_2);
            float _GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2;
            Unity_GradientNoise_float(_Multiply_341d69c5ea584eddaa27c39472018a10_Out_2, 256, _GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2);
            float _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7d257657255348c6a73d4658157b4e0f_Out_2, 0.015625, _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2);
            float _Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2;
            Unity_Add_float(_Add_bea5a7c807fe4e19ae0505c02da79d0a_Out_2, _Multiply_9f5de9b402104667820d9a8c7e9341a2_Out_2, _Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2);
            float _Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2);
            float2 _Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_341d69c5ea584eddaa27c39472018a10_Out_2, (_Multiply_5ae52ad6d5d448cb86cded4d3475fa64_Out_2.xx), _Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2);
            float _GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2;
            Unity_GradientNoise_float(_Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2, 512, _GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2);
            float _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2;
            Unity_Multiply_float_float(_GradientNoise_5c3f9e97bf6f411896a22c2f6358a437_Out_2, 0.0078125, _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2);
            float _Add_0027c0b5d889408ab74ec267703c82bb_Out_2;
            Unity_Add_float(_Add_5dd4a69f10104c12b9962e2a0cf5dcf0_Out_2, _Multiply_d3009e3842c541b5b70ab001b02b9dfe_Out_2, _Add_0027c0b5d889408ab74ec267703c82bb_Out_2);
            float _Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2);
            float2 _Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2;
            Unity_Multiply_float2_float2(_Multiply_a53810748de64a1dbb4567cad525ef4d_Out_2, (_Multiply_afe0227a3b9b4b799811a7c5fcb9ff17_Out_2.xx), _Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2);
            float _GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2;
            Unity_GradientNoise_float(_Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2, 1024, _GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2);
            float _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0cff360c2c0e43308355df31a44f0f90_Out_2, 0.00390625, _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2);
            float _Add_01e0933b291d4b0c8cb673d48445796f_Out_2;
            Unity_Add_float(_Add_0027c0b5d889408ab74ec267703c82bb_Out_2, _Multiply_1625af4c44e044948f09ce22ca15938c_Out_2, _Add_01e0933b291d4b0c8cb673d48445796f_Out_2);
            float _Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2;
            Unity_Multiply_float_float(_Clamp_e10948d71b16445bae2d4003334d0282_Out_3, _Property_bf29d77efa434c33ad4b846899e9c2cd_Out_0, _Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2);
            float2 _Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2;
            Unity_Multiply_float2_float2(_Multiply_8d4ae043bc5a41c5a8be69e7003f9b50_Out_2, (_Multiply_54e0b45b67ae4753848717bcfde5e9a1_Out_2.xx), _Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2);
            float _GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2;
            Unity_GradientNoise_float(_Multiply_437e6f59efb2437da6a699b0dac9e713_Out_2, 2048, _GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2);
            float _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ce95687e6ac142b9a6ea8d2f2dd18d7e_Out_2, 0.001953125, _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2);
            float _Add_cfc5120df0bb475dbbe6e85f08075299_Out_2;
            Unity_Add_float(_Add_01e0933b291d4b0c8cb673d48445796f_Out_2, _Multiply_d511b2f9795c4b1f8883a486eff18aaf_Out_2, _Add_cfc5120df0bb475dbbe6e85f08075299_Out_2);
            half _Property_ad583389c1154bf8923bd0907ce852b0_Out_0 = _Compensation;
            float _Subtract_87bff49254f04f72920410d5af926c2d_Out_2;
            Unity_Subtract_float(_Add_cfc5120df0bb475dbbe6e85f08075299_Out_2, _Property_ad583389c1154bf8923bd0907ce852b0_Out_0, _Subtract_87bff49254f04f72920410d5af926c2d_Out_2);
            half _Property_d36a6083a57743e7ad9fece60b124e86_Out_0 = _Scale;
            float _Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2;
            Unity_Multiply_float_float(_Subtract_87bff49254f04f72920410d5af926c2d_Out_2, _Property_d36a6083a57743e7ad9fece60b124e86_Out_0, _Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2);
            half _Property_ae35c87c298649fcb076da794235f88e_Out_0 = _NormalStrength;
            float3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1;
            float3x3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            float3 _NormalFromHeight_0d9db52e52b744149646b35045c24721_Position = IN.WorldSpacePosition;
            Unity_NormalFromHeight_Tangent_float(_Multiply_3d4d7f7fabd7415baa7a1c7bd9eb6e1e_Out_2,_Property_ae35c87c298649fcb076da794235f88e_Out_0,_NormalFromHeight_0d9db52e52b744149646b35045c24721_Position,_NormalFromHeight_0d9db52e52b744149646b35045c24721_TangentMatrix, _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1);
            surface.BaseColor = (_Property_a5cf3bbfe3344e718352683f2b30932e_Out_0.xyz);
            surface.NormalTS = _NormalFromHeight_0d9db52e52b744149646b35045c24721_Out_1;
            surface.Emission = half3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_shadowcaster
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define BUILTIN_TARGET_API 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define BUILTIN_TARGET_API 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define BUILTIN_TARGET_API 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            half3 BaseColor;
            half3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_a5cf3bbfe3344e718352683f2b30932e_Out_0 = _BaseColour;
            surface.BaseColor = (_Property_a5cf3bbfe3344e718352683f2b30932e_Out_0.xyz);
            surface.Emission = half3(0, 0, 0);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.texcoord2  = attributes.uv2;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SceneSelectionPass
        #define BUILTIN_TARGET_API 1
        #define SCENESELECTIONPASS 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS ScenePickingPass
        #define BUILTIN_TARGET_API 1
        #define SCENEPICKINGPASS 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        half _Scale;
        half _NormalStrength;
        half4 _BaseColour;
        half _MapScale;
        half _FirstOctaveScale;
        half _OctaveUVFalloff;
        half _HighDetailRange;
        half _MediumDetailRange;
        half2 _PlayerPosition;
        half _MediumDetailFade;
        half _HighDetailFade;
        half _Compensation;
        CBUFFER_END
        
        // Object and Global properties
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float2(float2 A, float2 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            half3 Normal;
            half3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_R_1 = IN.ObjectSpacePosition[0];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_G_2 = IN.ObjectSpacePosition[1];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3 = IN.ObjectSpacePosition[2];
            float _Split_c1c491ed5cf844ba83f5b8729af5c852_A_4 = 0;
            float _Split_411b1489059e4e289503d118e22a0e32_R_1 = IN.WorldSpacePosition[0];
            float _Split_411b1489059e4e289503d118e22a0e32_G_2 = IN.WorldSpacePosition[1];
            float _Split_411b1489059e4e289503d118e22a0e32_B_3 = IN.WorldSpacePosition[2];
            float _Split_411b1489059e4e289503d118e22a0e32_A_4 = 0;
            float2 _Vector2_c7d5bd0783de442984143311b5998c51_Out_0 = float2(_Split_411b1489059e4e289503d118e22a0e32_R_1, _Split_411b1489059e4e289503d118e22a0e32_B_3);
            half _Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0 = _MapScale;
            float2 _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2;
            Unity_Divide_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, (_Property_a6454f92f8f84819b7dc77e8cf5dd816_Out_0.xx), _Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2);
            float _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2;
            Unity_GradientNoise_float(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, 1, _GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2);
            half _Property_9218349beecb4770a147d13853bc611d_Out_0 = _FirstOctaveScale;
            float2 _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2;
            Unity_Multiply_float2_float2(_Divide_a20bd09958704ea091e0733dd98c6d0a_Out_2, (_Property_9218349beecb4770a147d13853bc611d_Out_0.xx), _Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2);
            float _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2;
            Unity_GradientNoise_float(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, 8, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2);
            float _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2;
            Unity_Add_float(_GradientNoise_b34708e9a75a43ecafed1ecba79205f0_Out_2, _GradientNoise_609f71c41188457a86b3c7a17ec3569a_Out_2, _Add_ef2d89499b0c495bb9a382deeeb43259_Out_2);
            half _Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0 = _MediumDetailRange;
            half2 _Property_7fb3a532b94d478492d269c450d95e83_Out_0 = _PlayerPosition;
            float _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2;
            Unity_Distance_float2(_Vector2_c7d5bd0783de442984143311b5998c51_Out_0, _Property_7fb3a532b94d478492d269c450d95e83_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2);
            float _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2;
            Unity_Subtract_float(_Property_01c2ad3175ae465eaf8e3feef913f0c5_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_b47464fc9708486bafdd83d3d1918983_Out_2);
            half _Property_c35c52625e604128987e8961972ea5fe_Out_0 = _MediumDetailFade;
            float _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2;
            Unity_Divide_float(_Subtract_b47464fc9708486bafdd83d3d1918983_Out_2, _Property_c35c52625e604128987e8961972ea5fe_Out_0, _Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2);
            float _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3;
            Unity_Clamp_float(_Divide_59e22d3c9ac74db5a9619748f906c82d_Out_2, 0, 1, _Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3);
            half _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0 = _OctaveUVFalloff;
            float _Multiply_846b218948b043f396dd06abf271b4b4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_846b218948b043f396dd06abf271b4b4_Out_2);
            float2 _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_55b82db1c410403ca7d9ff7a6bfaa070_Out_2, (_Multiply_846b218948b043f396dd06abf271b4b4_Out_2.xx), _Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2);
            float _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2;
            Unity_GradientNoise_float(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, 16, _GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2);
            float _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2;
            Unity_Multiply_float_float(_GradientNoise_d2e88f00d5b44156be544082fd58ec2c_Out_2, 0.25, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2);
            float _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2;
            Unity_Add_float(_Add_ef2d89499b0c495bb9a382deeeb43259_Out_2, _Multiply_cd5a964ba2a545b5968d62dd6a0b6e76_Out_2, _Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2);
            float _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2);
            float2 _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2;
            Unity_Multiply_float2_float2(_Multiply_167e28ca11f1415993c8b37ae2014ef3_Out_2, (_Multiply_f231566f4e2d41e2a8b0684ff28222d0_Out_2.xx), _Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2);
            float _GradientNoise_b014ad997208465db5071426cf44feef_Out_2;
            Unity_GradientNoise_float(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, 36, _GradientNoise_b014ad997208465db5071426cf44feef_Out_2);
            float _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2;
            Unity_Multiply_float_float(_GradientNoise_b014ad997208465db5071426cf44feef_Out_2, 0.125, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2);
            float _Add_1da376c3e95c4b12967168aca82f1e50_Out_2;
            Unity_Add_float(_Add_207bb4fa30434c79bc42cd3b61fe4002_Out_2, _Multiply_d04827fd2a5e4147bff3fccc44fe5615_Out_2, _Add_1da376c3e95c4b12967168aca82f1e50_Out_2);
            float _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2);
            float2 _Multiply_e64797608690411b9a17a2081065e6ad_Out_2;
            Unity_Multiply_float2_float2(_Multiply_b4825d40dd6a412ea099f2b760e74320_Out_2, (_Multiply_861ead11d87e417a93e9d9f7d7f42ee4_Out_2.xx), _Multiply_e64797608690411b9a17a2081065e6ad_Out_2);
            float _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2;
            Unity_GradientNoise_float(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, 64, _GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2);
            float _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2;
            Unity_Multiply_float_float(_GradientNoise_7ca507eadb2143fdb45900af1fcf3412_Out_2, 0.0625, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2);
            float _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2;
            Unity_Add_float(_Add_1da376c3e95c4b12967168aca82f1e50_Out_2, _Multiply_dcf53d77b0f44814b538b62a9d28b518_Out_2, _Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2);
            float _Multiply_abde997b14e146bda98f75b286cb598e_Out_2;
            Unity_Multiply_float_float(_Clamp_34002ba7072346409aab4cf2b8d1c9cc_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_abde997b14e146bda98f75b286cb598e_Out_2);
            float2 _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2;
            Unity_Multiply_float2_float2(_Multiply_e64797608690411b9a17a2081065e6ad_Out_2, (_Multiply_abde997b14e146bda98f75b286cb598e_Out_2.xx), _Multiply_670824297e16421a8acd2919cc1bddb7_Out_2);
            float _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2;
            Unity_GradientNoise_float(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, 128, _GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2);
            float _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c8d4ac1d6fb5465796ae6776d7bfc282_Out_2, 0.03125, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2);
            float _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2;
            Unity_Add_float(_Add_0c2f9125d86b4a5d84e31468a2cae906_Out_2, _Multiply_85262668615046d2b7e7d7ce39cbbd90_Out_2, _Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2);
            half _Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0 = _HighDetailRange;
            float _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2;
            Unity_Subtract_float(_Property_7ed3c40791e942a5b262fcb7aec0119f_Out_0, _Distance_f019e8ffb6424614b8e179a92fd415fc_Out_2, _Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2);
            half _Property_833a2631c6cb4daba0459ace939d6eed_Out_0 = _HighDetailFade;
            float _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2;
            Unity_Divide_float(_Subtract_1c8daa44ee784c22bc4b94cce1504f6a_Out_2, _Property_833a2631c6cb4daba0459ace939d6eed_Out_0, _Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2);
            float _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3;
            Unity_Clamp_float(_Divide_71a8f1d659fa4d70bea5121bd0b887ec_Out_2, 0, 1, _Clamp_cad9ce56faef452089e69733f64cfee4_Out_3);
            float _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2);
            float2 _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2;
            Unity_Multiply_float2_float2(_Multiply_670824297e16421a8acd2919cc1bddb7_Out_2, (_Multiply_6095ecfd394b47ccab73f8eb124fd6a4_Out_2.xx), _Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2);
            float _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2;
            Unity_GradientNoise_float(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, 256, _GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2);
            float _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2;
            Unity_Multiply_float_float(_GradientNoise_6fd60fc261464bfd9270abbaa882d8c2_Out_2, 0.015625, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2);
            float _Add_59c159e7097d43f095c14e646902502b_Out_2;
            Unity_Add_float(_Add_ab6e9356543f4ce6872b2f7b0993582e_Out_2, _Multiply_9b87af7a1138444db61f5bbaf6a9909c_Out_2, _Add_59c159e7097d43f095c14e646902502b_Out_2);
            float _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2);
            float2 _Multiply_c38d32237f744b0ebff80342103439d3_Out_2;
            Unity_Multiply_float2_float2(_Multiply_56a2cb787ba4482d9330198ed6b194d1_Out_2, (_Multiply_c98f8b4bb6ef47a1bb66374a409ffa62_Out_2.xx), _Multiply_c38d32237f744b0ebff80342103439d3_Out_2);
            float _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2;
            Unity_GradientNoise_float(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, 512, _GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2);
            float _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2;
            Unity_Multiply_float_float(_GradientNoise_ec73fc5c0e034a59b0a4b883f246bc91_Out_2, 0.0078125, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2);
            float _Add_7bd3a62e953e4868aba1c983ce158658_Out_2;
            Unity_Add_float(_Add_59c159e7097d43f095c14e646902502b_Out_2, _Multiply_f020d40e7d0d494fa69b4b0b95f28282_Out_2, _Add_7bd3a62e953e4868aba1c983ce158658_Out_2);
            float _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2);
            float2 _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2;
            Unity_Multiply_float2_float2(_Multiply_c38d32237f744b0ebff80342103439d3_Out_2, (_Multiply_476e6065aaa248cc8ee4df19f03e549a_Out_2.xx), _Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2);
            float _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2;
            Unity_GradientNoise_float(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, 1024, _GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2);
            float _Multiply_82898cb1191749959e3884ba044ca295_Out_2;
            Unity_Multiply_float_float(_GradientNoise_0a7b4d4221dd446ba248e3c532259cc6_Out_2, 0.00390625, _Multiply_82898cb1191749959e3884ba044ca295_Out_2);
            float _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2;
            Unity_Add_float(_Add_7bd3a62e953e4868aba1c983ce158658_Out_2, _Multiply_82898cb1191749959e3884ba044ca295_Out_2, _Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2);
            float _Multiply_1758899bb4824d929593de3f31e01294_Out_2;
            Unity_Multiply_float_float(_Clamp_cad9ce56faef452089e69733f64cfee4_Out_3, _Property_4c611273da754a2b9f0bb0e08ff658d1_Out_0, _Multiply_1758899bb4824d929593de3f31e01294_Out_2);
            float2 _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2;
            Unity_Multiply_float2_float2(_Multiply_bf31b2e44c504ceb98e698869aa2048d_Out_2, (_Multiply_1758899bb4824d929593de3f31e01294_Out_2.xx), _Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2);
            float _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2;
            Unity_GradientNoise_float(_Multiply_bcfa3571df7a4afca848f5fcaae7506f_Out_2, 2048, _GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2);
            float _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2;
            Unity_Multiply_float_float(_GradientNoise_c20e4374580b439382d51d6cc17b6e75_Out_2, 0.001953125, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2);
            float _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2;
            Unity_Add_float(_Add_479ef0f43b7a4fe1aef5300886f3743e_Out_2, _Multiply_d4d8ae74ffba41559e0ba07c68bfebe6_Out_2, _Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2);
            half _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0 = _Compensation;
            float _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2;
            Unity_Subtract_float(_Add_6391cbeb20034810bc6bf6acf9c430e1_Out_2, _Property_5210685da1a94f2f9677d0923dd46ba8_Out_0, _Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2);
            half _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0 = _Scale;
            float _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2;
            Unity_Multiply_float_float(_Subtract_0e97667559fe4938a4c78b2cc445dffa_Out_2, _Property_aa88ec12120d4b969c411dcbc53e5832_Out_0, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2);
            float3 _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0 = float3(_Split_c1c491ed5cf844ba83f5b8729af5c852_R_1, _Multiply_3599064d72a24ba9b29eb9573aaaa3df_Out_2, _Split_c1c491ed5cf844ba83f5b8729af5c852_B_3);
            description.Position = _Vector3_84c4e24e4be040b1a8a90e0969059a9a_Out_0;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}