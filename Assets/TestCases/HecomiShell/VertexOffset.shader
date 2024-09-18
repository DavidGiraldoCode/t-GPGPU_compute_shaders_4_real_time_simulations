Shader "Custom/VertexOffset"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _OffsetAmount ("Offset Amount", Range(0.0, 1.0)) = 0.1
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" }
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // Include Unity's common shader libraries
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Uniform variables
            float4 _BaseColor;
            float _OffsetAmount;

            struct VertexInput
            {
                float4 vertex : POSITION; // Object space position
                float3 normal : NORMAL;   // Object space normal
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION; // Clip space position
                float3 worldPos : TEXCOORD0;   // World space position
                float3 normal : TEXCOORD1;     // World space normal
            };

            // Vertex Shader
            VertexOutput vert(VertexInput input)
            {
                VertexOutput output;

                // Transform vertex position to world space
                float3 worldPos = TransformObjectToWorld(input.vertex.xyz);

                // Offset the position along the normal based on _OffsetAmount
                worldPos += input.normal * _OffsetAmount;

                // Output to the vertex shader
                output.position = TransformWorldToHClip(worldPos);
                output.worldPos = worldPos;
                output.normal = TransformObjectToWorldNormal(input.normal);

                return output;
            }

            // Fragment Shader
            float4 frag(VertexOutput input) : SV_Target
            {
                // Simple coloring based on base color
                return _BaseColor;
            }

            ENDHLSL
        }
    }

    // Fallback
    Fallback Off
}

