extends TextureRect

var speed = 400.0
var floor_y = 0.0
var state = "falling" # falling, splashed

# Textures
var texture_drop1 = preload("res://assets/images/animations/page2/water-drops/water-drop1.png")
var texture_drop3 = preload("res://assets/images/animations/page2/water-drops/water-drop3.png")
var texture_drop4 = preload("res://assets/images/animations/page2/water-drops/water-drop4.png")

func _ready():
	texture = texture_drop1
	# Randomize slightly horizontal position for variety
	position.x += randf_range(-10, 10)

func _process(delta):
	if state == "falling":
		position.y += speed * delta
		
		# Check collision
		if global_position.y >= floor_y:
			_splash()

func _splash():
	state = "splashed"
	
	# Change to splash texture
	texture = texture_drop3
	
	# Center the splash on the floor line
	# global_position.y = floor_y - size.y / 2
	
	# Wait a bit then change to final splash
	await get_tree().create_timer(0.1).timeout
	texture = texture_drop4
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
