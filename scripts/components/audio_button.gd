extends TextureButton

var texture_som_ligado = preload("res://assets/images/buttons/som-ligado.png")
var texture_som_desligado = preload("res://assets/images/buttons/som-desligado.png")

func _ready() -> void:
	_atualizar_textura(Global.som_ligado)
	Global.som_alterado.connect(_atualizar_textura)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	Global.toggle_som()

func _atualizar_textura(som_ligado: bool) -> void:
	if som_ligado:
		texture_normal = texture_som_ligado
	else:
		texture_normal = texture_som_desligado
