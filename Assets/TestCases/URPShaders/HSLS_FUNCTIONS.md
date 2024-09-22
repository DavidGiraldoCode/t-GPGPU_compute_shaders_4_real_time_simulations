# A thorought explanationg of some HSLS functions

The `frac()` function in HLSL (High-Level Shading Language) is used to return the fractional part of a floating-point value. Mathematically, it works by subtracting the floor value of the input from the input itself, which effectively removes the integer part of the number and leaves only the fractional component.

### Summary of `frac()` Behavior:
- It always returns a value between `[0.0, 1.0)`, where the fractional part is isolated from the input.
- For negative numbers, the fractional part is still positive, because `frac()` wraps around by subtracting the floor of the number.
- It works element-wise for vectors.

### Syntax:
```hlsl
float frac(float x);
float2 frac(float2 x);
float3 frac(float3 x);
float4 frac(float4 x);
```

It works for scalars (`float`), as well as vectors like `float2`, `float3`, and `float4`. For vectors, `frac()` operates element-wise.

### Example Explanation:

1. **Single Float Example**:
   ```hlsl
   float result = frac(2.75);
   ```
   - Input: `2.75`
   - Operation: `2.75 - floor(2.75) = 2.75 - 2 = 0.75`
   - Result: `0.75`
   
   **Explanation**: The integer part (`2`) is removed, leaving only the fractional part (`0.75`).

2. **Negative Float Example**:
   ```hlsl
   float result = frac(-1.25);
   ```
   - Input: `-1.25`
   - Operation: `-1.25 - floor(-1.25) = -1.25 - (-2) = 0.75`
   - Result: `0.75`
   
   **Explanation**: The fractional part for negative values is still positive, because the floor of `-1.25` is `-2`, and subtracting results in `0.75`.

3. **Zero Input**:
   ```hlsl
   float result = frac(0.0);
   ```
   - Input: `0.0`
   - Operation: `0.0 - floor(0.0) = 0.0 - 0 = 0.0`
   - Result: `0.0`
   
   **Explanation**: There’s no fractional part for `0.0`, so the result is `0.0`.

4. **Float2 Example**:
   ```hlsl
   float2 result = frac(float2(1.75, 3.5));
   ```
   - Input: `float2(1.75, 3.5)`
   - Operation: 
     - For `1.75`: `frac(1.75) = 1.75 - floor(1.75) = 0.75`
     - For `3.5`: `frac(3.5) = 3.5 - floor(3.5) = 0.5`
   - Result: `float2(0.75, 0.5)`
   
   **Explanation**: Each component of the vector is handled independently, and their fractional parts are extracted.

5. **Large Value Example**:
   ```hlsl
   float result = frac(123.456);
   ```
   - Input: `123.456`
   - Operation: `123.456 - floor(123.456) = 123.456 - 123 = 0.456`
   - Result: `0.456`
   
   **Explanation**: The integer part (`123`) is removed, leaving the fractional part (`0.456`).

6. **Exact Integer Input**:
   ```hlsl
   float result = frac(5.0);
   ```
   - Input: `5.0`
   - Operation: `5.0 - floor(5.0) = 5.0 - 5 = 0.0`
   - Result: `0.0`
   
   **Explanation**: Since the input is an exact integer, the result is `0.0` because there's no fractional part.