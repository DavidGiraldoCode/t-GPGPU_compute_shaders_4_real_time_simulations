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
The `.Dispatch(x,y,z)` function defines how may groups of threads (workgroups / threadgroups) will be spawn. And the `numthreads[x,y,z]` define how many thread will be on each group. So, for `.Dispatch(32, 32, 1)` and `numthreads[8,8,1]` the math goes as follows:
$$[32 x 32 x 1] x [8 x 8 x 1] = 1024 threadgroups x 64 threads = 65.536 threads in total$$.

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