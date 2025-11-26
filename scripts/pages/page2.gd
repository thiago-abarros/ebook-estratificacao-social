extends "res://scripts/pages/page_navigation.gd"

@onready var watering_can = $MainContainer/WateringCan
@onready var tree_floor = $MainContainer/TreeFloor
@onready var instruction = $MainContainer/Instruction
@onready var drop_spawner = $MainContainer/WateringCan/DropSpawner

@onready var poor_tree_1 = $MainContainer/TreesContainer/PoorTree1
@onready var rich_tree = $MainContainer/TreesContainer/RichTree
@onready var poor_tree_2 = $MainContainer/TreesContainer/PoorTree2

@onready var text_balloon = $MainContainer/TextBalloon
@onready var audio_player = $AudioStreamPlayer

var is_dragging = false
var initial_position = Vector2.ZERO
var drag_offset = Vector2.ZERO
var target_position = Vector2.ZERO
var drag_smoothing = 15.0

# Watering state
var is_watering = false
var interaction_completed = false
var spawn_timer = 0.0
var spawn_interval = 0.15 # Seconds between drops

var water_drop_scene = preload("res://scenes/components/water_drop.tscn")

# Tree Growth
var poor_growth = 0.0
var rich_growth = 0.0
var growth_speed = 0.5 # Progress per second

# Textures
var poor_tree_textures = [
	preload("res://assets/images/animations/page2/poor-tree/poor-tree1.png"),
	preload("res://assets/images/animations/page2/poor-tree/poor-tree2.png"),
	preload("res://assets/images/animations/page2/poor-tree/poor-tree3.png"),
	preload("res://assets/images/animations/page2/poor-tree/poor-tree4.png"),
	preload("res://assets/images/animations/page2/poor-tree/poor-tree5.png")
]

var rich_tree_textures = [
	preload("res://assets/images/animations/page2/rich-tree/rich-tree1.png"),
	preload("res://assets/images/animations/page2/rich-tree/rich-tree2.png"),
	preload("res://assets/images/animations/page2/rich-tree/rich-tree3.png"),
	preload("res://assets/images/animations/page2/rich-tree/rich-tree4.png")
]

func _ready():
	super._ready()
	# Store initial position to reset if needed (optional, or just keep it where it is)
	if watering_can:
		initial_position = watering_can.position
		target_position = watering_can.position

func _process(delta):
	# Smooth drag
	if watering_can:
		watering_can.global_position = watering_can.global_position.lerp(target_position, delta * drag_smoothing)
		
	if is_watering:
		spawn_timer -= delta
		if spawn_timer <= 0:
			_spawn_drop()
			spawn_timer = spawn_interval
			
		# Grow trees
		_process_growth(delta)

func _process_growth(delta):
	# Rich tree grows 2x faster
	rich_growth += delta * growth_speed * 2.0
	poor_growth += delta * growth_speed
	
	# Clamp growth
	if rich_growth > rich_tree_textures.size() - 1:
		rich_growth = float(rich_tree_textures.size() - 1)
		
	if poor_growth > poor_tree_textures.size() - 1:
		poor_growth = float(poor_tree_textures.size() - 1)
		
	_update_tree_visuals()
	
	# Check for completion
	if not interaction_completed:
		if rich_growth >= rich_tree_textures.size() - 1 and poor_growth >= poor_tree_textures.size() - 1:
			_on_interaction_complete()

func _on_interaction_complete():
	interaction_completed = true
	
	# Hide instruction
	if instruction:
		instruction.visible = false
		
	# Show balloon
	if text_balloon:
		text_balloon.visible = true
		text_balloon.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(text_balloon, "modulate:a", 1.0, 0.5)
		
	# Play audio
	Global.parar_audio()
	if audio_player:
		audio_player.play()

func _update_tree_visuals():
	if rich_tree:
		var idx = int(rich_growth)
		rich_tree.texture = rich_tree_textures[idx]
		
	if poor_tree_1:
		var idx = int(poor_growth)
		poor_tree_1.texture = poor_tree_textures[idx]
		
	if poor_tree_2:
		var idx = int(poor_growth)
		poor_tree_2.texture = poor_tree_textures[idx]

