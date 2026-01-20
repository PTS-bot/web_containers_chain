import matplotlib.pyplot as plt
import matplotlib.patches as patches
import json

# Load the JSON data from the uploaded file
with open('board-test2.json', 'r') as f:
    data = json.load(f)

# Create a figure
fig, ax = plt.subplots(figsize=(10, 12))
ax.invert_yaxis() # Invert Y axis to match screen coordinates
ax.set_aspect('equal')
ax.axis('off') # Turn off axes for a clean image

# Iterate through drawing elements
for key, item in data.items():
    color = item.get('color', '#000000')
    size = item.get('size', 2)
    
    if item['type'] == 'line':
        if '_children' in item:
            xs = [p['x'] for p in item['_children']]
            ys = [p['y'] for p in item['_children']]
            ax.plot(xs, ys, color=color, linewidth=size, solid_capstyle='round')
            
    elif item['type'] == 'ellipse':
        # Calculate width, height and center from bounding box (x,y to x2,y2)
        x = item.get('x', 0)
        y = item.get('y', 0)
        x2 = item.get('x2', 0)
        y2 = item.get('y2', 0)
        
        width = abs(x2 - x)
        height = abs(y2 - y)
        center_x = x + (x2 - x) / 2
        center_y = y + (y2 - y) / 2
        
        ellipse = patches.Ellipse((center_x, center_y), width, height, 
                                  edgecolor=color, facecolor='none', linewidth=size)
        ax.add_patch(ellipse)

# Save the figure
output_filename = 'reconstructed_board.png'
plt.savefig(output_filename, bbox_inches='tight', dpi=300)
plt.close()

print(f"Image saved as {output_filename}")