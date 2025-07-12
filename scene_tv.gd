extends Node2D

@onready var video_player = $VideoStreamPlayer
@onready var texture_rect = $TextureRect
@export var scene_name : String = "" 

func _on_return_button_pressed() -> void:
	print("Retour en arrière")
	GameManager.last_clicked_object = "tv"
	GameManager.last_object_interacted = "tv"
	get_tree().change_scene_to_file("res://chez_yann.tscn")

func _ready():
	#video_player.visible = false
	video_player.play()
	wait_for_texture()

func wait_for_texture():
	await get_tree().process_frame  # attendre une frame pour charger la texture
	var tex = video_player.get_video_texture()
	if tex:
		texture_rect.texture = tex
	else:
		print("Erreur : texture vidéo non disponible.")
