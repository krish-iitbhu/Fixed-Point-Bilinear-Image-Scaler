from PIL import Image
import numpy as np

# =====================================
# OUTPUT IMAGE SIZE
# =====================================

WIDTH  = 1024
HEIGHT = 1024

# =====================================
# STORE PIXELS
# =====================================

pixels = []

# =====================================
# READ OUTPUT HEX FILE
# =====================================

with open("output.hex", "r") as f:

    for line in f:

        value = line.strip()

        # replace unknown values
        if 'x' in value.lower():
            value = "00"

        pixels.append(int(value, 16))

# =====================================
# CONVERT TO NUMPY ARRAY
# =====================================

pixels = np.array(pixels, dtype=np.uint8)

# =====================================
# RESHAPE INTO IMAGE
# =====================================

img_array = pixels.reshape((HEIGHT, WIDTH))

# =====================================
# CREATE IMAGE
# =====================================

img = Image.fromarray(img_array)

# =====================================
# SAVE IMAGE
# =====================================

img.save("output.png")

print("====================================")
print("Output image generated successfully!")
print("Saved as output.png")
print("====================================")