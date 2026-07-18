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

---

## Pipeline Architecture

The image scaler consists of four pipeline stages:

1. **Coordinate Mapping** – Computes input image coordinates corresponding to each output pixel using fixed-point arithmetic.
2. **Memory Fetch** – Fetches the four neighboring pixels (I00, I01, I10, I11) required for interpolation.
3. **Bilinear Interpolation** – Computes the interpolated pixel using fixed-point bilinear interpolation.
4. **Pixel Reconstruction** – Stores the computed pixel into the output image memory.


# Simulation Workflow

## Step 1: Install Python Dependencies

Install the required Python libraries.

```bash
pip install pillow numpy
```

---

## Step 2: Convert Input Image to HEX

Place the input image inside the Python folder and run:

```bash
python img_to_hex.py
```

This generates:

```
input.png
      ↓
input.hex
```

---

## Step 3: Load HEX File into Vivado

Copy **input.hex** into the Vivado simulation directory (or add it as a Simulation Source).

The Verilog module loads the image using:

```verilog
$readmemh("input.hex", input_image);
```

---

## Step 4: Run Behavioral Simulation

Launch Behavioral Simulation in Vivado.

The pipeline processes every output pixel through the following stages:

```
Coordinate Mapping
        ↓
Memory Fetch
        ↓
Bilinear Interpolation
        ↓
Pixel Reconstruction
```

After simulation completes, the output image is written using:

```verilog
$writememh("output.hex", output_image);
```

---

## Step 5: Convert HEX to Image

Copy **output.hex** to the Python folder and run:

```bash
python hex_to_image.py
```

The script reconstructs the resized image and generates:

```
output.hex
      ↓
output.png
```

---

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

