extends "res://scripts/pages/page_navigation.gd"

@onready var tree1 = $MainContainer/TreesContainer/Tree1
@onready var tree2 = $MainContainer/TreesContainer/Tree2
@onready var instruction = $MainContainer/Instruction
@onready var text_balloon = $MainContainer/TextBalloon
@onready var audio_player = $AudioStreamPlayer

# --- Constants ---
const SHAKE_THRESHOLD = 1.5 # Lowered significantly for mobile sensitivity
const ENERGY_TO_GROW = 40.0 # Reduced from 60 to make it easier
const SWAY_SMOOTHING = 8.0 # Faster response

# --- Textures ---
# Tree 1: Sway (1, 2, 3) -> Growth (4, 5, 6, 7)
var t1_sway_center = preload("res://assets/images/animations/page5/tree1/tree1.png")
var t1_sway_right = preload("res://assets/images/animations/page5/tree1/tree2.png")
var t1_sway_left = preload("res://assets/images/animations/page5/tree1/tree3.png")

var t1_growth = [
	preload("res://assets/images/animations/page5/tree1/tree4.png"),
	preload("res://assets/images/animations/page5/tree1/tree5.png"),
	preload("res://assets/images/animations/page5/tree1/tree6.png"),
	preload("res://assets/images/animations/page5/tree1/tree7.png")
]

# Tree 2: Sway (2, 3, 4, 5) -> Stabilize (5, 2, 1)
var t2_sway_base = preload("res://assets/images/animations/page5/tree2/tree2.png")
var t2_sway_right = preload("res://assets/images/animations/page5/tree2/tree3.png")
var t2_sway_left = preload("res://assets/images/animations/page5/tree2/tree4.png")
var t2_sway_extreme = preload("res://assets/images/animations/page5/tree2/tree5.png")

var t2_stabilize = [
	preload("res://assets/images/animations/page5/tree2/tree5.png"),
	preload("res://assets/images/animations/page5/tree2/tree2.png"),
	preload("res://assets/images/animations/page5/tree2/tree1.png")
]

# --- State Variables ---
enum Phase {SWAY, GROWTH}
var current_phase = Phase.SWAY
var shake_energy = 0.0
var current_tilt = 0.0
var interaction_completed = false

# Simplified shake detection
var last_accel = Vector3.ZERO
var accel_history = []
const HISTORY_SIZE = 5

# Fallback timer (starts disabled, enabled after audio finishes)
var fallback_timer = 0.0
const FALLBACK_TIMEOUT = 4.0
var fallback_triggered = true # Start as true (disabled) until audio finishes

func _ready():
	super._ready()
	_update_visuals()
	
	# Wait for global audio to finish before enabling fallback
	var global_audio = Global.audio_player
	if global_audio and global_audio.playing:
		# Connect to finished signal
		if not global_audio.finished.is_connected(_on_audio_finished):
			global_audio.finished.connect(_on_audio_finished)
	else:
		# No audio or already finished, enable fallback immediately
		_enable_fallback()

func _on_audio_finished():
	_enable_fallback()

func _enable_fallback():
	# Start counting fallback timer
	fallback_timer = 0.0
	fallback_triggered = false

func _process(delta):
	# Fallback timer - auto-trigger after 4 seconds
	if current_phase == Phase.SWAY and not fallback_triggered:
		fallback_timer += delta
		if fallback_timer >= FALLBACK_TIMEOUT:
			fallback_triggered = true
			current_phase = Phase.GROWTH
			shake_energy = 0.0
			if instruction and instruction.visible:
				instruction.visible = false
	
	var accel = Input.get_accelerometer()
	
	# Simple shake detection: measure change in acceleration
	var shake_magnitude = 0.0
	
	if accel.length_squared() > 0.1:
		# Calculate change from last frame
		var accel_delta = (accel - last_accel).length()
		
		# Add to history
		accel_history.append(accel_delta)
		if accel_history.size() > HISTORY_SIZE:
			accel_history.pop_front()
		
		# Average the history for smoother detection
		var avg_delta = 0.0
		for val in accel_history:
			avg_delta += val
		if accel_history.size() > 0:
			avg_delta /= accel_history.size()
		
		shake_magnitude = avg_delta
		
		# Use X-axis for tilt (simpler approach)
		var raw_tilt = accel.x
		current_tilt = lerp(current_tilt, raw_tilt, delta * SWAY_SMOOTHING)
		
		last_accel = accel
	
	# Desktop debug controls
	if Input.is_action_pressed("ui_left"):
		current_tilt = -5.0
	elif Input.is_action_pressed("ui_right"):
		current_tilt = 5.0
	
	if Input.is_action_pressed("ui_accept"):
		shake_magnitude = 10.0
		if current_tilt == 0.0:
			current_tilt = sin(Time.get_ticks_msec() * 0.01) * 5.0
	
	# Process based on phase
	match current_phase:
		Phase.SWAY:
			_process_sway(delta, shake_magnitude)
		Phase.GROWTH:
			_process_growth(delta)
	
	_update_visuals()

func _process_sway(delta, shake_magnitude):
	# Much more forgiving shake detection
	if shake_magnitude > SHAKE_THRESHOLD:
		shake_energy += delta * 30.0 # Faster energy gain
		
		# Cancel fallback timer on interaction
		fallback_triggered = true
		
		if instruction and instruction.visible:
			instruction.visible = false
	
	# Transition to growth
	if shake_energy >= ENERGY_TO_GROW:
		current_phase = Phase.GROWTH
		shake_energy = 0.0

func _process_growth(delta):
	shake_energy += delta * 2.0
	
	if shake_energy > float(t1_growth.size()):
		shake_energy = float(t1_growth.size())
		if not interaction_completed:
			_on_interaction_complete()

func _on_interaction_complete():
	interaction_completed = true
	
	text_balloon.visible = true
	text_balloon.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(text_balloon, "modulate:a", 1.0, 0.5)
	
	Global.parar_audio()
	if audio_player:
		audio_player.play()

func _update_visuals():
	match current_phase:
		Phase.SWAY:
			_update_sway_visuals()
		Phase.GROWTH:
			_update_growth_visuals()

func _update_sway_visuals():
	# Tree 1 - responsive tilt
	if current_tilt > 0.5:
		tree1.texture = t1_sway_right
	elif current_tilt < -0.5:
		tree1.texture = t1_sway_left
	else:
		tree1.texture = t1_sway_center
	
	# Tree 2 - more variation
	if abs(current_tilt) > 1.5:
		tree2.texture = t2_sway_extreme
	elif current_tilt > 0.5:
		tree2.texture = t2_sway_right
	elif current_tilt < -0.5:
		tree2.texture = t2_sway_left
	else:
		tree2.texture = t2_sway_base

func _update_growth_visuals():
	var idx = int(shake_energy)
	
	# Tree 1 growth
	var t1_idx = clamp(idx, 0, t1_growth.size() - 1)
	tree1.texture = t1_growth[t1_idx]
	
	# Tree 2 stabilize
	var t2_progress = float(idx) / float(t1_growth.size())
	var t2_idx = int(t2_progress * t2_stabilize.size())
	t2_idx = clamp(t2_idx, 0, t2_stabilize.size() - 1)
	tree2.texture = t2_stabilize[t2_idx]
