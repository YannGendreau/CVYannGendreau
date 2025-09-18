extends Control


@onready var background = $Background
@onready var content = $Page # maintenant un TextureRect
@onready var close_button: Button = $CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)

func _on_close_pressed() -> void:
	queue_free()  # Ferme la page
