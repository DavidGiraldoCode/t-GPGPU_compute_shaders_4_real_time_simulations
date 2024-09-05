using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeShaderDispatcher : MonoBehaviour
{
    [SerializeField] private ComputeShader m_computeShader;
    [SerializeField] private RenderTexture m_texture;
    [SerializeField] private GameObject m_cube;
    [SerializeField] private int m_cubeGridSize;
    private List<GameObject> m_cubes;
    private struct Cube
    {
        public Color color;
    }
    private Cube[] m_cubesData;
    private ComputeBuffer m_computeBuffer;
    private void Awake()
    {
        Debug.Log("Awake");
        m_texture = null;
        m_cubes = new List<GameObject>();
        int cubesCount = m_cubeGridSize * m_cubeGridSize;

        m_cubesData = new Cube[cubesCount];
        for (int i = 0; i < cubesCount; i++)
        {
            float x = 1 + i % m_cubeGridSize;
            float y = 1 + i / m_cubeGridSize % m_cubeGridSize;

            GameObject cube = Instantiate(m_cube, new Vector3(x, y, 0.0f), Quaternion.identity);
            Cube cubeData = new Cube();

            Color randomColor = Random.ColorHSV();
            cube.GetComponent<MeshRenderer>().material.color = randomColor;
            cubeData.color = randomColor;


            m_cubes.Add(cube);
            m_cubesData[i] = cubeData;


        }

        // m_texture = new RenderTexture(256, 256, 24);
        // m_texture.enableRandomWrite = true;
        // m_texture.Create();

        // m_computeShader.SetTexture(0, "Result", m_texture);
        // m_computeShader.Dispatch(0, m_texture.width / 8, m_texture.width / 8, 1);
        Debug.Log("Size of m_cubes: " + m_cubes.Count + " - size of m_cubesData: " + m_cubesData.Length);
        GPURandomizeCubesColor();
    }

    private void Update()
    {
        //CPURandomizeCubesColor();
        GPURandomizeCubesColor();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //! This is not working probably because of Metal on MacOS
        /*
        if (m_texture == null)
        {
            m_texture = new RenderTexture(256, 256, 24);
            m_texture.enableRandomWrite = true;
            m_texture.Create();
        }

        m_computeShader.SetTexture(0, "Result", m_texture);
        m_computeShader.SetFloat("Resolution", m_texture.width);
        m_computeShader.Dispatch(0, m_texture.width / 8, m_texture.height / 8, 1);

        Graphics.Blit(m_texture, dest);
        */
    }

    private void CPURandomizeCubesColor()
    {

        for (int i = 0; i < m_cubes.Count; i++)
        {
            GameObject cube = m_cubes[i];
            cube.GetComponent<MeshRenderer>().material.color = Random.ColorHSV();
        }
    }


    private void GPURandomizeCubesColor()
    {
        int colorSize = sizeof(float) * 4;
        m_computeBuffer = new ComputeBuffer(m_cubesData.Length, colorSize);

        m_computeBuffer.SetData(m_cubesData);

        m_computeShader.SetBuffer(0, "cubes", m_computeBuffer);
        m_computeShader.SetFloat("resolution", m_cubesData.Length);
        
        m_computeShader.Dispatch(0, m_cubesData.Length / 10, 1, 1);
        //m_computeShader.Dispatch(0, m_cubeGridSize / 8, m_cubeGridSize / 8, 1);

        m_computeBuffer.GetData(m_cubesData);

        for (int i = 0; i < m_cubes.Count; i++)
        {
            m_cubes[i].GetComponent<MeshRenderer>().material.color = m_cubesData[i].color;
        }

        m_computeBuffer.Release();

    }
}
