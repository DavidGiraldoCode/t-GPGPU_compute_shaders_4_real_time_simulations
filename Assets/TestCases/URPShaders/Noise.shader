Shader "Unlit/Noise"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline"
            //"LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float hash(uint n)
            {
				// integer hash copied from Hugo Elias
				n = (n << 13U) ^ n;
				n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
				return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
			}

            struct VertexInput
            {
                float4 position : POSITION;
                float2 uv       : TEXCOORD0; //Semantics conveys information about the intended use of a parameter. 
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float2 uv       : TEXCOORD0;
            };

            VertexOutput vert(VertexInput input)
            {

                VertexOutput output;
                output.position = TransformObjectToHClip(input.position.xyz);
                output.uv = input.uv;

                return output;
            }

            float4 frag(VertexOutput output) : SV_TARGET
            {

                float2 scaledUV = output.uv * 80;
                float2 localUV = frac(scaledUV) * 2 - 1;
                //float2 localUV = (output.uv) * 2 - 1;
                
                float localDistanceFromCenter = length(localUV); // Returns the magnitud of a vector https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-length
                uint2 tid = scaledUV;
				uint seed = tid.x + 100 * tid.y + 100 * 10;

                float shellIndex = 0;
                float shellCount = 1;

                float rand = lerp(0, 1, hash(seed)); // Lerps between x0 and x1 by s https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-lerp

                float h = shellIndex / shellCount;

                int outsideThickness = (localDistanceFromCenter) > (1 * (rand - h));

                //if (outsideThickness) discard; //&& _ShellIndex > 0)

                //Use this to Debbug the noise.
                float4 color = float4(rand,rand,rand,1);

                //Use this to Debbug localUV
                //float4 color = float4(localUV.x,localUV.y,0,1);

                //Use this to Debbug the reading of a texture and location of the UVs.
                //float4 color = float4(output.uv.x,0,output.uv.y,1);
                
                return color;
            }

            ENDHLSL

        }
    }
}
