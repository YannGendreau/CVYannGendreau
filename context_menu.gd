extends Control
class_name ContextMenu

# Référence à l'animation de l'œil si elle existe (dans EyeButton)
@onready var eye_anim: AnimatedSprite2D = $EyeButton.get_node_or_null("AnimatedSprite2D")
@onready var hand_anim: AnimatedSprite2D = $HandButton.get_node_or_null("AnimatedSprite2D")
@onready var player = get_node("/root/ChezYann/Path2D/PathFollower/Employeur")

# Position cible à laquelle le joueur doit se rendre
@export var target_position: Vector2

# Référence vers l'objet interactif ayant ouvert ce menu (utilisé au besoin)
var target_node: Node = null
# Nom de l'animation à jouer quand le joueur arrive à destination (optionnel)
@export var player_arrival_animation: String = ""

# Chemin de la scène à charger si action = "main"
var target_scene: String = ""

@export var target_name := ""  #"tv", "ordi", "carton" dans l’inspecteur

var target_object: Node = null


# Dernière action choisie : "eye" ou "hand"
var last_action: String = ""

var object_name: String = ""

# Signal émis lorsqu’une action est choisie (connecté dans le script de l’objet)
signal action_chosen(action: String)

@onready var fade_timer = get_tree().get_root().get_node("ChezYann/FadeTimer")

func _ready() -> void:
	#Invisible au lancement
	visible = false
	#Transparence
	modulate.a = 0.0
	#Taille résuite à zéro
	scale = Vector2(0, 0)
	# Si l'animation de l'œil est présente, on la lance sur "idle"
	if eye_anim:
		eye_anim.play("idle")
	else:
		print("⚠️ AnimatedSprite2D non trouvé dans EyeButton")
	
	# Se connecte au signal 'reached_target' du GameManager (une seule fois)
	if GameManager and not GameManager.is_connected("reached_target", Callable(self, "_on_player_arrived")):
		GameManager.connect("reached_target", Callable(self, "_on_player_arrived"))

	# Si tu veux que tous les enfants (boutons/icônes) héritent
	for child in get_children():
		if child is Control:
			child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
			# Le panneau entier change le curseur en main
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# S'assurer que le menu capte bien la souris
	mouse_filter = Control.MOUSE_FILTER_STOP
			
	#$EyeButton.pressed.connect(_on_eye_pressed)

## Setter appelé par le script de l'objet pour indiquer la scène à charger
func set_target_scene(scene_path: String) -> void:
	target_scene = scene_path
	print("✅ target_scene défini :", target_scene)
#
# Quand la souris entre sur le bouton œil → joue l'animation "open"
func _on_eye_button_mouse_entered() -> void:
	if eye_anim:
		eye_anim.play("open")
#
# Quand la souris quitte le bouton œil → retourne à l'animation "idle"
func _on_eye_button_mouse_exited() -> void:
	if eye_anim:
		eye_anim.play("idle")
		
# Quand la souris entre sur le bouton main → joue l'animation "open"
func _on_hand_button_mouse_entered() -> void:
	if hand_anim:
		hand_anim.play("close")
#
# Quand la souris quitte le bouton main → retourne à l'animation "idle"
func _on_hand_button_mouse_exited() -> void:
	if hand_anim:
		hand_anim.play("open")

func _on_eye_button_pressed():
	if not target_node:
		push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		return

	var object_name = target_node.name
	if GameManager and GameManager.has_method("move_player_to_object"):
		GameManager.on_object_clicked(object_name)
		GameManager.move_player_to_object(object_name)
		print(target_node.name)
		
	visible = false

func _on_hand_button_pressed():
	if not target_node:
		push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		return

	var object_name = target_node.name
	GameManager.last_object_interacted = object_name.to_lower()
	GameManager.last_clicked_object = object_name.to_lower()

	if GameManager and GameManager.has_method("move_player_to_object"):
		GameManager.on_object_clicked(object_name)
		#GameManager.on_hand_action(GameManager.last_clicked_object)
		# ✅ Ici on précise bien "hand"
		await GameManager.move_player_to_object(object_name, "hand")

		# ⏳ Petite pause réaliste (optionnel)
		await get_tree().create_timer(0.5).timeout

		# 🎯 Changement de scène si défini
		if target_scene != "":
			GameManager.last_clicked_object = object_name
			get_tree().change_scene_to_file(target_scene)
		else:
			print("⚠️ Aucune scène cible définie.")

	# 🔒 Cache le menu après l’action
	visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Vérifie si le clic est en dehors du menu
		var mouse_pos = get_viewport().get_mouse_position()
		if not get_global_rect().has_point(mouse_pos):
			visible = false
	