func _input(event):
	if not watering_can:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging if clicked on watering can
				if watering_can.get_global_rect().has_point(event.position):
					is_dragging = true
					drag_offset = watering_can.global_position - event.position
					target_position = watering_can.global_position # Sync target
			else:
				# Stop dragging
				is_dragging = false
				_check_watering_stop()

	elif event is InputEventScreenTouch:
		if event.pressed:
			if watering_can.get_global_rect().has_point(event.position):
				is_dragging = true
				drag_offset = watering_can.global_position - event.position
				target_position = watering_can.global_position # Sync target
		else:
			is_dragging = false
			_check_watering_stop()

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if is_dragging:
			target_position = event.position + drag_offset
			_check_watering()

func _check_watering():
	if not tree_floor or not watering_can:
		return

	# Check if watering can overlaps with tree floor
	# We check if the center of the watering can is horizontally aligned with the floor
	# and if it is above the bottom of the floor (allowing it to be "above" the ground)
	var can_center = watering_can.global_position + watering_can.size / 2
	var floor_rect = tree_floor.get_global_rect()
	
	# Calculate the actual visible area of the texture (handling Keep Aspect Centered)
	var floor_rect_size = tree_floor.size
	var floor_tex_size = tree_floor.texture.get_size()
	var scale_ratio = min(floor_rect_size.x / floor_tex_size.x, floor_rect_size.y / floor_tex_size.y)
	
	var actual_width = floor_tex_size.x * scale_ratio
	var actual_height = floor_tex_size.y * scale_ratio
	
	var x_offset = (floor_rect_size.x - actual_width) / 2.0
	var y_offset = (floor_rect_size.y - actual_height) / 2.0
	
	# Define the actual visual bounds of the grass
	var grass_start_x = floor_rect.position.x + x_offset
	var grass_end_x = grass_start_x + actual_width
	var grass_top_y = floor_rect.position.y + y_offset
	var grass_bottom_y = grass_top_y + actual_height
	
	# Horizontal check: Can center is within the VISIBLE grass width
	# Added a small buffer (40px) to make it easier to hit the edges
	var horizontal_match = can_center.x > (grass_start_x - 20) and can_center.x < (grass_end_x + 80)
	
	# Vertical check: Can is above the bottom of the visible grass
	# And not too high up (e.g. 500px above the grass top)
	var vertical_match = can_center.y < grass_bottom_y and can_center.y > (grass_top_y - 500)
	
	if horizontal_match and vertical_match:
		if not is_watering:
			_start_watering()
	else:
		if is_watering:
			_stop_watering()

func _check_watering_stop():
	if is_watering:
		_stop_watering()

func _start_watering():
	is_watering = true
	
	# Tilt the can
	var tween = create_tween()
	tween.tween_property(watering_can, "rotation_degrees", 30.0, 0.2)
	
	# Hide instruction
	if instruction and instruction.visible:
		instruction.visible = false

func _stop_watering():
	is_watering = false
	
	# Reset rotation
	var tween = create_tween()
	tween.tween_property(watering_can, "rotation_degrees", 0.0, 0.2)

func _spawn_drop():
	if not drop_spawner or not tree_floor:
		return
		
	var drop = water_drop_scene.instantiate()
	# Add to MainContainer so it doesn't move with the can
	$MainContainer.add_child(drop)
	
	# Set position to spawner global position
	drop.global_position = drop_spawner.global_position
	
	# Set floor level for collision
	# Calculate the actual top of the texture within the TextureRect (handling Keep Aspect Centered)
	var floor_rect_size = tree_floor.size
	var floor_tex_size = tree_floor.texture.get_size()
	
	# Calculate scale to fit (Keep Aspect Centered / stretch_mode = 5)
	var scale_ratio = min(floor_rect_size.x / floor_tex_size.x, floor_rect_size.y / floor_tex_size.y)
	var actual_height = floor_tex_size.y * scale_ratio
	
	# Calculate vertical offset (centered)
	var y_offset = (floor_rect_size.y - actual_height) / 2.0
	
	# The collision point is the top of the visible texture
	# We add a small buffer (e.g. 10% of height) so it hits "inside" the grass a bit
	drop.floor_y = tree_floor.global_position.y + y_offset
