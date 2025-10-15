extends CanvasLayer

@onready var vbox = $VBoxContainer
@onready var anim = $AnimationPlayer
@onready var sprite = $Sunset  # chemin
@onready var replay = $Replay

@export var delay := 0.5
@export var duration := 1.0

func _ready():
	sprite.modulate.a = 0.0
	sprite.visible = true
	await get_tree().create_timer(delay).timeout
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 1.0, duration)
	await tween
	
	
	anim.play("scroll")
	
#func end_credits():
	#get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
func _on_replay_pressed() -> void:
	FadeLayer.transition_to_scene("res://chez_yann.tscn")
