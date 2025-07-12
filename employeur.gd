extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var path_follower = get_node("/root/ChezYann/Path2D/PathFollower")

var moving = false
var target_ratio: float = 0.0
var speed: float = 0.5  # ajustable

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
		update_animation()

func update_animation():
	if moving:
		animated_sprite.play("walkleft")
	else:
		animated_sprite.play("idle")
