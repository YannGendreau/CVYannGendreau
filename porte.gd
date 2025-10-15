extends "res://scripts/ContextualObject.gd"

#@onready var porte: AnimatedSprite2D = $porte/AnimatedSprite2D

@export var object_name := "porte"  # 👈 unique pour chaque objet
@export var context_menu_path: NodePath
@export var scene_path := "res://sortie.tscn"
@export var player_target_position := Vector2(100, 0)
@export var scene_name := "porte" 

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	sprite.play('close')
	
	if not GameManager.all_objects_visited():
		print("🚪 La porte est encore verrouillée ! Explore d’abord tout.")
		return  # 🚫 bloque le clic

	## ✅ Tous visités → autoriser l’ouverture
	#if GameManager:
#
		#if has_node("AnimatedSprite2D"):
			#await get_tree().process_frame  
			#await get_tree().create_timer(1.0).timeout  # ⏳ 1 seconde
			#sprite.play("open")  # joue l’anim
			#await sprite.animation_finished

	

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	
func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not GameManager.all_objects_visited():
			print("🚪 La porte est encore verrouillée ! Explore d’abord tout.")
			return
		
		if scene_path != "":
			await GameManager.move_player_to_object("porte")
			get_tree().change_scene_to_file(scene_path)
