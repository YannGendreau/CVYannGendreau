extends CharacterBody2D

@onready var computer: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	computer.play("hue")
