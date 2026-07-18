# Fixed-Point Bilinear Image Scaler in Verilog HDL

## Overview

This project implements a **4-stage pipelined bilinear image scaler** in **Verilog HDL** using **fixed-point arithmetic**. The design supports both **grayscale** and **RGB** image resizing with parameterizable input/output resolutions. A Python-based preprocessing and postprocessing flow is used to convert images to HEX format for simulation and reconstruct the resized output image.

---

## Features
* 4-stage pipelined architecture for high-throughput image scaling
* Fixed-point bilinear interpolation (Q8 format)
* Supports grayscale and RGB images
* Parameterizable input and output image resolutions
* Memory initialization using HEX files
* Python utilities for image-to-HEX and HEX-to-image conversion
* Fully verified using Xilinx Vivado Behavioral Simulation


## Pipeline Architecture
The image scaler consists of four pipeline stages:

### Stage 1: Coordinate Mapping

For every output pixel ((x_{out}, y_{out})), the corresponding input image coordinates are computed using fixed-point scaling factors.

The scaling factors are calculated as:

```text
scale_x = (W_IN << 8) / W_OUT
scale_y = (H_IN << 8) / H_OUT
```

The mapped input coordinates are then obtained as:

```text
x_in_fixed = x_out × scale_x
y_in_fixed = y_out × scale_y
```

The integer and fractional components are extracted as:

```text
x0 = x_in_fixed >> 8
y0 = y_in_fixed >> 8

a = x_in_fixed[7:0]
b = y_in_fixed[7:0]
```

where:

* `x0`, `y0` are the integer pixel locations.
* `a`, `b` represent the fractional distances used during interpolation.

---

### Stage 2: Memory Fetch

The four neighboring pixels required for bilinear interpolation are fetched from memory.

```text
I00 = (x0,     y0)
I10 = (x0 + 1, y0)
I01 = (x0,     y0 + 1)
I11 = (x0 + 1, y0 + 1)
```

Boundary checking is performed to ensure memory accesses remain within the valid image dimensions.

---

### Stage 3: Bilinear Interpolation

The output pixel intensity is computed using fixed-point bilinear interpolation.

```text
Pixel =
((256-a)(256-b)I00 +
 a(256-b)I10 +
(256-a)bI01 +
 abI11) >> 16
```

This computes a weighted average of the four neighboring pixels based on the fractional distances.

---

### Stage 4: Pixel Reconstruction

The interpolated pixel is written into the output image memory at the corresponding output coordinate.

After all output pixels have been processed, the output memory is exported as a HEX file using `$writememh()`.



## Fixed-Point Arithmetic
As we know divide is very expensive in hardware so to make it simple we use for FPGA use we make our project using Fixed point arthmetic.

Instead, this design uses an **8-bit fractional fixed-point (Q8) representation**, where the lower 8 bits represent the fractional component.


Multiplication is performed using integer arithmetic, and the result is scaled back by shifting right by 16 bits after interpolation.

This approach:

* Eliminates floating-point hardware.
* Reduces resource utilization.
* Improves synthesis efficiency.
* Maintains high interpolation accuracy for image scaling.


## Complete Workflow

```
Input Image (.png/.jpg/.gif)
          │
          ▼
Python (img_to_hex.py)
          │
          ▼
input.hex
          │
          ▼
Vivado Simulation
($readmemh)
          │
          ▼
4-Stage Bilinear Image Scaler
          │
          ▼
output.hex
($writememh)
          │
          ▼
Python (hex_to_image.py)
          │
          ▼
Output Image (.png)



## Results

The project successfully performs hardware-based bilinear image scaling using a 4-stage pipelined architecture. The generated output image is reconstructed from the simulated HEX output and verified against the expected resized image.

