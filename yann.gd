extends CharacterBody2D

@onready var yann : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:

	yann.play('idle')
