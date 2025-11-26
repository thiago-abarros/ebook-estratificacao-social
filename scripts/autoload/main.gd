extends Node

var paginas: Array[String] = [
	"res://scenes/pages/capa.tscn",
	"res://scenes/pages/page2.tscn",
	"res://scenes/pages/page3.tscn",
	"res://scenes/pages/page4.tscn",
	"res://scenes/pages/page5.tscn",
	"res://scenes/pages/page6.tscn",
	"res://scenes/pages/page7.tscn",
	"res://scenes/pages/contracapa.tscn"
]

# Mapeamento de índices de página para caminhos de áudio
# Exemplo: 0: "res://assets/audio/transcriptions/capa.ogg"
var audios_pagina: Dictionary = {
	0: "res://assets/audio/transcriptions/capa.ogg",
	1: "res://assets/audio/transcriptions/page2.ogg",
	2: "res://assets/audio/transcriptions/page3.ogg",
	3: "res://assets/audio/transcriptions/page4.ogg",
	4: "res://assets/audio/transcriptions/page5.ogg",
	5: "res://assets/audio/transcriptions/page6.ogg",
	6: "res://assets/audio/transcriptions/page7.ogg",
	7: "res://assets/audio/transcriptions/contracapa.ogg"
}

var pagina_atual: int = 0
var audio_player: AudioStreamPlayer

var som_ligado: bool = true
signal som_alterado(novo_estado: bool)

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	# Tenta tocar o áudio da primeira página ao iniciar
	_tocar_audio_pagina()

func toggle_som() -> void:
	som_ligado = not som_ligado
	AudioServer.set_bus_mute(0, not som_ligado)
	som_alterado.emit(som_ligado)
	
	if som_ligado:
		# Se estamos na página 4 (índice 3), verifica se o vídeo está tocando
		if pagina_atual == 3:
			var current_scene = get_tree().current_scene
			if current_scene and current_scene.has_node("VideoContainer/VideoPanel/VideoStreamPlayer"):
				var video_player = current_scene.get_node("VideoContainer/VideoPanel/VideoStreamPlayer")
				# Só toca a transcrição se o vídeo estiver pausado
				if video_player.paused:
					_tocar_audio_pagina()
				# Se o vídeo está tocando, não toca a transcrição
			else:
				# Se não encontrou o vídeo, toca normalmente
				_tocar_audio_pagina()
		else:
			# Para outras páginas, toca normalmente
			_tocar_audio_pagina()
	else:
		audio_player.stop()

func proxima_pagina() -> void:
	if pagina_atual < paginas.size() - 1:
		pagina_atual += 1
		_mudar_cena()

func pagina_anterior() -> void:
	if pagina_atual > 0:
		pagina_atual -= 1
		_mudar_cena()

func pagina_inicial() -> void:
	pagina_atual = 0
	_mudar_cena()

func _mudar_cena() -> void:
	get_tree().change_scene_to_file(paginas[pagina_atual])
	_tocar_audio_pagina()

func _tocar_audio_pagina() -> void:
	if not som_ligado:
		return
	
	# Se estamos na página 4 (índice 3), verifica se o vídeo está tocando
	if pagina_atual == 3:
		# Aguarda um frame para garantir que a cena foi carregada
		await get_tree().process_frame
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.has_node("VideoContainer/VideoPanel/VideoStreamPlayer"):
			var video_player = current_scene.get_node("VideoContainer/VideoPanel/VideoStreamPlayer")
			# Só toca a transcrição se o vídeo estiver pausado
			if video_player.paused:
				_executar_audio()
			# Se o vídeo está tocando, não toca a transcrição
		else:
			# Se não encontrou o vídeo, toca normalmente
			_executar_audio()
	else:
		# Para outras páginas, toca normalmente
		_executar_audio()

func _executar_audio() -> void:
	audio_player.stop()
	
	if audios_pagina.has(pagina_atual):
		var audio_path = audios_pagina[pagina_atual]
		if ResourceLoader.exists(audio_path):
			var stream = load(audio_path)
			audio_player.stream = stream
			audio_player.play()
		else:
			print("Áudio não encontrado para a página " + str(pagina_atual) + ": " + audio_path)

func parar_audio() -> void:
	if audio_player:
		audio_player.stop()
