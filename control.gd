extends Control

@onready var background = $Control/Background
@onready var content = $Control/Content  # maintenant un TextureRect

func _ready():
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	background.connect("gui_input", Callable(self, "_on_background_gui_input"))

func _on_background_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		print('clic')
		# ✅ Avec TextureRect : pas besoin de calculer
		if not content.get_global_rect().has_point(mouse_pos):
			queue_free()  # clic à l’extérieur → fermer
			print('clac')
