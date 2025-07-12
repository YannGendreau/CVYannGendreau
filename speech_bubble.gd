extends Control
class_name SpeechBubble

@onready var label = $Bubble/Text
@onready var bubble = $Bubble
@onready var arrow = $Arrow

# Largeur max autorisée pour la bulle avant retour à la ligne
const MAX_WIDTH := 300
const PADDING := Vector2(20, 10)

func _ready():
	# Réglages initiaux du Label
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = MAX_WIDTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	

func set_text(new_text: String) -> void:
	label.text = new_text

	await get_tree().process_frame  # attendre que le texte s'affiche
	#await resized
	# Ajustement de la bulle à la taille du texte + padding
	var text_size = label.get_combined_minimum_size()
	bubble.custom_minimum_size = text_size + PADDING
	
	arrow.anchor_top = 0
	arrow.anchor_bottom = 0
	arrow.anchor_left = 0.5
	arrow.anchor_right = 0.5
	#arrow.offset_top = bubble.height
		# Positionner la flèche
	arrow.position = Vector2(
		bubble.position.x + bubble.size.x + 50,
		bubble.position.y + bubble.size.y + 49  # juste en dessous
	)
	
	show()
