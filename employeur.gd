#extends CharacterBody2D
#
#@onready var path_2d = get_node("/root/ChezYann/Path2D")
#@onready var path_follow = get_node("/root/ChezYann/Path2D/PathFollower")
#@onready var anim = $AnimatedSprite2D
#
#var target_position: Vector2
#var target_offset: float
#var moving = false
#var speed = 100.0
#
#func go_to_offset(offset: float):
	#if not path_follow:
		#push_error("PathFollow2D manquant !")
		#return
#
	#target_offset = offset
	#moving = true
#
#func _physics_process(delta):
	#if moving:
		#var current_offset = path_follow.progress_ratio
		#var direction = sign(target_offset - current_offset)
		#path_follow.progress_ratio += direction * speed * delta
#
		#global_position = path_follow.global_position
#
	## Animation direction
		#if direction != 0:
			#$AnimatedSprite2D.play("walkleft")
			#$AnimatedSprite2D.flip_h = direction < 0
		#else:
			#$AnimatedSprite2D.play("idle")
#
		#if abs(target_offset - path_follow.progress_ratio) < 0.005:
			#moving = false
			#$AnimatedSprite2D.play("idle")
	#
	#
	##if moving:
		##var direction = (target_position - global_position).normalized()
		##velocity = direction * speed
##
		### Change d'animation selon la direction
		##if direction.x > 0:
			##anim.flip_h = false
		##elif direction.x < 0:
			##anim.flip_h = true
##
		##move_and_slide()
##
		##if global_position.distance_to(target_position) < 4.0:
			##moving = false
			##velocity = Vector2.ZERO
			##play_idle_animation()
#
#func play_walk_animation():
	#if not anim.is_playing() or anim.animation != "walk":
		#anim.play("walk")
#
#func play_idle_animation():
	#if anim.animation != "idle":
		#anim.play("idle")

##################################################
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var path_follower = get_node("/root/ChezYann/Path2D/PathFollower")

var moving = false
var target_ratio: float = 0.0
var speed: float = 0.5  # ajustable

var movement_target : Vector2 

func go_to(ratio: float) -> void:
	path_follower.progress_ratio = ratio
	global_position = path_follower.global_position
	look_at(path_follower.global_position)
	_play_animation("idle")  # Ou "walk" si tu comptes l’animer ensuite

func _play_animation(anim_name: String) -> void:
	if animated_sprite != null:
		animated_sprite.play(anim_name)

#func _process(delta):
#
	#if not moving:
		#return
		#
	#if moving:
		#var direction = (movement_target - global_position)
		#if direction.length() < 2.0:
			#moving = false
			#velocity = Vector2.ZERO
		#else:
			#velocity = direction.normalized() * speed
			#move_and_slide()
#
	#var current = path_follower.progress_ratio
	#var direction = sign(target_ratio - current)
	#var step = delta * speed * direction
#
	#path_follower.progress_ratio += step
	#global_position = path_follower.global_position
#
	## Gérer l'animation gauche/droite en fonction du déplacement
	#if direction != 0:
		#animated_sprite.flip_h = direction < 0
#
	## Vérifie si on est proche de la destination
	#if abs(path_follower.progress_ratio - target_ratio) < 0.005:
		#path_follower.progress_ratio = target_ratio
		#global_position = path_follower.global_position
		#moving = false
	#if update_animation():
		#update_animation()
	#else:
		#print('pas danim')		
##
#func update_animation():
	#if moving:
		#animated_sprite.play("walkleft")
	#else:
		#animated_sprite.play("idle")


################################################
#extends CharacterBody2D
#
#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#
#var moving = false
#var target_ratio: float = 0.0
#@onready var path_follower = get_node("/root/ChezYann/Path2D/PathFollower")
#
#func go_to(ratio: float):
	#target_ratio = ratio
	#moving = true
#
#func _process(delta):
	#if moving:
		#var current = path_follower.progress_ratio
		#var direction = sign(target_ratio - current)
		#var step = delta * 0.2  # vitesse ajustable
		#
		#global_position = path_follower.global_position
#
		## Arrêt automatique quand proche du point cible
		#if abs(path_follower.progress_ratio - target_ratio) < 0.005:
			#path_follower.progress_ratio = target_ratio
			#moving = false
			## TODO: lancer animation idle ici
#########################################################################
#var target_position: Vector2
#var 
#var is_moving := false
#var speed := 100.0
#var direction := 1
#
#func _physics_process(delta):
	#if moving:
		#var distance = movement_target - global_position
#
		#if distance.length() > 2:  # seuil d’arrêt pour éviter les tremblements
			#velocity = distance.normalized() * speed
			#move_and_slide()
			#animated_sprite.play("walkleft")
#
			## Mise à jour direction (flip_h)
			#direction = sign(distance.x)
			#animated_sprite.flip_h = direction < 0
		#else:
			#moving = false
			#velocity = Vector2.ZERO
			#animated_sprite.play("idle")
#Grok
	#if moving:
		## Interpolation progressive vers la cible
		#var current_ratio = progress_ratio
		#var distance = abs(target_progress_ratio - current_ratio)
		#if distance > 0.001:  # Petite marge pour éviter les micro-ajustements
			#var step = speed * delta / get_parent().curve.get_baked_length()
			#progress_ratio = move_toward(current_ratio, target_progress_ratio, step)
			## Jouer l'animation de marche
			#animated_sprite.play("walk")
		#else:
			#is_moving = false
			#animated_sprite.play("idle")  # Revenir à l'animation idle quand le déplacement est fini
#
#func go_to(pos: float):
	#target_position = pos
	#is_moving = true
#
#func play_idle():
	#animated_sprite.play("idle")
	
	
	
	
	
	
