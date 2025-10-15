extends Node2D

@onready var jouer = $Button
@onready var animation_player = $AnimationPlayer


func _on_button_pressed() -> void:
	#animation_player.play("crossfade_in")
	#await animation_player.animation_finished
	#FadeLayer.play("fade")
	#get_tree().change_scene_to_file("res://chez_yann.tscn")
	FadeLayer.transition_to_scene_fast("res://chez_yann.tscn")
