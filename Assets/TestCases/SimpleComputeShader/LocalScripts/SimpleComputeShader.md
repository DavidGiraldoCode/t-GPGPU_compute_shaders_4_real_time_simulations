# Simple Compute Shader

## DevLog 2024 Sep 5
Based on the YT video, a compute shader was implemented to compute random colors. Using a buffer, an array was sent to the GPU, which computed the results. The data was retrieved on the CPU to set new colors on the meshes.
The comparison yielded no meaningful results. Being the CPU even faster. Further analysis of the distribution of workgroups on the Dispatch function must be conducted.
A possible cause is that the cubes are instantiated by the CPU as GameObjects. Perhaps, by using GPU instancing, the performance would improve.

# Ref
- [Getting Started with Compute Shaders in Unity](https://youtu.be/BrZ4pWwkpto?si=QgHm8hmmWkE7ifUw)