#################################################################
#extends Control
#class_name ContextMenu
#
## Référence à l'animation de l'œil si elle existe (dans EyeButton)
#@onready var eye_anim: AnimatedSprite2D = $EyeButton.get_node_or_null("AnimatedSprite2D")
#@onready var player = get_node("/root/ChezYann/Path2D/PathFollower/Employeur")
#
## Position cible à laquelle le joueur doit se rendre
#@export var target_position: Vector2
#
## Référence vers l'objet interactif ayant ouvert ce menu (utilisé au besoin)
#var target_node: Node = null
## Nom de l'animation à jouer quand le joueur arrive à destination (optionnel)
#@export var player_arrival_animation: String = ""
#
## Chemin de la scène à charger si action = "main"
#var target_scene: String = ""
#
#@export var target_name := ""  #"tv", "ordi", "carton" dans l’inspecteur
#
#var target_object: Node = null
#
#
## Dernière action choisie : "eye" ou "hand"
#var last_action: String = ""
#
#var object_name: String = ""
#
## Signal émis lorsqu’une action est choisie (connecté dans le script de l’objet)
#signal action_chosen(action: String)
#
#@onready var fade_timer = get_tree().get_root().get_node("ChezYann/FadeTimer")
#
#func _ready() -> void:
	##Invisible au lancement
	#visible = false
	##Transparence
	#modulate.a = 0.0
	##Taille résuite à zéro
	#scale = Vector2(0, 0)
	## Si l'animation de l'œil est présente, on la lance sur "idle"
	#if eye_anim:
		#eye_anim.play("idle")
	#else:
		#print("⚠️ AnimatedSprite2D non trouvé dans EyeButton")
	#
	## Se connecte au signal 'reached_target' du GameManager (une seule fois)
	#if GameManager and not GameManager.is_connected("reached_target", Callable(self, "_on_player_arrived")):
		#GameManager.connect("reached_target", Callable(self, "_on_player_arrived"))
#
	## Si tu veux que tous les enfants (boutons/icônes) héritent
	#for child in get_children():
		#if child is Control:
			#child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	#
			## Le panneau entier change le curseur en main
	#mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
#
	## S'assurer que le menu capte bien la souris
	#mouse_filter = Control.MOUSE_FILTER_STOP
			#
	##$EyeButton.pressed.connect(_on_eye_pressed)
#
### Setter appelé par le script de l'objet pour indiquer la scène à charger
#func set_target_scene(scene_path: String) -> void:
	#target_scene = scene_path
	#print("✅ target_scene défini :", target_scene)
##
## Quand la souris entre sur le bouton œil → joue l'animation "open"
#func _on_eye_button_mouse_entered() -> void:
	#if eye_anim:
		#eye_anim.play("open")
##
## Quand la souris quitte le bouton œil → retourne à l'animation "idle"
#func _on_eye_button_mouse_exited() -> void:
	#if eye_anim:
		#eye_anim.play("idle")
#
#func _on_eye_button_pressed():
	#if not target_node:
		#push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		#return
#
	#var object_name = target_node.name
	#if GameManager and GameManager.has_method("move_player_to_object"):
		#GameManager.on_object_clicked(object_name)
		#GameManager.move_player_to_object(object_name)
		#print(target_node.name)
		#
	#visible = false
	#
#func _on_hand_button_mouse_entered() -> void:
	#if eye_anim:
		#eye_anim.play("open")
	#
#func _on_hand_button_mouse_exited() -> void:
	#if eye_anim:
		#eye_anim.play("close")
#
#func _on_hand_button_pressed():
	#if not target_node:
		#push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		#return
#
	#var object_name = target_node.name
	#GameManager.last_object_interacted = object_name.to_lower()
	#GameManager.last_clicked_object = object_name.to_lower()
#
	#if GameManager and GameManager.has_method("move_player_to_object"):
		#GameManager.on_object_clicked(object_name)
		##GameManager.on_hand_action(GameManager.last_clicked_object)
		## ✅ Ici on précise bien "hand"
		#await GameManager.move_player_to_object(object_name, "hand")
#
		## ⏳ Petite pause réaliste (optionnel)
		#await get_tree().create_timer(0.5).timeout
#
		## 🎯 Changement de scène si défini
		#if target_scene != "":
			#GameManager.last_clicked_object = object_name
			#get_tree().change_scene_to_file(target_scene)
		#else:
			#print("⚠️ Aucune scène cible définie.")
#
	## 🔒 Cache le menu après l’action
	#visible = false
