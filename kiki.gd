#extends "res://scripts/ContextualObject.gd"
#@export var object_name := "kiki"  # 👈 unique pour chaque objet
#@export var context_menu_path: NodePath
#@export var scene_path := "res://scenes/scene_tv.tscn"
#@export var player_target_position := Vector2(100, 0)
#@export var scene_name := "kiki" 
#
#func _ready():
	#mouse_entered.connect(_on_mouse_entered)
	#mouse_exited.connect(_on_mouse_exited)
	#ensure_click_area()
	#sprite.play('ears')
#
#func _on_mouse_entered():
	#Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
#
#func _on_mouse_exited():
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
#
#func ensure_click_area():
	#if has_node("ClickArea"):
		#return $ClickArea
#
	#var area = Area2D.new()
	#area.name = "ClickArea"
	#var shape = CollisionShape2D.new()
	#var rect = RectangleShape2D.new()
		## taille approximative ; ajuste si besoin
	#rect.extents = Vector2(40, 40)
	#shape.shape = rect
	#area.add_child(shape)
	#add_child(area)
	#area.collision_layer = 1
	#area.collision_mask = 1
#
		## connect events
	#area.mouse_entered.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	#area.mouse_exited.connect(func(): Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	#area.input_event.connect(func(viewport, event, shape_idx):
		#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#print("🐶 ClickArea detected click")
			#var menu = get_node(context_menu_path)
			##menu.target_name = object_name  # 👈 essentiel !
			#menu.visible = true              # 👈 rend le menu visible
			#menu.position = global_position  # 👈 positionne le menu au-dessus de Kiki
			#GameManager.on_object_clicked(object_name)  # 👈 Déclare le nom
	#)
	#return area
	
extends "res://scripts/ContextualObject.gd"
#@export var interaction_offset := Vector2(-10, 0)  # position du perso relative à l’objet
@export var object_name := "kiki"  # 👈 unique pour chaque objet
@export var context_menu_path: NodePath
@export var scene_path := "res://scenes/scene_tv.tscn"
@export var player_target_position := Vector2(100, 0)
@export var scene_name := "kiki" 


func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var menu = get_node(context_menu_path)
		var object_name = self.object_name
		menu.target_name = object_name  # 👈 essentiel !
		GameManager.on_object_clicked(object_name)  # 👈 Déclare le nom

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
