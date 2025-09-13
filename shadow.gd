extends Sprite2D


func _process(delta):
	# Exemple : ombre plus petite si le perso "saute"
	scale.x = 1.0
	scale.y = clamp(1.0 - position.y * 0.001, 0.5, 1.0)
	modulate = Color(0, 0, 0, 0.2)
