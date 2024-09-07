# Compute Shaders
It is a program, a piece of software that runs on the GPU and tells the hardware to do computations. It uses HSLS, GLSL, or CG. These programs perform tasks outside of the normal rendering pipeline.

## Structure
Compute shaders runs by dispatching them from CPU using `dipatch` function, as they are not attached to any mesh data (like vertex and fragment shaders).
In C#:
```C#
ComputeShader instance
instance.GetKernel()
instance.SetData() // This can be a texture of a buffer
instance.dispatch()
```

In the HLSL:
``` C 
kernel specification

reading variables

numthreads[#, #, #]

KernelDefinition
```

## Thread groups
The `.Dispatch(x,y,z)` function defines how may groups of threads (workgroups / threadgroups) will be spawn. And the `numthreads[x,y,z]` define how many thread will be on each group. </br>
So, for `.Dispatch(32, 32, 1)` and `numthreads[8,8,1]` the math goes as follows:</br>
$$(32 * 32 * 1)threadgroups * (8 * 8 * 1)threads = (1024) threadgroups * (64) threads = 65.536threads$$.

## Buffers
Buffers are well-defined containers of the same datatype and discrete size. A buffer needs to know how many items it will carry and the size of one single item. Items can be `structs` having all its members the same datatype.

```C
struct
{
    float scalar;
    float3 vector;
    float4 color;
    float4x4 matrix;
}
```

So, for a `struct` of type `float` which size is 4 bytes. Computing the size of that struct in memory goes as follow:
| Variable | floats | Times float size (4 bytes) |
| :------- | :----- | :------------------------- |
| scalar   | 1      | 4    |
| vector   | 3      | 12   |
| color    | 4      | 16   |
| matrix   | 16     | 64   |
|          | TOTAL  | 92 bytes   |

Getting data from the GPU to the CPU is expensive. Takes time. In Unity, this process of reading will wait until the kernel finishes. Blocking the main thread. Other methods like `AsycnGPUReadback()` will request the data in the background, so it can be use when is ready. But this introduces latency. Meaning, there will be frames in the simulation with any data.

K. Halladay (2014) gives an example of a kernel to compute a `vector x matrix` operation in the GPU as follows:
(This is a good candidate for computing how a vector field contributes in the velocity vector a boid in a simulation)
``` C
#pragma kernel Multiply

struct VecMatPair
{
	float3 pos;
	float4x4 mat;
};

RWStructuredBuffer<VecMatPair> dataBuffer;

[numthreads(16,1,1)]
void Multiply (uint3 id : SV_DispatchThreadID)
{
    dataBuffer[id.x].pos = mul(dataBuffer[id.x].mat, float4(dataBuffer[id.x].pos, 1.0));
}
```
```C#
public ComputeShader shader;

void RunShader()
{
	VecMatPair[] data = new VecMatPair[5];
	//INITIALIZE DATA HERE

	ComputeBuffer buffer = new ComputeBuffer(data.Length, 76);
	buffer.SetData(data);
	int kernel = shader.FindKernel("Multiply");
	shader.SetBuffer(kernel, "dataBuffer", buffer);
	shader.Dispatch(kernel, data.Length, 1,1);
}
```

```bash
"To dispatch the shader we first calculate how many threadgroups we need, in our case we want the amount of threads to be the length of the array, so the thread groups should be that amount divided by the thread size rounded up. When dealing with integers the easiest way of doing a division and getting the rounded up result is to add the divisor minus one before the division, that adds 1 to the result unless the dividend is a exact multiple of the divisor." Ronja (2020)
```
```C#
int threadGroups = (int) ((instanceCount + (threadGroupSize - 1)) / threadGroupSize);
```
Ronja, “Compute Shader.” Accessed: Sep. 07, 2024. [Online]. Available: https://www.ronja-tutorials.com/post/050-compute-shader/
