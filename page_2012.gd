extends Control


@onready var background = $Background
@onready var content = $Page # maintenant un TextureRect
@onready var close_button: Button = $CloseButton
@onready var return_button = get_node("/root/Carton_docs/ReturnButton") 

func _ready():
	close_button.pressed.connect(_on_close_pressed)

func _on_close_pressed() -> void:
	queue_free()  # Ferme la page
	return_button.visible = true
