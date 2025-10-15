extends AnimatedSprite2D

#signal animation_finished

func _ready() -> void:
	
	play("idle")
	flip_h = true
	animation_finished.connect(_kriss_anim)
	
func _kriss_anim():
	match animation:
		"idle":
			play("walk")
		"walk":
			play("punch")
		"punch":
			play("idle")
	
