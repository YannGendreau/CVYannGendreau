#extends "res://scripts/ContextualObject.gd"
##extends CharacterBody2D
##@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
#
#@export var object_name := "kiki"  # 👈 unique pour chaque objet
#@export var context_menu_path: NodePath
#@export var scene_path := "res://informatique.tscn"
#@export var player_target_position := Vector2(100, 0)
#@export var scene_name := "kiki" 
#
#func _ready():
	#mouse_entered.connect(_on_mouse_entered)
	#mouse_exited.connect(_on_mouse_exited)
	#mouse_entered.connect(func(): print("🐶 souris entrée sur kiki"))
	#mouse_exited.connect(func(): print("🐶 souris sortie de kiki"))
	#input_event.connect(func(viewport, event, shape_idx): 
		#if event is InputEventMouseButton and event.pressed:
			#print("🐶 clic détecté sur kiki")
	#)
	#print("Kiki prêt :", name)
	#
#func _on_area_input_event(viewport, event, shape_idx):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#print('Et clic')
		#var menu = get_node(context_menu_path)
		#var object_name = self.object_name
		#menu.target_name = object_name  # 👈 essentiel !
		#menu.show_menu(global_position, scene_path, player_target_position)
		#GameManager.on_object_clicked(object_name)  # 👈 Déclare le nom
		#print("Clique sur Kiki détecté")
	#
#func _on_mouse_entered():
	#Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
#
#func _on_mouse_exited():
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
#
#func _input_event(viewport, event, shape_idx):
	#if event is InputEventMouseMotion:
		#print("🐶 La souris passe sur Kiki !")
		#

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
		#menu.target_name = object_name  # 👈 essentiel !
		menu.show_menu(global_position, scene_path, player_target_position)
		GameManager.on_object_clicked(object_name)  # 👈 Déclare le nom

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
