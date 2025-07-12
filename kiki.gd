extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("Idle")
	#context_menu.visible = false

#func _input_event(viewport, event, shape_idx):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#show_context_menu()
#
#func show_context_menu():
	#var offset = Vector2(0, -50)
	#context_menu.global_position = global_position + offset
	#context_menu.visible = true
#
#func hide_context_menu():
	#context_menu.visible = false
#
#func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if not GameManager.is_player_moving():
		#GameManager.move_player_to(global_position - Vector2(30, 0))
		#if context_menu:
			#context_menu.visible = false
