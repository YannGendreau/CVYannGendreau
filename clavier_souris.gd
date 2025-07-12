extends CharacterBody2D

@onready var clavier: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	clavier.play('hue')
