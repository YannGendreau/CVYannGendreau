extends Control
class_name ContextMenu

# Référence à l'animation de l'œil si elle existe (dans EyeButton)
@onready var eye_anim: AnimatedSprite2D = $EyeButton.get_node_or_null("AnimatedSprite2D")
@onready var player = get_node("/root/ChezYann/Path2D/PathFollower/Employeur")

# Position cible à laquelle le joueur doit se rendre
@export var target_position: Vector2

# Référence vers l'objet interactif ayant ouvert ce menu (utilisé au besoin)
var target_node: Node = null
#var target_node: Node2D  
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

#var object_name = GameManager.last_clicked_object
#var scene_name = ''

#@onready var fade_timer: Timer = $FadeTimer
#@onready var fade_timer = $FadeTimer
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

	$EyeButton.pressed.connect(_on_eye_pressed)
	
#func show_menu_for(object: Node, global_position: Vector2) -> void:
	#target_object = object
	#position = global_position
	#visible = true
#
#
## Setter appelé par le script de l'objet pour indiquer la scène à charger
func set_target_scene(scene_path: String) -> void:
	target_scene = scene_path
	print("✅ target_scene défini :", target_scene)
#
## Quand la souris entre sur le bouton œil → joue l'animation "open"
#func _on_eye_button_mouse_entered() -> void:
	#if eye_anim:
		#eye_anim.play("open")
#
## Quand la souris quitte le bouton œil → retourne à l'animation "idle"
#func _on_eye_button_mouse_exited() -> void:
	#if eye_anim:
		#eye_anim.play("idle")
#
##func _on_eye_button_pressed() -> void:
	##print("👁 Oeil cliqué")
	### Émet le signal "eye" pour informer l'objet qui a ouvert le menu
	##emit_signal("action_chosen", "eye")
	##last_action = "eye"
##
	### Déplace le joueur vers la position de l’objet (légèrement à gauche)
	###if GameManager and GameManager.has_method("move_player_to"):
		###GameManager.move_player_to(target_position - Vector2(30, 0), player_arrival_animation)
##
	##if GameManager and GameManager.has_method("move_player_to_object"):
		##GameManager.on_object_clicked(object_name)  # Met à jour last_clicked_object (utile pour fallback)
		##GameManager.move_player_to_object(object_name, "idle")  # ou une autre anim finale
		##print(object_name)
		##
	###if GameManager and target_object:
		###if GameManager.has_method("on_object_clicked"):
			###GameManager.on_object_clicked(target_object.name)
		###GameManager.move_player_to_object(target_object.name, "idle")
##
##
		### Attend que le joueur ait atteint la position
		##await GameManager.reached_target
		##print('arrivé')
		### Petite pause pour le réalisme
		##await get_tree().create_timer(0.5).timeout
		##
		###GameManager.show_speech_bubble_above(GameManager.player, "Lorem Ipsum is simply dummy .")
		##var name := GameManager.last_clicked_object
		##var text :String= GameManager.LOOK_TEXTS.get(name, "Je ne vois rien de spécial.")
		##GameManager.show_speech_bubble_above(GameManager.player, text)
		###print('Ya une bulle')
	##
		###GameManager.on_eye_clicked(self)
			##
	##emit_signal("action_chosen", "eye")		
	#
## Quand on clique sur le bouton main
#func _on_hand_button_pressed() -> void:
	#print("✋ Main cliquée")
#
	## Déplace le joueur vers la position de l’objet
	#if GameManager and GameManager.has_method("move_player_to"):
		#GameManager.move_player_to(target_position - Vector2(30, 0), player_arrival_animation)
		#
		## Attend que le joueur ait atteint la position
		#await GameManager.reached_target
#
		## Petite pause pour laisser souffler la narration
		#await get_tree().create_timer(0.5).timeout
#
		## Si une scène est définie, on la charge
		#if target_scene != "":
			#GameManager.last_clicked_object = target_name  # <<< ICI
			#get_tree().change_scene_to_file(target_scene)
		#else:
			#print("⚠️ Aucune scène cible définie.")
#
	## Remet l'œil en animation "idle" après interaction
	#if eye_anim:
		#eye_anim.play("idle")
#
	#print("🎯 target_position =", target_position)
	#
##func _on_icon_clicked(object_name: String):
	##GameManager.last_clicked_object = object_name
	##GameManager.move_player_to_object_offset(object_name)
#
#
		#
func show_menu(position: Vector2, scene_path: String, target_pos: Vector2, object_name: String):
	global_position = position
	self.scene_path = scene_path
	self.target_position = target_pos
	self.object_name = object_name  # 👈 stocke localement
	show()
	
	
#func show_menu(target: Node, global_position: Vector2):
	#visible = true
	#target_node = target
	#position = global_position
	#
#func _on_eye_button_pressed():
	#if not target_node:
		#push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		#return
#
	#var object_name = target_node.name
	#if GameManager and GameManager.has_method("move_player_to_object"):
		#GameManager.on_object_clicked(object_name)
		#GameManager.move_player_to_object(object_name, "idle")  # Animation finale
	#visible = false
	
func _on_eye_pressed():
	if target_node:
		var game_manager = get_node("/root/GameManager")  # ou où se trouve ton GameManager
		game_manager.on_eye_clicked(target_node)
	
	
#func show_menu(target: Node, global_position: Vector2):
	#visible = true
	#target_node = target
	#position = global_position

func _on_eye_button_pressed():
	if not target_node:
		push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		return

	var object_name = target_node.name
	if GameManager and GameManager.has_method("move_player_to_object"):
		GameManager.on_object_clicked(object_name)
		#GameManager.move_player_to_object(object_name, "idle")  # Animation finale
		GameManager.move_player_to_object(object_name)
		print(target_node.name)
	
	
	visible = false

func _on_hand_button_pressed():
	#if not target_node:
		#push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		#return
#
	#var object_name = target_node.name
	#if GameManager and GameManager.has_method("move_player_to_object"):
		#GameManager.on_object_clicked(object_name)
		#GameManager.move_player_to_object(object_name)  # Par exemple
	#visible = false
	## Attend que le joueur ait atteint la position
	#await GameManager.reached_target
#
	## Petite pause pour laisser souffler la narration
	##await get_tree().create_timer(0.5).timeout
	#if target_scene != "":
		#GameManager.last_clicked_object = target_name  # <<< ICI
		#get_tree().change_scene_to_file(target_scene)
	#else:
		#print("⚠️ Aucune scène cible définie.")
		
	if not target_node:
		push_error("❌ Aucun objet cible défini pour le menu contextuel.")
		return

	var object_name = target_node.name
	GameManager.last_object_interacted = object_name.to_lower()

	if GameManager and GameManager.has_method("move_player_to_object"):
		GameManager.on_object_clicked(object_name)
		await GameManager.move_player_to_object(object_name)  # Assure-toi que cette fonction est async (voir ci-dessous)
		
		# ⏳ Petite pause réaliste (optionnel)
		await get_tree().create_timer(0.5).timeout

		# 🎯 Changement de scène si défini
		if target_scene != "":
			GameManager.last_clicked_object = object_name
			get_tree().change_scene_to_file(target_scene)
		else:
			print("⚠️ Aucune scène cible définie.")
	visible = false
