Shader "David/ShaderBasics/TextureSampler"
{
    Properties
    {

        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _AlphaMap("Alpha Map", 2D) = "white" {}
        _ScrollingYSpeed("Scrolling Y speed", Float) = 0.0
        _BaseColor("Color", Color) = (1,1,1,1)
        //Do not name a materia variable _MainTex as it is a reserved property name
    }
    SubShader
    {
        Tags 
        { 

            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline" 
        }
        //LOD 100
        Cull Off

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            //#pragma target 3.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexObject
            {
                float2 uv : TEXCOORD0;
                float2 uvBlend : TEXCOORD1;
                float4 position : POSITION;
                float4 normal : NORMAL;
            };

            struct FragmentObject
            {
                float2 uv : TEXCOORD0;
                float2 uvBlend : TEXCOORD1;
                float4 position : SV_POSITION;
            };

            //TEXTURE2D and the SAMPLER macros
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_AlphaMap);
            SAMPLER(sampler_AlphaMap);

            //Buffer for compatibility
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _AlphaMap_ST;
                float _ScrollingYSpeed;
                float4 _BaseColor;
            CBUFFER_END

            FragmentObject vert(VertexObject vertexInput)
            {
                FragmentObject vertOutput;

                //vertexInput.position.xyz += vertexInput.normal.xyz * _SinTime;

                //Initialization
                vertOutput.position = TransformObjectToHClip(vertexInput.position.xyz);
                vertOutput.uv = TRANSFORM_TEX(vertexInput.uv, _BaseMap);
                vertOutput.uvBlend = TRANSFORM_TEX(vertexInput.uvBlend, _AlphaMap);

                return vertOutput;
            }

            float4 frag(FragmentObject fragmentInput) : SV_Target
            {
                //fragmentInput.uv.x += _Time * 0.5 ;
                fragmentInput.uv.y += _Time * _ScrollingYSpeed;
                
                //SAMPLE_TEXTURE2D is a macro that wraps the functionality of samplying texture
                // allowing compatibility through different graphics APIs
                

                float4 finalPixel = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, fragmentInput.uv);

                //finalPixel.a = 0.1;


                return finalPixel;
            }

            ENDHLSL
        }
    }
}
