extends Control

func _ready() -> void:
	var botao_proximo = get_node_or_null("botao-proximo")
	if botao_proximo:
		botao_proximo.pressed.connect(Global.proxima_pagina)
	
	var botao_anterior = get_node_or_null("botao-anterior")
	if botao_anterior:
		botao_anterior.pressed.connect(Global.pagina_anterior)
		
	var botao_iniciar = get_node_or_null("botao-iniciar-jornada")
	if botao_iniciar:
		botao_iniciar.pressed.connect(Global.proxima_pagina)

	var botao_voltar = get_node_or_null("botao-voltar-inicio")
	if botao_voltar:
		botao_voltar.pressed.connect(Global.pagina_inicial)
