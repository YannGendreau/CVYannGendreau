extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var path_follower = get_node("/root/ChezYann/Path2D/PathFollower")

signal reached_target   # ✅ déclaration du signal

var moving = false
var target_ratio: float = 0.0
var speed: float = 0.5  # ajustable

var forced_anim: String = ""


func _ready() -> void:
	animated_sprite.play("idle")
	animated_sprite.animation_finished.connect(_on_animation_finished)

	add_to_group("Employeur")

func go_to(ratio: float):
	#target_ratio = path_follower.curve.sample_baked(ratio * path_follower.curve.get_baked_length())
	target_ratio = clamp(ratio, 0.0, 1.0)
	moving = true
	update_animation()
	
#func go_to(offset_ratio: float, facing: String = "right"):
	#if path_follower:
		#path_follower.progress_ratio = offset_ratio
#
	#match facing:
		#"left":
			#$AnimatedSprite2D.play("walkleft")
		#"right":
			#$AnimatedSprite2D.play("walkright")
		#"back":
			#$AnimatedSprite2D.play("back")
			#
	#target_ratio = clamp(offset_ratio, 0.0, 1.0)
	#moving = true
	#update_animation()
	#
#func set_idle(facing: String):
	#match facing:
		#"left":
			#$AnimatedSprite2D.play("idle")
		#"right":
			#$AnimatedSprite2D.play("idle_right")
		#"back":
			#$AnimatedSprite2D.play("back")

func _process(delta):
	if not moving:
		return

	var current = path_follower.progress_ratio
	var direction = sign(target_ratio - current)
	var step = delta * speed * direction

	path_follower.progress_ratio += step
	global_position = path_follower.global_position

	# Gérer l'animation gauche/droite en fonction du déplacement
	if direction != 0:
		animated_sprite.flip_h = direction < 0

	# Vérifie si on est proche de la destination
	if abs(path_follower.progress_ratio - target_ratio) < 0.005:
		path_follower.progress_ratio = target_ratio
		global_position = path_follower.global_position
		moving = false
		emit_signal("reached_target")
		update_animation()
		
#var target_position = 0.0  # Position cible en unités absolues
##var moving = false  # État de déplacement	
#func _process(delta):
	#if moving:
		#var curve_length = get_parent().curve.get_baked_length()
		#var current_progress = progress  # Utiliser une variable locale pour plus de clarté
		#var current_ratio = current_progress / curve_length
		#var distance = abs(target_position - current_progress)
		#print("Déplacement : current_progress=", current_progress, " target=", target_position, " distance=", distance)
		#if distance > 1:  # Petite marge
			#var move_speed = speed * delta
			#progress = move_toward(current_progress, target_position, move_speed)
			#if animated_sprite:
				#animated_sprite.play("walk")
		#else:
			#moving = false
			#if animated_sprite:
				#animated_sprite.play("idle")

func update_animation():
	if forced_anim != "":
		animated_sprite.play(forced_anim)
		return

	if moving:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func _on_context_menu_action_selected(action: String, object_name: String):
	#GameManager.last_object_interacted = object_name  # Ajouter cette ligne
	GameManager.last_clicked_object = object_name  # Ajouter cette ligne

	if action == "eye":
		#_show_bubble_text(object_name)
		GameManager.move_to_object(object_name)
	elif action == "hand":
		GameManager.move_to_object(object_name)
		var scene_path = "res://scenes/" + object_name + ".tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Erreur : Scène ", scene_path, " non trouvée")
			
func _on_animation_finished():
	if forced_anim != "":
		forced_anim = ""
		update_animation()
			
	
