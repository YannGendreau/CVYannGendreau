
extends Control
class_name SpeechBubble

@onready var bubble = $Bubble
@onready var label = $Bubble/MarginContainer/Text
@onready var margin_container = $Bubble/MarginContainer
@onready var arrow = $Bubble/Arrow


const MAX_WIDTH := 400
const MARGIN := 12

func set_text(text: String) -> void:
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL

	# largeur max
	label.custom_minimum_size = Vector2(MAX_WIDTH, 0)

	# attendre la frame suivante pour recalcul
	await get_tree().process_frame
	
	#print('la taille du texte est:', label.custom_minimum_size)

	# récupérer taille du texte calculée après wrap
	var text_size = label.get_combined_minimum_size()
	
	# ajuster la bulle autour du texte
	bubble.custom_minimum_size = text_size + Vector2(MARGIN * 2, MARGIN * 2)

	# ajuster la taille globale
	custom_minimum_size = bubble.custom_minimum_size

	# placer la flèche centrée sous la bulle
	arrow.position = Vector2(
		bubble.size.x / 2 - arrow.size.x / 2,
		bubble.size.y - 4   # petit offset vers le bas
	)
	
		# Gauche
	arrow.position.x = 40
	# Droite
	#arrow.position.x = size.x - arrow.size.x - 10

	visible = true


func hide_bubble() -> void:
	visible = false


# clic n’importe où pour fermer
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not bubble.get_global_rect().has_point(get_viewport().get_mouse_position()):
			queue_free()
