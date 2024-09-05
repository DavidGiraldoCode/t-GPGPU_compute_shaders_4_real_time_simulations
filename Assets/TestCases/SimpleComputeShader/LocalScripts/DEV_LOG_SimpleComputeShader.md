# DevLog Simple Compute Shader

## 2024 Sep 5 - Color randomizer
Based on the YT video, a compute shader was implemented to compute random colors. Using a buffer, an array was sent to the GPU, which computed the results. The data was retrieved on the CPU to set new colors on the meshes. </br>
The comparison yielded no meaningful results. Being the CPU even faster. Further analysis of the distribution of workgroups on the Dispatch function must be conducted. </br>
- CPU (left) / GPU (right)
<img width="448" alt="CPU" src="https://github.com/user-attachments/assets/2f0d4b0c-8f7e-4b7e-a065-e74307e1d6f3">
<img width="448" alt="GPU" src="https://github.com/user-attachments/assets/92502b98-c782-4b10-bef1-43829551bbae">

A possible cause is that the cubes are instantiated by the CPU as GameObjects. Perhaps, by using GPU instancing, the performance would improve.

# Ref
- [Getting Started with Compute Shaders in Unity](https://youtu.be/BrZ4pWwkpto?si=QgHm8hmmWkE7ifUw)
