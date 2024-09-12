Shader "Unlit/Displacement"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            //"RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline"
            //"LightMode" = "ForwardBase"
        }
        //LOD 100
        Cull Off
        //ZTest Always
        //Offset 0, -1
        Pass
        {
            // Disable depth test so all layers render
            //ZTest Always
            //Offset 1, 1
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexInput
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0; //Semantics conveys information about the intended use of a parameter. 
                
            };

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float3 normal   : TEXCOORD1;
                float2 uv       : TEXCOORD0;
                
            };

            int _LayerCount;
            int _LayerIndex;

            VertexOutput vert(VertexInput input)
            {

                float shellHeight = (float)_LayerIndex / (float)_LayerCount; //(float)_ShellIndex / (float)_ShellCount;
                //float shellHeight = (float)1 / (float)2;

                float distanceAtenuation = 2.5;
                shellHeight = pow(shellHeight, distanceAtenuation);  // f(y) =x^{2.5} => x is the shellHeight and exponent is a user defined value of atenuation.

                float shellLenght = 0.2;
                float displacementForceAlongNormal = shellLenght * shellHeight;//0.0;

                input.vertex.xyz += input.normal.xyz * displacementForceAlongNormal;//shellLenght * shellHeight;

                VertexOutput output;
                
                output.normal = normalize(TransformObjectToWorldNormal(input.normal));
                output.position = TransformObjectToHClip(input.vertex.xyz);

                output.uv = input.uv;

                return output;
            }

            float4 frag(VertexOutput output) : SV_TARGET
            {

                return float4(1.0,1.0,1.0,0.5);
            }

            ENDHLSL
        }
    }
}
