extends "res://scripts/pages/page_navigation.gd"

@onready var tree_sprite = $MainContainer/TreeContainer/TreeSprite
@onready var tree_sprite_2 = $MainContainer/TreeContainer/TreeSprite2
@onready var tree_sprite_3 = $MainContainer/TreeContainer/TreeSprite3
@onready var items_container = $MainContainer/ItemsContainer
@onready var text_balloon = $MainContainer/TextBalloon

# Textures for the tree states
var tree_textures = [
	preload("res://assets/images/animations/page7/tree-growing/tree-growing-1.png"),
	preload("res://assets/images/animations/page7/tree-growing/tree-growing-2.png"),
	preload("res://assets/images/animations/page7/tree-growing/tree-growing-3.png"),
	preload("res://assets/images/animations/page7/tree-growing/tree-growing-4.png")
]

var balloon_textures = {
	"initial": preload("res://assets/images/text-balloon/page7-1.png"),
	"final": preload("res://assets/images/text-balloon/page7-2.png")
}

var items_collected: int = 0

func _ready():
	super._ready()
	_update_tree_state()
	
	# Connect signals for all item buttons
	for button in items_container.get_children():
		if button is TextureButton:
			button.pressed.connect(_on_item_pressed.bind(button))

func _on_item_pressed(button: TextureButton):
	# Rotate the collected item
	# button.visible = false
	button.rotation_degrees = 45 # Rotate right
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	items_collected += 1
	_update_tree_state()

func _update_tree_state():
	var texture_index = 0
	
	if items_collected >= 4:
		texture_index = 3 # Final state
		if text_balloon:
			text_balloon.texture = balloon_textures["final"]
			
		# Stop global audio and play post-interaction audio
		if Global.has_method("parar_audio"):
			Global.parar_audio()
			
		var audio_path = "res://assets/audio/transcriptions/pos-interaction/page7-pos-interaction.ogg"
		if ResourceLoader.exists(audio_path):
			var stream = load(audio_path)
			var player = AudioStreamPlayer.new()
			add_child(player)
			player.stream = stream
			player.play()
			# Clean up player after it finishes
			player.finished.connect(player.queue_free)
	elif items_collected >= 3:
		texture_index = 2 # Third state
	elif items_collected >= 1:
		texture_index = 1 # Second state
	else:
		texture_index = 0 # Initial state
		if text_balloon:
			text_balloon.texture = balloon_textures["initial"]
		
	if texture_index < tree_textures.size():
		var texture = tree_textures[texture_index]
		if tree_sprite:
			tree_sprite.texture = texture
		if tree_sprite_2:
			tree_sprite_2.texture = texture
		if tree_sprite_3:
			tree_sprite_3.texture = texture
