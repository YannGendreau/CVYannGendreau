extends Node2D

@export var scene_name: String = ""
@onready var return_button = $ReturnButton/AnimatedSprite2D
@onready var ecran: TextureRect = $Ecran
@onready var btn_prev: TextureButton = $ButtonL
@onready var btn_next: TextureButton = $ButtonR
@export var images: Array[Texture2D] = []
@onready var francecam: Control = $Francecam   # ta page spéciale (logo + texte + lien)
@onready var kriss: AnimatedSprite2D = $Kriss
var current_index: int = 0
const FRANCECAM_INDEX = 12

@onready var rich_label : RichTextLabel = $Francecam/RichTextLabel


func _ready() -> void:
	
	kriss.visible = false

	print(current_index)
	return_button.play("glow")

	if images.is_empty():
		push_warning("⚠️ Aucune image définie dans la variable 'images'")
		return

	# Connecter les boutons
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_next.pressed.connect(_on_next_pressed)

	# Masquer la page Francecam au départ
	francecam.visible = false

	# Afficher la première image
	_update_image()
	
	rich_label.bbcode_enabled = true
	rich_label.text = "[color=red]FranceCam[/color] est une base de données en ligne consacrée aux caméra utilisées dans les films et productions audiovisuelles francophones.
Le site permet de consulter des fiches détaillées d’œuvres, d’identifier les modèles de caméras et de suivre les tendances du matériel cinéma en France.

Développé avec [color=orange][b]Symfony[/b][/color], [color=orange][b]JavaScript[/b][/color], [color=orange][b]Ajax[/b][/color], [color=orange][b]jQuery[/b][/color], [color=orange][b]Node.js[/b][/color], et une base de données [color=orange][b]MySQL[/b][/color], [color=red]FranceCam[/color] repose sur une architecture moderne et réactive. L’interface, conçue en [color=orange][b]CSS[/b][/color] avec préprocesseur [color=orange][b]Sass[/b][/color], offre une navigation fluide et intuitive.

Le projet allie rigueur technique et passion du cinéma pour proposer un outil à la fois informatif, ergonomique et évolutif."


func _on_return_button_pressed() -> void:
	print("Retour en arrière")
	GameManager.last_clicked_object = "ordi"
	get_tree().change_scene_to_file("res://chez_yann.tscn")

func _on_next_pressed() -> void:
	if images.is_empty():
		return
	current_index += 1
	if current_index > images.size():  # dernière page = Francecam
		current_index = 0
	_update_image()

func _on_prev_pressed() -> void:
	if images.is_empty():
		return
	current_index -= 1
	if current_index < 0:
		current_index = images.size()
	_update_image()

func _update_image() -> void:
	# Cas 1 : page "normale" (image)
	if current_index < images.size():
		ecran.texture = images[current_index]
		ecran.visible = true
		francecam.visible = false
		print("📸 Image affichée :", current_index, "/", images.size())
		_kriss()

	# Cas 2 : dernière page = Francecam
	else:
		ecran.visible = false
		francecam.visible = true
		kriss.visible = (current_index != FRANCECAM_INDEX)
		print("🇫🇷 Page Francecam affichée !")

	# Gérer visibilité des boutons
	btn_prev.visible = (current_index > 0)
	btn_next.visible = (current_index < images.size())
	
func _kriss():
	#if current_index == 8:
		#print(current_index)
		#kriss.visible = true
	#elif current_index != 8:
		#kriss.visible = false
	kriss.visible = (current_index == 10)
	
