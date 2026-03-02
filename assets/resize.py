# 1x -> 2x automatic no-input scaling

# Heavily modified version of similar script committed by MathIsFun
# https://github.com/MathIsFun0/Cryptid/blob/main/assets/2x/resize.py

# Requires Pillow to be installed

import os
from pathlib import Path
from PIL import Image

def upscale_pixel_art(input_image, output_directory, input_image_path):
    # Double the size
    new_size = (int(input_image.width * 2), int(input_image.height * 2))
    resized_image = input_image.resize(new_size, Image.NEAREST)  # NEAREST resampling preserves pixelation

    # Save the resized image
    filename = os.path.basename(input_image_path)
    output_image_path = os.path.join(output_directory, filename)
    resized_image.save(output_image_path)

# Get paths of folders
directory_assets = os.path.dirname(__file__) # Parent of parent of this very file
directory_1x = os.path.join(directory_assets, "1x")

# Copy directory structure of 1x and scale images within
for (dirpath, dirnames, filenames) in os.walk(directory_1x):
    directory_2x = Path(dirpath.replace("1x", '2x'))

    if not os.path.exists(directory_2x):
        directory_2x.mkdir()

    for filename in filenames:
        if filename.split(".")[-1] != "png": continue
        input_image_path = os.path.join(dirpath, filename)
        input_image = Image.open(input_image_path)
        upscale_pixel_art(input_image, directory_2x, input_image_path)