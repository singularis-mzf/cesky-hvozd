import argparse
from PIL import Image

# Set up argument parsing
parser = argparse.ArgumentParser(description="Generate an image from a color table.")
parser.add_argument("input_file", help="Path to the input file with the color table.")
parser.add_argument("output_image", help="Path to save the output image.")
args = parser.parse_args()

# Read the color table from the input file
color_table = []
with open(args.input_file, 'r') as file:
    for line in file:
        # Clean up the line by stripping out unwanted characters
        line = line.strip().replace('{', '').replace('}', '').replace('"', '').replace(' ', '')
        # Split the line by commas to get the individual hex colors
        row = line.split(',')
        # Filter out any empty strings
        row = [color for color in row if color]
        # Convert hex colors to RGB tuples, ensuring to remove the '#' symbol
        try:
            row = [tuple(int(hex_color.strip('#')[i:i+2], 16) for i in (0, 2, 4)) for hex_color in row]
        except ValueError as e:
            print(f"Error processing hex value: {e}")
            continue  # Skip invalid hex entries
        color_table.append(row)

# Check if color_table is empty
if not color_table:
    raise ValueError("No valid color data found in the input file.")

# Get the size of the image from the color table
height = len(color_table)
width = len(color_table[0])

# Create a new image with the given width and height
image = Image.new("RGB", (width, height))

# Fill the image with colors from the table
for y, row in enumerate(reversed(color_table)):  # Reverse Y to match the original logic
    for x, color in enumerate(row):
        image.putpixel((x, y), color)

# Save the image
image.save(args.output_image)

print(f"Image successfully created and saved as {args.output_image}")
