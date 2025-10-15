extends "res://scripts/ContextualObject.gd"

@export var object_name := "kiki"  # 👈 unique pour chaque objet
@export var context_menu_path: NodePath
@export var scene_path := "res://informatique.tscn"
@export var player_target_position := Vector2(100, 0)
@export var scene_name := "kiki" 
#@onready var anim = $AnimatedSprite2D

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	sprite.play('ears')
	
		# Empêche "jump" et "down" de boucler même si tu as oublié dans l'éditeur
	var frames := sprite.sprite_frames
	if frames:
		for anim_name in ["jump", "down"]:
			if frames.has_animation(anim_name):
				frames.set_animation_loop(anim_name, false)

	# Par contre on laisse "idle" et "ears" boucler
	for anim_name in ["idle", "ears"]:
		if frames.has_animation(anim_name):
			frames.set_animation_loop(anim_name, true)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var menu = get_node(context_menu_path)
		var object_name = self.object_name
		GameManager.on_object_clicked(object_name) 
		menu.show_menu(global_position, scene_path, player_target_position)
		
func _on_eye_icon_pressed() -> void:
	GameManager.on_eye_clicked(self)
	


func react_to_action(action: String):
	if action == "eye":
		# 👀 simple bulle (côté GameManager)
		pass

	elif action == "hand":
		# 🐶 Dérouler les animations
		_play_hand_sequence()


func _play_hand_sequence() -> void:
	sprite.play("jump")
	await sprite.animation_finished

	sprite.play("idle")
	await get_tree().create_timer(3.0).timeout  # idle 2 sec

	sprite.play("down")

	await sprite.animation_finished

	sprite.play("ears")
