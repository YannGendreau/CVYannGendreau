extends Area2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var page = preload("res://page_2003.tscn").instantiate()
		get_tree().root.add_child(page)  # ou ajoute dans un CanvasLayer prévu pour les pages
		page.z_index = 100  # assure que ça s'affiche au-dessus
