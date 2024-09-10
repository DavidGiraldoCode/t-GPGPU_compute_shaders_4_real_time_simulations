// Shader file for the Universal Render Pipeline

Shader "Unlit/PaintedObject"
{
    Properties
    {
        // Define any shader properties here if needed
        _ColorBuffer("Color Buffer", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "FORWARD"

            // Import the URP core shader library
            HLSLPROGRAM

            // Specify the vertex and fragment shader functions
            #pragma vertex vert
            #pragma fragment frag

            // Include the URP shader library
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Structure for input data to the vertex shader
            struct appdata_t
            {
                // Vertex position in object space
                float4 vertex : POSITION;

                // Vertex ID for accessing the color buffer, this match the vertices on the buffer from the Compute Shader
                uint id : SV_VertexID;
            };

            // Structure for data passed from the vertex(v) shader to(2) the fragment(f) shader, this is the color buffer
            struct v2f
            {
                // Transformed vertex position in clip space
                float4 pos : SV_POSITION;

                // Color data from the buffer
                float4 color : COLOR;
            };

            // Declare the structured buffer for the color data that is 
            Texture2D<float4> _ColorBuffer;//Texture2D
            

            // Vertex shader function
            v2f vert(appdata_t v)
            {
                v2f o;

                // Transform vertex position from object space to clip space
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex); //Previously TransformObjectToHClip

                // Retrieve color from the texture using the vertex ID
                o.color = _ColorBuffer.Load(v.id);

                return o;
            }

            // Fragment shader function
            float4 frag(v2f i) : SV_Target
            {
                // Output the color value
                return i.color;
            }

            ENDHLSL
        }
    }
}