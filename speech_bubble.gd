#extends Control
#class_name SpeechBubble
#
#@onready var label = $Bubble/Text
#@onready var bubble = $Bubble
#@onready var arrow = $Arrow
#
## Largeur max autorisée pour la bulle avant retour à la ligne
#const MAX_WIDTH := 300
#const PADDING := Vector2(20, 10)
#
#func _ready():
	## Réglages initiaux du Label
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.custom_minimum_size.x = MAX_WIDTH
	#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	#
#
#func set_text(new_text: String) -> void:
	#label.text = new_text
#
	#await get_tree().process_frame  # attendre que le texte s'affiche
	##await resized
	## Ajustement de la bulle à la taille du texte + padding
	#var text_size = label.get_combined_minimum_size()
	#bubble.custom_minimum_size = text_size + PADDING
	#
	#arrow.anchor_top = 0
	#arrow.anchor_bottom = 0
	#arrow.anchor_left = 0.5
	#arrow.anchor_right = 0.5
	##arrow.offset_top = bubble.height
		## Positionner la flèche
	#arrow.position = Vector2(
		#bubble.position.x + bubble.size.x + 50,
		#bubble.position.y + bubble.size.y + 49  # juste en dessous
	#)
	#
	#show()

##########################################################################################


#extends Control
#
#class_name SpeechBubble
#
##@onready var label = $Bubble/Text
#@onready var label = $Bubble/MarginContainer/Text
#@onready var margin_container = $Bubble/MarginContainer
#@onready var bubble = $Bubble
#@onready var arrow = $Bubble/Arrow
##
##const MAX_WIDTH := 350
#const MARGIN := 12
#const MAX_HEIGHT := 200
##
### Affiche une bulle de dialogue avec le texte fourni
##func show_bubble(text: String) -> void:
	##label.text = text
	##
	#### Surcharge du thème (Godot 4 → add_theme_*_override)
	###label.add_theme_constant_override("line_spacing", 2)
	###label.add_theme_color_override("font_color", Color.WHITE)
###
	#### On force le Label à recalculer sa taille
	###label.reset_size()
##
	### Ajuster la taille du Panel autour du texte
	###var margin = 12
	###bubble.custom_minimum_size = Vector2(
		###label.size.x + margin * 2,
		###label.size.y + margin * 2
	###)
##
	### Centrer le texte dans le panel
	###label.position = Vector2(margin, margin)
	###label.autowrap_mode = TextServer.AUTOWRAP_WORD
	##
	###arrow.anchor_top = 0
	###arrow.anchor_bottom = 0
	###arrow.anchor_left = 0.5
	###arrow.anchor_right = 0.5
	###arrow.offset_top = bubble.height
		#### Positionner la flèche
	###arrow.position = Vector2(
		###bubble.position.x + bubble.size.x + 50,
		###bubble.position.y + bubble.size.y + 49  # juste en dessous
		###)
##
##
	###visible = true
##
### Cache la bulle
##func hide_bubble() -> void:
	##visible = false
	##
##func set_text(text: String) -> void:
	##label.text = text
	##label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	##label.custom_minimum_size = Vector2(MAX_WIDTH, 0)  # largeur max, hauteur libre
##
	##label.reset_size()
	##await get_tree().process_frame
##
	##var text_size = label.get_combined_minimum_size()
	##var height = min(text_size.y, 200)  # limite hauteur si besoin
##
	### Ajuste le NinePatchRect autour du texte
	##bubble.custom_minimum_size = Vector2(
		##MAX_WIDTH + MARGIN * 2,
		##height + MARGIN * 2
	##)
##
	### Place bien le label à l'intérieur
	##label.position = Vector2(MARGIN, MARGIN)
##
	### Ajuste la bulle globale (le Control qui contient tout)
	##custom_minimum_size = bubble.custom_minimum_size
##
	##visible = true
	#
#const MAX_WIDTH := 330
#
#func _ready():
	#print("Bubble:", bubble)
	#print("Label:", label)
