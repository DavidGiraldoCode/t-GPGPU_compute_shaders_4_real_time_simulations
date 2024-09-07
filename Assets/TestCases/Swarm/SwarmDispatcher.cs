using UnityEditor;
using UnityEngine;

public class SwarmDispatcher : MonoBehaviour
{
    [Tooltip("Declare an instance of the Compute shader assets")]
    [SerializeField] private ComputeShader m_swarmComputeShader;
    [Tooltip("The amount must be a possitive integer")]
    [SerializeField] private uint m_swarmCount = 0;
    [SerializeField] private GameObject m_prefab;
    private Transform[] m_gObjInstances;
    private int m_lineUpKernelId = 0;
    private int m_swarmKernelId = 0;
    private uint m_threadGroupXSize = 0;
    private ComputeBuffer m_positionsBF;
    private ComputeBuffer m_resultBF;
    /*
    The stride is the number of bytes from one row in memory to the next row in memory
    This is how much memory one item inside the buffer takes.
    */
    private int m_bufferStride;
    private int m_threadGroups;
    private Vector3[] m_positionsOUTPUT;

    private void Start()
    {
        m_lineUpKernelId = m_swarmComputeShader.FindKernel("LineUpObjects");
        m_swarmKernelId = m_swarmComputeShader.FindKernel("Swarm");

        m_swarmComputeShader.GetKernelThreadGroupSizes(m_lineUpKernelId, out m_threadGroupXSize, out _, out _);

        InitBuffer();

        m_positionsOUTPUT = new Vector3[(int)m_swarmCount];
        m_gObjInstances = new Transform[(int)m_swarmCount];

        for (int i = 0; i < m_swarmCount; i++)
        {
            m_gObjInstances[i] = Instantiate(m_prefab, transform).transform;
        }

        Debug.Log("m_threadGroupXSize: " + m_threadGroupXSize);
        Debug.Log("m_swarmCount:" + m_swarmCount);
        Debug.Log("m_threadGroups: " + (int)((m_swarmCount + (m_threadGroupXSize - 1)) / m_threadGroupXSize));
    }

    private void InitBuffer()
    {
        //Each iteam in the buffer is a vector in 3D, that needs 3 floats to store X, Y and Z
        int XYZ = 3;
        m_bufferStride = sizeof(float) * XYZ;

        //Instantiating a buffer is done by kernel, on the Compute Shader instance
        m_positionsBF = new ComputeBuffer((int)m_swarmCount, m_bufferStride);
        m_resultBF = new ComputeBuffer((int)m_swarmCount, m_bufferStride);
    }

    private void Update()
    {
        //LineUpObjectWithGPU();
        CreateSwarmGPU();
    }

    private void LineUpObjectWithGPU()
    {
        //Passing the Buffer from CPU world to the GPU world.
        m_swarmComputeShader.SetBuffer(m_lineUpKernelId, "PositionsBF", m_positionsBF);
        m_threadGroups = (int)((m_swarmCount + (m_threadGroupXSize - 1)) / m_threadGroupXSize);
        m_swarmComputeShader.Dispatch(m_lineUpKernelId, m_threadGroups, 1, 1); //Threadgruops size must be above 0

        m_positionsBF.GetData(m_positionsOUTPUT);

        for (int i = 0; i < m_gObjInstances.Length; i++)
        {
            m_gObjInstances[i].localPosition = m_positionsOUTPUT[i];
        }
    }

    private void CreateSwarmGPU()
    {
        //Passing the Buffer from CPU world to the GPU world.
        m_swarmComputeShader.SetFloat("Time", Time.time);

        m_swarmComputeShader.SetBuffer(m_swarmKernelId, "Result", m_resultBF);

        m_threadGroups = (int)((m_swarmCount + (m_threadGroupXSize - 1)) / m_threadGroupXSize);
        m_swarmComputeShader.Dispatch(m_swarmKernelId, m_threadGroups, 1, 1); //Threadgruops size must be above 0

        m_resultBF.GetData(m_positionsOUTPUT);

        for (int i = 0; i < m_gObjInstances.Length; i++)
        {
            m_gObjInstances[i].localPosition = m_positionsOUTPUT[i];
        }
    }

    private void DestroyBuffer()
    {
        //Disposing of the buffer is KEY to avoid memory leaks
        m_positionsBF.Dispose();
        m_resultBF.Dispose();
        //Release(); those the same thing, inside is calling .Dispose();
    }

    private void OnDestroy()
    {
        DestroyBuffer();
    }

}
