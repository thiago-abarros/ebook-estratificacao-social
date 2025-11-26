# Video controller that extends page navigation to keep navigation buttons working
extends "res://scripts/pages/page_navigation.gd"

@onready var video_player = $VideoContainer/VideoPanel/VideoStreamPlayer
@onready var toggle_button = $ToggleButton
@onready var restart_button = $RestartButton

# Preload the button textures
var play_texture = preload("res://assets/images/buttons/play-button.png")
var pause_texture = preload("res://assets/images/buttons/pause-button.png")

# Flag to prevent multiple restart clicks
var is_restarting = false

func _ready():
	# Call parent to setup navigation buttons
	super._ready()
	
	# Debug - check if nodes exist
	if not video_player:
		print("ERROR: VideoStreamPlayer not found!")
	if not toggle_button:
		print("ERROR: ToggleButton not found!")
	if not restart_button:
		print("ERROR: RestartButton not found!")
	else:
		print("RestartButton found successfully!")
	
	# Connect button signals
	if toggle_button:
		toggle_button.pressed.connect(_on_toggle_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		print("RestartButton signal connected!")
	
	# Connect video finished signal to prevent disappearing
	if video_player:
		video_player.finished.connect(_on_video_finished)
	
	# Show video preview (first frame)
	if video_player:
		video_player.play()
		video_player.paused = true
	
	# Set initial button to play icon
	_update_button_icon()

func _on_video_finished():
	# When video ends, restart it at the beginning and pause
	video_player.stop()
	video_player.play()
	video_player.paused = true
	# Update button to show play icon
	_update_button_icon()

# ========================================
# INTERAÇÃO: Toque
# Botão para play/pause do vídeo
# ========================================
func _on_toggle_pressed():
	if video_player.paused:
		# ========================================
		# ANIMAÇÃO: Vídeo
		# Reprodução de vídeo
		# ========================================
		video_player.paused = false
		# Stop page audio transcription if it's playing
		if Global.has_method("parar_audio"):
			Global.parar_audio()
	else:
		# Pause
		video_player.paused = true
	
	# Update button icon
	_update_button_icon()

# ========================================
# INTERAÇÃO: Toque
# Botão para reiniciar o vídeo
# ========================================
func _on_restart_pressed():
	if is_restarting:
		return

	# If already at the beginning (less than 0.2s), ignore to prevent freezing
	if video_player.stream_position < 0.2:
		return

	is_restarting = true
	
	# 1. Save whether it was paused or playing
	var was_paused = video_player.paused
	
	# 2. Trick to prevent image from disappearing:
	# We don't use stop(). Just unpause and rewind the time.
	video_player.paused = true
	video_player.stop()
	video_player.stream_position = 0.0
	video_player.paused = false
	
	# If the video had reached the end, it stops playing internally.
	# In that case, we force play again.
	if not video_player.is_playing():
		video_player.play()
	
	# 3. Wait for the video to update the frame visually (essential)
	await get_tree().process_frame
	
	# 4. Restore previous state
	# If it was paused before, pause it again now at frame 0
	if was_paused:
		video_player.paused = true
	
	_update_button_icon()
	
	# Small safety delay before allowing the button to be pressed again
	# This prevents frantic double-clicks that make the screen flicker
	await get_tree().create_timer(0.2).timeout
	
	is_restarting = false

func _update_button_icon():
	if video_player.paused:
		toggle_button.texture_normal = play_texture
	else:
		toggle_button.texture_normal = pause_texture
