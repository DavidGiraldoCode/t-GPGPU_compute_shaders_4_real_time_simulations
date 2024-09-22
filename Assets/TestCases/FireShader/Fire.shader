Shader "David/VFX/Fire"
{
    Properties
    {
        [MainTexture] _BaseMap ("BaseMap", 2D) = "white" {}
        _DisplacementTex ("DisplacementTex", 2D) = "white" {}
        _DownUpMask ("DownUpMask", 2D) = "white" {}
        _ArcMask ("ArcMask", 2D) = "white" {}
        _DisplacementSpeed ("Displacement speed", Float) = 1
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "RenderType"="Transparent"
        }
        //LOD 100
        //Blend SrcAlpha One
        Blend SrcAlpha OneMinusSrcAlpha
        //Blend One OneMinusSrcAlpha
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert;
            #pragma fragment frag;

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/writing-shaders-urp-unlit-texture.html
            //TODO study why you need TEXTURE2D, what it does, and why is important
            //Macro for Texture sampling in URP, define in Core.hlsl
            TEXTURE2D(_BaseMap); // Define a texture
            SAMPLER(sampler_BaseMap); // Define the sampler
            TEXTURE2D(_DisplacementTex);
            SAMPLER(sampler_DisplacementTex);
            TEXTURE2D(_DownUpMask);
            SAMPLER(sampler_DownUpMask);
            TEXTURE2D(_ArcMask);
            SAMPLER(sampler_ArcMask);
            
            //TODO study why the texture has an _ST at the end.
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST; //_ST suffix is necesarry because some Macros use it
                float4 _DisplacementTex_ST;
                float4 _DownUpMask_ST;
                float4 _ArcMask_ST;
                float _DisplacementSpeed;
            CBUFFER_END

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvDisplacement : TEXCOORD1;
            };

            struct FragmentData
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvDisplacement : TEXCOORD1;
            };

            FragmentData vert(MeshData mesh)
            {
                FragmentData fragmentData;

                fragmentData.position = TransformObjectToHClip(mesh.vertex.xyz);

                 //TODO Study TRANSFORM_TEX
                 // This Macro applies offset and tiling transformation 
                 // Looks like this -> #define TRANSFORM_TEX(tex, name) ((tex.xy) * name##_ST.xy + name##_ST.zw)
                fragmentData.uv = TRANSFORM_TEX(mesh.uv, _BaseMap);
                fragmentData.uvDisplacement = TRANSFORM_TEX(mesh.uvDisplacement, _DisplacementTex);

                return fragmentData;
            };

            float4 frag( FragmentData fragmentData) : SV_Target
            {
                

                //fragmentData.uv.y -= _Time * _DisplacementSpeed;

                fragmentData.uvDisplacement.y -= _Time * _DisplacementSpeed;
                //Macro to sample the texture, The texture, the sampler and the coordinate of the vertex
                float4 displacementSample = SAMPLE_TEXTURE2D(_DisplacementTex, sampler_DisplacementTex, fragmentData.uvDisplacement);

                //fragmentData.uvDisplacement.y -= _Time * _DisplacementSpeed * 1.2;
                float4 displacementByTwoSample = SAMPLE_TEXTURE2D(_DisplacementTex, sampler_DisplacementTex, fragmentData.uvDisplacement * 4);
                float4 maskSample = SAMPLE_TEXTURE2D(_DownUpMask, sampler_DownUpMask, fragmentData.uv);
                float4 arcMaskSample = SAMPLE_TEXTURE2D(_ArcMask, sampler_ArcMask, fragmentData.uv);

                // fragmentData.uv.y += displacementSample.r * 0.1;
                // fragmentData.uv.x += displacementSample.r * 0.1;

                // |MD> = |M> + |D> * scalar
                fragmentData.uv.xy += displacementSample.xy * 0.03;

                fragmentData.uv.xy += displacementByTwoSample.xy * 0.06;

                //fragmentData.uv.y -= _Time * _DisplacementSpeed;

                float4 baseMapSample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, fragmentData.uv);
                baseMapSample.a *= (1- maskSample.r); //* 8.1;
                baseMapSample.a *= (arcMaskSample.r);

                if(baseMapSample.b > 0) discard;
                
                float4 outterFireColor = float4(baseMapSample.r, 0.5, 0, baseMapSample.a);
                float4 innerFireColor = float4(0.6, baseMapSample.g, 0 , baseMapSample.a);

                float4 fragmetColor = outterFireColor + innerFireColor;

                return fragmetColor;
            };

            ENDHLSL
        }
    }
}
