#extends Node2D
#
#@onready var video_player = $VideoStreamPlayer
#@onready var texture_rect = $TextureRect
#@onready var return_bouton = $ReturnButton/AnimatedSprite2D
#@export var scene_name : String = "" 
#
#func _on_return_button_pressed() -> void:
	#print("Retour en arrière")
	#GameManager.last_clicked_object = "tv"
	##GameManager.last_object_interacted = "tv"
	#get_tree().change_scene_to_file("res://chez_yann.tscn")
#
#func _ready():
	#return_bouton.play("glow")
	##video_player.visible = false
	#video_player.play()
	#wait_for_texture()
#
#func wait_for_texture():
	#await get_tree().process_frame  # attendre une frame pour charger la texture
	#var tex = video_player.get_video_texture()
	#if tex:
		#texture_rect.texture = tex
	#else:
		#print("Erreur : texture vidéo non disponible.")
		
extends Node2D

@onready var video_buttons := $VideoButtons/VBoxContainer
@onready var player_layer := $VideoPlayerLayer
@onready var video_player := $VideoPlayerLayer/VideoStreamPlayer
@onready var close_button := $VideoPlayerLayer/Close
@onready var overlay := $VideoPlayerLayer/ColorRect
@onready var return_button := $ReturnButton

func _ready():
	player_layer.visible = false
	#close_button.pressed.connect(_on_close_pressed)
	return_button.pressed.connect(_on_return_pressed)
	close_button.modulate = Color(1,0,0)
	close_button.pressed.connect(func():
		print("✅ Bouton cliqué direct"))
	print("🎬 player_layer =", player_layer)

	# Connexion des deux boutons films
	$VideoButtons/VBoxContainer/FilmButton1.pressed.connect(_on_film_pressed.bind("res://Videos/COLLAB - 2019 - Real Yann Gendreau - HD - FR_1.ogv"))
	$VideoButtons/VBoxContainer/FilmButton2.pressed.connect(_on_film_pressed.bind("res://Videos/Volontés_final.ogv"))

func _on_film_pressed(video_path: String):
	if not ResourceLoader.exists(video_path):
		push_warning("⚠️ Vidéo introuvable : " + video_path)
		return

	video_player.stream = load(video_path)
	player_layer.visible = true
	video_player.play()

	# Fade-in doux
	overlay.modulate.a = 0.0
	video_player.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 0.7, 0.4)
	tween.tween_property(video_player, "modulate:a", 1.0, 0.4)



func _on_return_pressed():
	print("↩️ Retour à la scène précédente")
	get_tree().change_scene_to_file("res://chez_yann.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and player_layer.visible:
		_on_close_pressed()
	
func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_close_pressed() -> void:
	print("🔴 fermeture demandée")
	var tween = create_tween().set_parallel(true)
	tween.tween_property(video_player, "modulate:a", 0.0, 0.4)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.4)
	tween.finished.connect(func(): print("✅ Tween terminé"))
	await tween.finished
	print("✅ Suite exécutée après fade")
	video_player.stop()
	player_layer.visible = false
	print("✅ Fermé")
