using Unity.Collections;
using UnityEngine;
[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class ComputeDispatcher : MonoBehaviour
{
    [SerializeField] private ComputeShader m_ComputeShader;
    [SerializeField] private Transform m_painterShere;
    [SerializeField] private int m_paintingRadius;
    /*
    Mesh data
    */
    private Mesh m_mesh;
    private Material m_material;
    /*
    ID and Thread gruops data
    */
    private int m_MeshColoringKernelID;
    private uint m_threadGroupXSize;
    private int m_threadGroups;
    /*
    Data variables for the kernel
    */
    private ComputeBuffer m_vertexBuffer;
    private ComputeBuffer m_colorBuffer;
    private int m_vertexCount;

    //MonoBehaviour lifecyle
    private void Awake()
    {
        if (!m_ComputeShader)
        {
            throw new System.MissingFieldException("Compute Shader is missing on the ComputeDispatcher, add it on the Unity Editor");
        }
    }
    private void OnEnable()
    {
        m_mesh = GetComponent<MeshFilter>().sharedMesh;
        m_material = GetComponent<MeshRenderer>().sharedMaterial;
        m_vertexCount = m_mesh.vertexCount;
        SetUpComputeBuffer();
        SetUpKernel();
        SetUpKernelData();
    }
    private void Update()
    {
        UpdateKernelData();
    }

    private void OnDisable()
    {
        DiscardComputeBuffer();
    }
    private void OnDrawGizmos()
    {
        if (m_painterShere != null)
        {
            Gizmos.DrawWireSphere(m_painterShere.position, m_paintingRadius);
        }
    }

    // private methods:
    void SetUpKernel()
    {
        m_MeshColoringKernelID = m_ComputeShader.FindKernel("MeshColoring");
        m_ComputeShader.GetKernelThreadGroupSizes(m_MeshColoringKernelID, out m_threadGroupXSize, out _, out _);
        m_threadGroups = Mathf.CeilToInt((float)m_vertexCount / m_threadGroupXSize);

    }
    void SetUpKernelData()
    {
        GetMeshData(); //Get the vertices data for the buffer using Unity's manual memory allocation
        /*
        Bind the Buffers to the kernel and pass the vertex count
        Recall that the GPU knows nothing about the state of the application (CPU world)
        */
        m_ComputeShader.SetBuffer(m_MeshColoringKernelID, "_VertexBuffer", m_vertexBuffer);
        m_ComputeShader.SetBuffer(m_MeshColoringKernelID, "_ColorBuffer", m_colorBuffer);
        m_ComputeShader.SetInt("_VertexCount", m_vertexCount);

        /*
        Passing the color buffer (the one that the CS modifies) to the shader of a material to overide
        */
        m_material.SetBuffer("_ColorBuffer", m_colorBuffer);
    }

    void UpdateKernelData()
    {
        /*
        The vertices of the mesh are in local space, we need to apply the world space transformation matrix
        to be able to see the results properly as the mesh moves in the world.
        */
        m_ComputeShader.SetMatrix("_LocalToWorld", transform.localToWorldMatrix);
        /*
        Pass the position and the radious of influence, This represents a sphere
        */
        m_ComputeShader.SetVector("_Sphere", new Vector4(m_painterShere.position.x, m_painterShere.position.y, m_painterShere.position.z, m_paintingRadius));

        //Dispatch the Compute Shader to the GPU, specifying the kernel entry point.
        m_ComputeShader.Dispatch(m_MeshColoringKernelID, m_threadGroups, 1, 1);
    }

    void SetUpComputeBuffer()
    {
        m_vertexBuffer = new ComputeBuffer(m_vertexCount, sizeof(float) * 3, ComputeBufferType.Default, ComputeBufferMode.Immutable);
        m_colorBuffer = new ComputeBuffer(m_vertexCount, sizeof(float) * 4);
        /*
        ComputeBufferMode.Immutable: This means that the CPU will NOT modified the buffer.
        */
    }

    void DiscardComputeBuffer()
    {
        /*
        Disposing the buffer deallocates the heap memory
        */
        if (m_colorBuffer != null)
        {
            m_colorBuffer.Dispose();
            m_colorBuffer = null;
        }

        if (m_vertexBuffer != null)
        {
            m_vertexBuffer.Dispose();
            m_vertexBuffer = null;
        }

    }
    void GetMeshData()
    {
        //? What is `using`?
        /*
        using: This keyword ensures that unmanaged resources are correctly disposed of after use. 
        In this case, both meshDataArray and vertexArray implement IDisposable. 
        Once execution exits the using block, these objects are automatically disposed of, 
        releasing memory and avoiding potential memory leaks.
        */
        //? What is Mesh.AcquireReadOnlyMeshData(mesh)?
        /*
        This function is used to acquire read-only mesh data efficiently. 
        It returns a Mesh.MeshDataArray, which is an array containing data for multiple meshes, 
        but in this case, it only accesses a single mesh. So meshDataArray[0] is the first (and the only in this case) 
        element after the meshDataArray is retrieved, which contains the mesh data for further processing.
        */
        using (var meshDataArray = Mesh.AcquireReadOnlyMeshData(m_mesh))
        {
            var meshData = meshDataArray[0];
            //? What a NativeArray?
            /*
            Unity-Specific: Designed for Unity's high-performance systems like the Job System and Burst Compiler, not a general C# feature.
            Manual Memory Management: You must dispose of it manually using .Dispose() to avoid memory leaks.
            Unmanaged Memory: Operates outside of the .NET garbage collector for better performance and control.
            Performance-Optimized: Provides better memory alignment and efficiency, especially when working with large datasets (e.g., mesh data, physics).
            Fixed Size: Once created, the size of a NativeArray cannot be changed.
            Requires Allocator: Needs an explicit memory allocation type (e.g., Allocator.TempJob, Allocator.Persistent).

            Allocator.TempJob: The memory allocator used for this array. 
            "TempJob" means the memory will be allocated temporarily, useful for short-lived operations that are run within a job.

            NativeArrayOptions.UninitializedMemory: This option skips the zero-initialization of the memory 
            to improve performance since the array will be populated immediately after.
            */
            using (var vertexArray = new NativeArray<Vector3>(m_vertexCount, Allocator.TempJob, NativeArrayOptions.UninitializedMemory))
            {
                //This method takes a NativeArray and fills it with vertices, 3D vectors that represent points
                meshData.GetVertices(vertexArray);
                //Finally we pass the vertex data to the Buffer that will be sent to the GPU.
                m_vertexBuffer.SetData(vertexArray);
            }
        }
        // Here, the using blocks end and all the heap allocated memory is realeased.
    }

}