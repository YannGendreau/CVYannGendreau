extends Node2D

@export var scene_name : String = "" 
#var return_button = $ReturnButton

#func _ready() -> void:
	#
	#return_button.visible = true

func _on_return_button_pressed() -> void:
	print("Retour en arrière")
	GameManager.last_clicked_object = "carton"
	#GameManager.last_object_interacted = "carton"
	get_tree().change_scene_to_file("res://chez_yann.tscn")
	
	#return_button.visible = false


#func _on_etiquette_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#var page = preload("res://page_2001.tscn").instantiate()
		#get_tree().root.add_child(page)  # ou ajoute dans un CanvasLayer prévu pour les pages
		#page.z_index = 100  # assure que ça s'affiche au-dessus
