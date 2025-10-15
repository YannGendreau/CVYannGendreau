extends Control


@onready var background = $Background
@onready var content = $Content/Page # maintenant un TextureRect
@onready var close_button: Button = $CloseButton
@onready var arrow_left: TextureButton = $ButtonL
@onready var arrow_right: TextureButton = $ButtonR
@onready var return_button = get_node("/root/Carton_docs/ReturnButton") 


@export var pages: Array[Texture2D] = []
var current_page: int = 0

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	update_page()
	arrow_left.pressed.connect(_on_arrow_left)
	arrow_right.pressed.connect(_on_arrow_right)

func _on_close_pressed() -> void:
	queue_free()  # Ferme la page
	return_button.visible = true
	
func update_page():
	if pages.is_empty():
		return
	
	# Affiche la bonne page
	content.texture = pages[current_page]
	
	# Active/désactive les flèches selon la position
	arrow_left.visible = current_page > 0
	arrow_right.visible = current_page < pages.size() - 1
	
	for i in range($Content/VBoxContainer/Pages.get_child_count()):
		$Content/VBoxContainer/Pages.get_child(i).visible = (i == current_page)
	
func _on_arrow_left():
	if current_page > 0:
		current_page -= 1
		update_page()
		print("clic")

func _on_arrow_right():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page()
		print("clac")
