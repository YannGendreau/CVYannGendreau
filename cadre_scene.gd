extends Node2D

@export var scene_name : String = "" 
@onready var return_button = $ReturnButton/AnimatedSprite2D

func _ready() -> void:
	
	return_button.play('glow') 


func _on_return_button_pressed() -> void:
	print("Retour en arrière")
	GameManager.last_clicked_object = "cadre"
	#GameManager.last_object_interacted = "cadre"

	get_tree().change_scene_to_file("res://chez_yann.tscn")
