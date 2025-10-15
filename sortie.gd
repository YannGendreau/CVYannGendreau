extends Node2D

@onready var path_follower: PathFollow2D = $Path2D/PathFollower
@onready var player: Node2D = $Path2D/PathFollower/Employeur/AnimatedSprite2D
@onready var yann: Node2D = $Yann   # ton perso Yann
@onready var yann_anim: AnimatedSprite2D = $Yann/AnimatedSprite2D   # ton perso Yann
@onready var speech_bubble_container := get_node("/root/Sortie/UI/SpeechBubbleContainer")
var speech_bubble_scene: PackedScene = preload("res://speechbubble.tscn")
@onready var arrow := get_node("/root/Sortie/UI/SpeechBubbleContainer/")
@onready var buttons := $Background/Buttons
@onready var canvas_layer := $CanvasLayer
@onready var send_button := get_node("/root/Sortie/CanvasLayer/ContactForm/SendButton")




func _ready():
	# 🔹 Placer le player hors écran au début
	path_follower.progress_ratio = 0.0
	player.play("walk_left")  # si tu as une anim "walk"

	# 🔹 Déplacer automatiquement le player jusqu’à la fin du Path
	var tween = create_tween()
	tween.tween_property(path_follower, "progress_ratio", 1.0, 2.0) # durée = 3s

	# 🔹 Quand le mouvement est fini
	tween.finished.connect(_on_player_arrived)
	
		## Quand le player a fini son trajet → bulle sur Yann
	#player.reached_target.connect(_on_player_arrived)
	
	buttons.visible = false
	canvas_layer.visible = false
	
	send_button.pressed.connect(_on_send_pressed)

	

func _on_player_arrived():
	player.play("idle")
	print("✅ Le player est arrivé au bout du path")
	show_speech_bubble_above(yann, "J'espère que votre visite a été instructive. Êtes-vous intéressé par mon profil ?")
	
func show_speech_bubble_above(character: Node2D, text: String) -> void:
	if not speech_bubble_scene or not speech_bubble_container:
		print("❌ Impossible d’afficher la bulle")
		return

	var bubble := speech_bubble_scene.instantiate()
	#var ui_layer = get_tree().root.get_node("ChezYann/UI/SpeechBubbleContainer")
	#ui_layer.add_child(bubble)
	speech_bubble_container.add_child(bubble)

	# Position au-dessus du perso Yann
	var bubble_offset := Vector2(500, 800)  # ajuste selon la taille du sprite
	var world_pos: Vector2 = character.global_position - bubble_offset
	var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos

	bubble.position = screen_pos
	bubble.set_text(text)
	
	bubble.flip_arrow(true)


	# Disparition après 3s
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(bubble):
		bubble.queue_free()
		show_choice_buttons()

func show_choice_buttons():
	buttons.visible = true
	
func _on_oui_pressed() -> void:
	await get_tree().create_timer(0.5).timeout  # idle 2 sec
	yann_anim.play('joy')
	await get_tree().create_timer(2.0).timeout  # idle 2 sec
	canvas_layer.visible = true
	
	
func _on_non_pressed() -> void:
	await get_tree().create_timer(0.5).timeout  # idle 2 sec
	yann_anim.play('sad')
	await get_tree().create_timer(1.0).timeout
	await FadeLayer.transition_to_scene("res://credits_non.tscn")
	
func _on_send_pressed():
	print("✉️ Message envoyé (simulation)")
	$CanvasLayer.visible = false
	await get_tree().create_timer(1.0).timeout
	await FadeLayer.transition_to_scene("res://credits_oui.tscn")
	
	
	#print("✉️ Message envoyé (simulation)")
	#$CanvasLayer.visible = false
#
	## Petit délai avant de lancer le fade noir (par exemple 1 seconde)
	#await get_tree().create_timer(1.0).timeout
#
	## Lancer le fondu noir
	#FadeLayer.transition()
#
	## Quand le fondu noir est terminé (le signal est émis à la fin du fade_black)
	#FadeLayer.on_transition_finished.connect(func ():
		## Changer de scène pendant que l'écran est noir
		#get_tree().change_scene_to_file("res://credits.tscn")
	#, CONNECT_ONE_SHOT)
	
	
	
	#await fade_layer.fade_in(1.0)
