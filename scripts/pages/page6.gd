extends "res://scripts/pages/page_navigation.gd"

@onready var seeds_container = $MainContainer/SeedsContainer
@onready var grass = $MainContainer/Grass
@onready var instruction = $MainContainer/Instruction
@onready var text_balloon = $MainContainer/TextBalloon
@onready var audio_player = $AudioStreamPlayer

# Physics constants
const GRAVITY_HEAVY = 980.0
const GRAVITY_LIGHT = 100.0
const FRICTION_AIR = 2.0
const BOUNCE = 0.3

# Drag state
var dragged_seed = null
var drag_offset = Vector2.ZERO
var drag_velocity = Vector2.ZERO
var last_drag_pos = Vector2.ZERO
var last_drag_time = 0.0

# Seed data: { node: { velocity: Vector2, type: "light"|"heavy", is_resting: bool } }
var seeds_data = {}
var interacted_seeds = {} # Track unique seeds interacted with
var interaction_completed = false

func _ready():
	super._ready()
	_setup_seeds()

func _setup_seeds():
	if not seeds_container:
		return
		
	for child in seeds_container.get_children():
		var type = "heavy"
		if "Light" in child.name:
			type = "light"
			
		seeds_data[child] = {
			"velocity": Vector2.ZERO,
			"type": type,
			"is_resting": false
		}

func _process(delta):
	# Update dragged seed velocity for throw calculation
	if dragged_seed:
		var current_time = Time.get_ticks_msec() / 1000.0
		var dt = current_time - last_drag_time
		if dt > 0:
			var current_pos = dragged_seed.global_position
			# Calculate velocity based on movement
			var raw_velocity = (current_pos - last_drag_pos) / dt
			# Smooth it out
			drag_velocity = drag_velocity.lerp(raw_velocity, delta * 10.0)
			
			last_drag_pos = current_pos
			last_drag_time = current_time
			
	# Apply physics to non-dragged seeds
	for seed_node in seeds_data.keys():
		if seed_node == dragged_seed:
			continue
			
		var data = seeds_data[seed_node]
		
		# Handle resting seeds (check if floor moved)
		if data.is_resting:
			var grass_top = _get_grass_top_y()
			var seed_bottom = seed_node.global_position.y + seed_node.size.y
			
			if seed_bottom > grass_top:
				# Penetrating (floor rose) - Snap up and stay resting
				seed_node.global_position.y = grass_top - seed_node.size.y
				continue
			elif seed_bottom < grass_top - 5.0:
				# Floating (floor dropped) - Wake up
				data.is_resting = false
			else:
				# On floor (within tolerance) - Snap and stay resting
				seed_node.global_position.y = grass_top - seed_node.size.y
				continue
			
		_apply_physics(seed_node, data, delta)
		
	# Check for completion
	if not interaction_completed and interacted_seeds.size() >= 4:
		_on_interaction_complete()

func _on_interaction_complete():
	interaction_completed = true
	
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

# ========================================
# ANIMAÇÃO: Física
# Simulação de física com gravidade, fricção e colisão
# ========================================
func _apply_physics(seed_node, data, delta):
	var velocity = data.velocity
	var gravity = GRAVITY_HEAVY
	
	if data.type == "light":
		gravity = GRAVITY_LIGHT
		# Add some floaty noise
		velocity.x += randf_range(-10, 10) * delta
	
	# Apply gravity
	velocity.y += gravity * delta
	
	# Apply air friction
	velocity -= velocity * FRICTION_AIR * delta
	
	# Move
	seed_node.global_position += velocity * delta
	
	# Check collision with grass
	if grass:
		var grass_rect = grass.get_global_rect()
		# Simple collision check with top of grass
		# Calculate actual top based on aspect ratio (similar to page 2)
		var grass_top = _get_grass_top_y()
		
		if seed_node.global_position.y + seed_node.size.y > grass_top:
			# Collision!
			seed_node.global_position.y = grass_top - seed_node.size.y
			
			if abs(velocity.y) < 50:
				# Stop if slow enough
				velocity = Vector2.ZERO
				data.is_resting = true
			else:
				# Bounce
				velocity.y = - velocity.y * BOUNCE
				velocity.x *= 0.8 # Ground friction
				
	# Screen bounds
	var viewport_rect = get_viewport_rect()
	if seed_node.global_position.x < 0:
		seed_node.global_position.x = 0
		velocity.x = - velocity.x * BOUNCE
	elif seed_node.global_position.x + seed_node.size.x > viewport_rect.size.x:
		seed_node.global_position.x = viewport_rect.size.x - seed_node.size.x
		velocity.x = - velocity.x * BOUNCE
		
	# Top bound (ceiling)
	if seed_node.global_position.y < 0:
		seed_node.global_position.y = 0
		velocity.y = - velocity.y * BOUNCE
		
	# Bottom bound (failsafe, though grass should catch it)
	if seed_node.global_position.y + seed_node.size.y > viewport_rect.size.y:
		seed_node.global_position.y = viewport_rect.size.y - seed_node.size.y
		velocity.y = - velocity.y * BOUNCE
		velocity.x *= 0.8
		
	data.velocity = velocity

func _get_grass_top_y():
	if not grass:
		return 1000.0
		
	var rect_size = grass.size
	var tex_size = grass.texture.get_size()
	var scale_ratio = min(rect_size.x / tex_size.x, rect_size.y / tex_size.y)
	var actual_height = tex_size.y * scale_ratio
	var y_offset = (rect_size.y - actual_height) / 2.0
	
	# Return top Y of visible texture + small buffer
	return grass.global_position.y + y_offset + (actual_height * 0.2)

# ========================================
# INTERAÇÃO: Arrastar
# Captura eventos de mouse e toque para arrastar sementes
# ========================================
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_try_start_drag(event.position)
			else:
				_stop_drag()
				
	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_start_drag(event.position)
		else:
			_stop_drag()
			
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if dragged_seed:
			dragged_seed.global_position = event.position + drag_offset

func _try_start_drag(pos):
	if not seeds_container:
		return
		
	for child in seeds_container.get_children():
		if child.get_global_rect().has_point(pos):
			dragged_seed = child
			drag_offset = child.global_position - pos
			last_drag_pos = child.global_position
			last_drag_time = Time.get_ticks_msec() / 1000.0
			drag_velocity = Vector2.ZERO
			
			# Wake up
			seeds_data[child].is_resting = false
			seeds_data[child].velocity = Vector2.ZERO
			
			# Track interaction
			interacted_seeds[child] = true
			
			# Hide instruction
			if instruction and instruction.visible:
				instruction.visible = false
			return

func _stop_drag():
	if dragged_seed:
		# Apply throw velocity
		seeds_data[dragged_seed].velocity = drag_velocity
		dragged_seed = null