#
#
#func set_text(text: String) -> void:
	#label.text = text
	#label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#label.position = Vector2(MARGIN, MARGIN)
#
	#label.custom_minimum_size = Vector2(MAX_WIDTH, 0)  # largeur max, hauteur libre
	#
	## Forcer recalcul une frame plus tard
	#await get_tree().process_frame
#
	## Taille du texte (après autowrap)
	#var text_size = label.get_combined_minimum_size()
#
	## Ajuster le NinePatchRect autour du texte (+ marges déjà gérées par le container)
	#bubble.custom_minimum_size = Vector2(
		#min(text_size.x, MAX_WIDTH),
		#text_size.y
	#)
	#bubble.custom_minimum_size = text_size + Vector2(MARGIN * 2, MARGIN * 2)
	## Ajuster la bulle globale
	#custom_minimum_size = bubble.custom_minimum_size
	#
	### --- Positionner la flèche ---
	##arrow.position = Vector2(
		##(bubble.size.x - arrow.size.x) / 2,  # centre horizontal
		##bubble.size.y - 1                    # pile en bas (ajuste le -1 si besoin)
	##)
#
	#visible = true
#
##func set_text(text: String) -> void:
	### Mettre le texte
	##label.text = text
	### Wrapping automatique
	##label.autowrap_mode = TextServer.AUTOWRAP_WORD
		##
	###Justification horizontale
	##label.horizontal_alignment = Label.HORIZONTAL_ALIGNMENT_FILL
		##
		### Limiter la largeur max
	##label.custom_minimum_size.x = MAX_WIDTH
	##label.custom_minimum_size.y = 0  # laisse la hauteur libre
		##
		### Forcer recalcul du label
	##label.reset_size()
		##
		### Récupérer la taille réelle du label
	##var text_size = label.get_size()
		##
		### Ajuster la bulle autour du texte (MarginContainer gère les marges)
	##bubble.custom_minimum_size = text_size
		##
		### Ajuster la taille du Control principal
	##custom_minimum_size = bubble.custom_minimum_size
		##
	##visible = true
##
		### Placer la flèche sous la bulle, centrée horizontalement
	##arrow.anchor_top = 0
	##arrow.anchor_bottom = 0
	##arrow.anchor_left = 0.5
	##arrow.anchor_right = 0.5
	##arrow.position = Vector2(bubble.custom_minimum_size.x / 2, bubble.custom_minimum_size.y)
#
##func hide_bubble() -> void:
	##visible = false
	#
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		## Vérifie si on clique en dehors de la bulle
		#if not bubble.get_global_rect().has_point(get_viewport().get_mouse_position()):
			#queue_free()
##############################################################################################
extends Control
class_name SpeechBubble

@onready var bubble = $Bubble
@onready var label = $Bubble/MarginContainer/Text
@onready var margin_container = $Bubble/MarginContainer
@onready var arrow = $Bubble/Arrow

const MAX_WIDTH := 270
const MARGIN := 12

func set_text(text: String) -> void:
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL

	# largeur max
	label.custom_minimum_size = Vector2(MAX_WIDTH, 0)

	# attendre la frame suivante pour recalcul
	await get_tree().process_frame

	# récupérer taille du texte calculée après wrap
	var text_size = label.get_combined_minimum_size()

	# ajuster la bulle autour du texte
	bubble.custom_minimum_size = text_size + Vector2(MARGIN * 2, MARGIN * 2)

	# ajuster la taille globale
	custom_minimum_size = bubble.custom_minimum_size

	# placer la flèche centrée sous la bulle
	arrow.position = Vector2(
		bubble.size.x / 2 - arrow.size.x / 2,
		bubble.size.y - 2   # petit offset vers le bas
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

	
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed:
		## Vérifie si on clique en dehors de la bulle
		#if not bubble.get_global_rect().has_point(get_viewport().get_mouse_position()):
			#queue_free()
