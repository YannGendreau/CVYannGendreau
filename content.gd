extends TextureRect

func _ready():
	if texture:
		# Ajuster le TextureRect à la taille réelle de la texture
		custom_minimum_size = texture.get_size()
		size = texture.get_size()
		anchor_left = 0.0
		anchor_top = 0.0
		anchor_right = 0.0
		anchor_bottom = 0.0
		position = Vector2.ZERO
