extends Area2D

@onready var return_button = get_node("/root/Carton_docs/ReturnButton") 

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var page = preload("res://page_2003.tscn").instantiate()
		get_tree().root.add_child(page)  # ou ajoute dans un CanvasLayer prévu pour les pages
		page.z_index = 100  # assure que ça s'affiche au-dessus
		return_button.visible = false
		
func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
