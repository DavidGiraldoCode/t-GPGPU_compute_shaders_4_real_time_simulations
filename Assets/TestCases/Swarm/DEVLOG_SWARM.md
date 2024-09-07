# DevLog Swarm

- **2024-09-07:** 
- Managed to configure two diffenrent kernels, and buffers. Used the buffer data to update position of Game Objects on the scene.
- The kernel's index in retrieved using `.FindKernel("Name")`
- Theres a pattern of steps that one needs to keep in mind. It Is like a protocol.

The `SwarmDispatcher.cs` handles the setup of the compute shader and a buffer
```C#
// Declare Compute Shader Instance
// Declare Compute Buffer Instance

//Instantiate Buffer with the size and stride -> Heap allocation
//Instantiate Compute Shader by finding the asset (linked manually in Unity editor) 

// Set buffer and/or varibles to the specific kernel
// Dispatch Compute Shader
// Get data from buffer

//Destroy the buffer -> Heap deallocation
```
The `SwarmCompute.compute` defines the kernels
```C
// Declare kernel

// Declare buffers, textures or variables
// Declare helper functions

// Set number of threads
// Define kernel
```
- It is ideal to calculate the size of the thread group using Ronja's method of adding the size of the thread group - 1.
- For 1000 instances, 64 threads per group, 16 thread groups. Goes at 60 fps.
<img width="915" alt="Screenshot 2024-09-07 at 20 24 34" src="https://github.com/user-attachments/assets/4808be11-18f7-485e-8bb5-c75ec559e964">


# References:
Ronja, “Compute Shader.” Accessed: Sep. 07, 2024. [Online]. Available: https://www.ronja-tutorials.com/post/050-compute-shader/
