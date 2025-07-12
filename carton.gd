extends "res://scripts/ContextualObject.gd"

@export var object_name := "carton"  # 👈 unique pour chaque objet
@export var context_menu_path: NodePath
@export var scene_path := "res://carton_docs.tscn"
@export var player_target_position := Vector2(100, 0)
@export var scene_name := "carton" 


func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print('Et clic')
		var menu = get_node(context_menu_path)
		var object_name = self.object_name
		menu.target_name = object_name  # 👈 essentiel !
		menu.show_menu(global_position, scene_path, player_target_position)
		GameManager.on_object_clicked(object_name)  # 👈 Déclare le nom

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
