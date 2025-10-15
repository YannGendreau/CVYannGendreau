extends CanvasLayer

signal on_fade_out_finished
signal on_fade_in_finished
signal on_fade_out_fast_finished
signal on_fade_in_fast_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rect: ColorRect = $FondNoir

func _ready() -> void:
	rect.visible = false
	rect.modulate.a = 0.0
	animation_player.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"fade_black":
			on_fade_out_finished.emit()
		"fade_in":
			rect.visible = false
			on_fade_in_finished.emit()
		"fade_out_fast":
			on_fade_out_fast_finished.emit()
		"fade_in_fast":
			rect.visible = false
			on_fade_in_fast_finished.emit()


func fade_out():
	rect.visible = true
	animation_player.play("fade_black")


func fade_in():
	rect.visible = true
	animation_player.play("fade_in")
	
func fade_out_fast():
	rect.visible = true
	animation_player.play("fade_out_fast")


func fade_in_fast():
	rect.visible = true
	animation_player.play("fade_in_fast")


# 🔹 Version finale : fade out -> change scene -> attend chargement -> fade in
func transition_to_scene(scene_path: String) -> void:
	fade_out()
	await on_fade_out_finished

	get_tree().change_scene_to_file(scene_path)

	# 🕐 Attendre une frame pour que la nouvelle scène soit bien instanciée
	await get_tree().process_frame
	await get_tree().process_frame

	# Puis lancer le fade in
	fade_in()

func transition_to_scene_fast(scene_path: String) -> void:
	fade_out_fast()
	await on_fade_out_fast_finished

	get_tree().change_scene_to_file(scene_path)

	# 🕐 Attendre une frame pour que la nouvelle scène soit bien instanciée
	await get_tree().process_frame
	await get_tree().process_frame

	# Puis lancer le fade in
	fade_in_fast()

#extends CanvasLayer
#
#signal on_transition_finished
#
#@onready var animation_player := $AnimationPlayer
#@onready var rect: ColorRect = $FondNoir
#
#func _ready() -> void:
	#rect.visible = true
	#rect.color = Color.BLACK
	#rect.modulate.a = 0.0
	#animation_player.animation_finished.connect(_on_animation_finished)
#
#func _on_animation_finished(anim_name: String) -> void:
	#if anim_name == "fade_black":
		#on_transition_finished.emit()  # informe que le fade noir est fini
	#elif anim_name == "fade_in":
		#rect.visible = false
#
#func fade_out():
	#rect.visible = true
	#animation_player.play("fade_black")
#
#func fade_in():
	#rect.visible = true
	#animation_player.play("fade_in")



#extends CanvasLayer
#
#signal on_transition_finished
#
#@onready var animation_player := $AnimationPlayer
#@onready var rect: ColorRect = $FondNoir
#
#func _ready() -> void:
	#rect.visible = false
	#print("🧩 FadeLayer ready — FondNoir trouvé:", rect)
	#rect.color = Color.BLACK
	#rect.anchor_left = 0.0
	#rect.anchor_top = 0.0
	#rect.anchor_right = 1.0
	#rect.anchor_bottom = 1.0
	#rect.offset_left = 0
	#rect.offset_top = 0
	#rect.offset_right = 0
	#rect.offset_bottom = 0
	#rect.visible = true
	#rect.modulate.a = 0.0
	#animation_player.animation_finished.connect(_on_animation_finished)
	#
#func _on_animation_finished(anim_name):
	#if anim_name == "fade_black":
		#on_transition_finished.emit()
		#animation_player.play('fade_in')
	#elif anim_name ==  "fade_in":
		#rect.visible = false
#
#
#func transition():
	#rect.visible = true
	#animation_player.play("fade_black")
#func _ready():
	#if rect == null:
		#push_error("❌ Aucun ColorRect trouvé dans le FadeLayer !")
		#return
	#rect.color = Color.BLACK
	#rect.visible = true
	#rect.modulate.a = 0.0
#
#func fade_out(duration := 1.0):
	#if rect == null:
		#push_error("❌ Aucun ColorRect trouvé dans le FadeLayer !")
		#return
	#rect.visible = true
	#var tween = create_tween()
	#tween.tween_property(rect, "modulate:a", 1.0, duration)
	#await tween.finished
#
#func fade_in(duration := 1.0):
	#if rect == null:
		#push_error("❌ Aucun ColorRect trouvé dans le FadeLayer !")
		#return
	#rect.visible = true
	#rect.modulate.a = 1.0
	#var tween = create_tween()
	#tween.tween_property(rect, "modulate:a", 0.0, duration)
	#await tween.finished
	#rect.visible = false
