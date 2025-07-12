extends Node2D

@export var scene_name : String = "" 

func _on_return_button_pressed() -> void:
		print("Retour en arrière")
		GameManager.last_clicked_object = "ordi"
		GameManager.last_object_interacted = "ordi"

		get_tree().change_scene_to_file("res://chez_yann.tscn")
