extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Sprite2D = $shadow
@onready var path_follower = get_node("/root/ChezYann/Path2D/PathFollower")

signal reached_target   # ✅ déclaration du signal

var moving = false
var target_ratio: float = 0.0
var speed: float = 0.4  # ajustable

var forced_anim: String = ""

var last_direction: int = 1  # 1 = droite, -1 = gauche


func _ready() -> void:

	add_to_group("Employeur")
	

func go_to(ratio: float):
	#target_ratio = path_follower.curve.sample_baked(ratio * path_follower.curve.get_baked_length())
	target_ratio = clamp(ratio, 0.0, 1.0)
	moving = true
	update_animation()

func _process(delta):
	if not moving:
		return

	var current = path_follower.progress_ratio
	var direction = sign(target_ratio - current)

	# garder la direction pour l'anim idle
	if direction != 0:
		last_direction = direction  

	var step = delta * speed * direction
	path_follower.progress_ratio += step
	global_position = path_follower.global_position

	# Vérifie si on est proche de la destination
	if abs(path_follower.progress_ratio - target_ratio) < 0.005:
		path_follower.progress_ratio = target_ratio
		global_position = path_follower.global_position
		moving = false
		emit_signal("reached_target")
		update_animation()
	else:
		update_animation()  # mettre à jour en temps réel
	
func update_animation():
	if forced_anim != "":
		animated_sprite.play(forced_anim)
		return

	if moving:
		if last_direction < 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")


func _on_context_menu_action_selected(action: String, object_name: String):
	#GameManager.last_object_interacted = object_name  # Ajouter cette ligne
	GameManager.last_clicked_object = object_name  # Ajouter cette ligne

	if action == "eye":
		GameManager.move_to_object(object_name)
	elif action == "hand":
		GameManager.move_to_object(object_name)
		var scene_path = "res://scenes/" + object_name + ".tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Erreur : Scène ", scene_path, " non trouvée")
			
#func face_direction(facing: String):
	#match facing:
		#"left":
			#animated_sprite.play("idle")
		#"right":
			#animated_sprite.play("idle_right")
		#"back":
			#animated_sprite.play("back")
		#"front":
			#animated_sprite.play("front")
		#_:
			#animated_sprite.play("front") # fallback

func face_direction(facing: String):
	animated_sprite.play(facing)  # joue directement le nom
	
# Dans employeur.gd (ton player)
func get_progress_ratio() -> float:
	var pf = get_parent()
	if pf is PathFollow2D:
		return pf.progress_ratio
	return -1.0

func set_progress_ratio(value: float) -> void:
	var pf = get_parent()
	if pf is PathFollow2D:
		pf.progress_ratio = value
