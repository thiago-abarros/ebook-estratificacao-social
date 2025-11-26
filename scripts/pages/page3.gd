extends "res://scripts/pages/page_navigation.gd"

@onready var tree_sprite = $MainContainer/ZoomContainer/TreeAligner/TreeSprite
@onready var instruction_sprite = $MainContainer/InstructionSprite
@onready var post_zoom_container = $MainContainer/PostZoomContainer

var min_zoom = 1.0
var max_zoom = 2.5
var current_zoom = 1.0
var target_zoom = 1.0
var zoom_speed = 0.05
var smooth_speed = 3.0

# Touch variables
var touch_points = {}
var start_distance = 0.0
var start_zoom = 1.0

func _ready():
	super._ready()
	# Ensure pivot is at the bottom center for zooming into the ground
	if tree_sprite:
		tree_sprite.resized.connect(_update_pivot)
		_update_pivot()

func _update_pivot():
	if tree_sprite:
		tree_sprite.pivot_offset = Vector2(tree_sprite.size.x / 2, tree_sprite.size.y * 0.9) # Focus near bottom

func _process(delta):
	if not tree_sprite:
		return
		
	# ========================================
	# ANIMAÇÃO: Interpolação (Lerp)
	# Zoom suave usando interpolação linear
	# ========================================
	current_zoom = lerp(current_zoom, target_zoom, smooth_speed * delta)
	
	# Apply scale
	tree_sprite.scale = Vector2(current_zoom, current_zoom)
	
	# Check completion based on current visual zoom
	_check_completion()

func _input(event):
	if not tree_sprite:
		return

	# Check if event is inside the zoom container
	var zoom_container = $MainContainer/ZoomContainer
	if not zoom_container:
		return
		
	var is_inside = false
	if event is InputEventMouse:
		is_inside = zoom_container.get_global_rect().has_point(event.position)
		# print("Mouse Event: ", event.position, " Rect: ", zoom_container.get_global_rect(), " Inside: ", is_inside)
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		is_inside = zoom_container.get_global_rect().has_point(event.position)
	
	# If not inside, ignore TOUCH inputs (pinch)
	# We allow Mouse Wheel and Pan Gesture (Trackpad) globally for better UX
	if not is_inside and (event is InputEventScreenTouch or event is InputEventScreenDrag):
		# Clear touch points if finger leaves area
		if event is InputEventScreenTouch and not event.pressed:
			touch_points.erase(event.index)
		return

	# Desktop: Mouse Wheel
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
			
	# Trackpad: Pan Gesture
	elif event is InputEventPanGesture:
		if event.delta.y < 0:
			_zoom_in()
			
	# ========================================
	# INTERAÇÃO: Múltiplos toques (Pinça)
	# Detecção de gestos multi-touch para zoom
	# ========================================
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
			
		if touch_points.size() == 2:
			var p1 = touch_points.values()[0]
			var p2 = touch_points.values()[1]
			start_distance = p1.distance_to(p2)
			start_zoom = target_zoom # Use target_zoom as base for pinch
			
	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position
		
		if touch_points.size() == 2:
			var p1 = touch_points.values()[0]
			var p2 = touch_points.values()[1]
			var current_distance = p1.distance_to(p2)
			
			if start_distance > 0:
				var zoom_factor = current_distance / start_distance
				# Only allow zooming in
				if zoom_factor > 1.0:
					target_zoom = clamp(start_zoom * zoom_factor, min_zoom, max_zoom)

func _zoom_in():
	if target_zoom < max_zoom:
		target_zoom = min(target_zoom + zoom_speed, max_zoom)

func _zoom_out():
	# Zoom out disabled
	pass

func _check_completion():
	# Check if we are close enough to max zoom
	if current_zoom >= max_zoom * 0.95:
		_hide_instruction()
		_show_post_zoom_elements()

func _hide_instruction():
	if instruction_sprite and instruction_sprite.visible:
		var tween = create_tween()
		tween.tween_property(instruction_sprite, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): instruction_sprite.visible = false)

func _show_post_zoom_elements():
	if post_zoom_container and not post_zoom_container.visible:
		post_zoom_container.modulate.a = 0.0
		post_zoom_container.visible = true
		# ========================================
		# ANIMAÇÃO: Interpolação (Tween)
		# Fade-in dos elementos pós-zoom
		# ========================================
		var tween = create_tween()
		tween.tween_property(post_zoom_container, "modulate:a", 1.0, 1.0)
		
		# Stop global audio and play post-interaction audio
		if Global.has_method("parar_audio"):
			Global.parar_audio()
			
		var audio_path = "res://assets/audio/transcriptions/pos-interaction/page3-pos-interaction.ogg"
		if ResourceLoader.exists(audio_path):
			var stream = load(audio_path)
			var player = AudioStreamPlayer.new()
			add_child(player)
			player.stream = stream
			player.play()
			# Clean up player after it finishes
			player.finished.connect(player.queue_free)
