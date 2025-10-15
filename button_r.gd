extends TextureButton

func _ready():
	_start_blink()
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _start_blink():
	var tween = create_tween()
	tween.set_loops()  # boucle infinie
	tween.tween_property(self, "modulate:a", 0.3, 0.5)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
