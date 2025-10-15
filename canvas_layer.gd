extends CanvasLayer

#@onready var send_button = $ContactForm/SendButton
#@onready var fade_layer := $FadeLayer

#func _ready():
	#send_button.pressed.connect(_on_send_pressed)

#func _on_send_pressed():
	#print("✉️ Message envoyé (simulation)")
##
	##if not Engine.has_singleton("FadeLayer"):
		##print("❌ FadeLayer introuvable — vérifie l’autoload")
		##return
#
	## Appel avec le bon autoload (global)
	##await fade_layer.fade_out(1.0)
	#get_tree().change_scene_to_file("res://scenes/informatique.tscn")
	##await fade_layer.fade_in(1.0)
#
	## Optionnel : fermer le formulaire
	#hide()
	
signal on_transition_finished

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
