import argparse
from PIL import Image
import os

# Set up argument parsing
parser = argparse.ArgumentParser(description="Process an image and generate a color table.")
parser.add_argument("image_path", help="Path to the image file.")
parser.add_argument("output_path", help="Path to save the output file.")
args = parser.parse_args()

# Load the image
image = Image.open(args.image_path)

# Convert image to RGB format
image = image.convert("RGB")

# Get image size
width, height = image.size

# Initialize an empty color table
color_table = []

# Iterate through the image pixels and create the color table, reverse Y axis
for y in reversed(range(height)):
    row = []
    for x in range(width):
        pixel = image.getpixel((x, y))
        # Convert RGB to HEX and add quotes
        hex_color = '"#' + '{:02x}{:02x}{:02x}'.format(pixel[0], pixel[1], pixel[2]) + '"'
        row.append(hex_color)
    color_table.append(row)

# Save the color table to the output file in the desired format
output_file = args.output_path
with open(output_file, 'w') as file:
    for row in color_table:
        formatted_row = "{" + ','.join(row) + "},"
        file.write(formatted_row + '\n')

print(f"Color table successfully saved to {output_file}")
