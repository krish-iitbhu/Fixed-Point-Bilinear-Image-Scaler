from PIL import Image
import numpy as np

# =====================================
# LOAD IMAGE
# =====================================

img = Image.open("input.gif")

# convert to grayscale
img = img.convert("L")

# =====================================
# CONVERT TO ARRAY
# =====================================

img_array = np.array(img)

H, W = img_array.shape

print("Width :", W)
print("Height:", H)

# =====================================
# WRITE HEX FILE
# =====================================

with open("input.hex", "w") as f:

    for y in range(H):
        for x in range(W):

            pixel = img_array[y, x]

            f.write(f"{pixel:02X}\n")

print("HEX file generated successfully!")