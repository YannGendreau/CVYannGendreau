extends Node  # Le GameManager gère les déplacements du joueur, les bulles de dialogue, et les interactions globales

# Accès direct au PathFollow2D sur lequel le joueur se déplace
#@onready var path_follower: PathFollow2D = get_node("/root/ChezYann/Path2D/PathFollower")
@onready var speech_bubble_container := get_node("/root/ChezYann/UI/SpeechBubbleContainer")
@onready var context_menu = get_node("/root/ChezYann/ContextMenu")  # Menu contextuel global.
@onready var arrow_green = preload("res://assets/ui/cursors/arrow_1.png")
@onready var arrow_blue = preload("res://assets/ui/cursors/arrow_2.png")
#@onready var path: Path2D = get_node_or_null("/root/ChezYann/Path2D")
@onready var path_follower: PathFollow2D = get_node_or_null("/root/ChezYann/Path2D/PathFollower")
#@onready var path_follower: PathFollow2D = get_parent()
@onready var player: Node2D = path_follower.get_node_or_null("AnimatedSprite2D") if path_follower else null

var speech_bubble_scene: PackedScene = preload("res://speechbubble.tscn")


# Distance à partir de laquelle on considère que le joueur est arrivé à destination
@export var distance_object: int = 100
#230525 Dernière position du perso
var last_player_position: Vector2 = Vector2.ZERO
# Position où le joueur doit aller
var destination: Vector2 = Vector2.ZERO
# Cible finale atteinte
var target_position: Vector2 = Vector2.ZERO
var last_clicked_object: String = ""
var last_object_interacted: String = ""
var player_path_ratio := 0.5  # Position par défaut
# Références à d'autres objets utiles
var path: Path2D
#var player: CharacterBody2D
#@onready var player = get_node("/root/ChezYann/Path2D/PathFollower/Employeur")
var speed : float = 300.0
var target_offset :float  = 0.0
@export var move_speed_ratio: float = 0.5  # vitesse en unité de ratio par seconde
var fade_timer: Timer = null
var is_moving :bool = false
var current_bubble: SpeechBubble = null
var arrival_animation: String = ""  # Nom de l'animation à jouer une fois arrivé
var object_name = ""
# mapping : objets -> offset sur le Path2D
#const OBJECT_OFFSETS := {
	#"tv": 0.1,
	#"ordi": 0.8,
	#"carton": 0.6,
	#"cadre": 0.3,
	#"centre": 0.5
#}

var LOOK_TEXTS = {
	"tv": "Je regarde la TV...",
	"carton": "Je regarde le carton...",
	"ordi": "Je regarde l'ordinateur...",
	"cadre": "Je regarde le cadre..."
}

const OBJECT_DATA := {
	"tv": {
		"ratio": 0.1,
		"facing": "back",
		"text": "Une bande démo vidéo.",
		"bubble_offset": Vector2(250, 120)
	},
	"ordi": {
		"ratio": 0.8,
		"facing": "back",
		"text": "Ses compétences informatiques.",
		"bubble_offset": Vector2(100, 350)
	},
	"carton": {
		"ratio": 0.6,
		"facing": "back",
		"text": "Divers. Apparemment, il s'agit de son expérience professionelle inclassable.",
		"bubble_offset": Vector2(100, 400)
	},
	"cadre": {
		"ratio": 0.3,
		"facing": "left",
		"text": "Ses études et diplômes.",
		"bubble_offset": Vector2(100, 270)
	},
	"centre": {
		"ratio": 0.5,
		"facing": "right",
		"text": "Le centre de la pièce, un point de rencontre.",
		"bubble_offset": Vector2(480, 270)
	}
}

const OFFSET_BUBBLE := Vector2(90, 370) 

# Signal personnalisé émis quand le joueur atteint la cible
signal reached_target
#
#version avec position dynamique
func _ready():
	#Nouveau timer
	fade_timer = Timer.new()
	#Nommer le timer
	fade_timer.name = "FadeTimer"
	#Durée
	fade_timer.wait_time = 1.5
	#S'arrête à la fin 
	fade_timer.one_shot = true
	#Ajout d'un enfant
	add_child(fade_timer)
	#Connecte le timer à une méthode qui est exécutée une fois le temps écoulé
	fade_timer.timeout.connect(_on_fade_timeout)
	
	# Curseur vert
	Input.set_custom_mouse_cursor(arrow_green, Input.CURSOR_POINTING_HAND)
	# Curseur bleu
	Input.set_custom_mouse_cursor(arrow_blue, Input.CURSOR_ARROW)
	
	call_deferred("place_player_at_last_offset")
	
	
	# Recherche des nœuds dans la scène principale (ajuste le chemin selon chez_yann.tscn)
	if not path_follower or not player:
		push_error("❌ GameManager : Références manquantes. Vérifie la structure de chez_yann.tscn.")
		print("path_follower: ", path_follower, ", player: ", player)
	else:
		print("✅ Références GameManager initialisées")
# Éviter de réinitialiser la position au démarrage
	if path_follower.progress > 0:  # Garder la dernière position si existante
		path_follower.moving = false  # Assurer que le déplacement s’arrête

#Appel des noeuds du Player, chemin et Chemin à suivre 
func init_refs(root_node: Node):
	player = root_node.get_node_or_null("/root/ChezYann/Path2D/PathFollower/Employeur")
	path = root_node.get_node_or_null("/root/ChezYann/Path2D")
	path_follower = path.get_node_or_null("/root/ChezYann/Path2D/PathFollower") if path else null
	if player and path and path_follower:
		print("✅ Références GameManager remises à zéro")
	else:
		push_error("❌ GameManager : une ou plusieurs références sont nulles. Vérifie les noms et la hiérarchie.")

func delete_follower():
	# Supprime le follower (utile si on veut détruire la trajectoire)
	print("✂ Suppression path_follower")
	path_follower.queue_free()
	
func _process(delta):
	if is_moving:
		var cur = path_follower.unit_offset
		var dir = sign(target_offset - cur)
		cur += dir * move_speed_ratio * delta
		path_follower.unit_offset = clamp(cur, 0.0, 1.0)
		# mise à jour du joueur : il groupera automatiquement
		player.global_position = path_follower.global_position

		if abs(cur - target_offset) < 0.005:
			is_moving = false
			path_follower.unit_offset = target_offset
			player.global_position = path_follower.global_position
			emit_signal("reached_target")

#func move_player_to_object(object_name: String):

	#last_clicked_object = object_name
	#var offset_ratio : float = OBJECT_OFFSETS.get(object_name.to_lower(), 0.0)
#
	#if player and player.is_inside_tree():
		#player.go_to(offset_ratio)
	#else:
		#push_error("❌ Le player n'est pas prêt ou a été libéré.")
#
	#print("🚀 Déplacement demandé vers %s → ratio %.2f" % [object_name, offset_ratio])
#
	#print("👣 Déplacement vers ", object_name, " → position ", target_position)
	#
	#var timer = get_tree().create_timer(0.8).timeout
	#await timer
	#print(timer)
	#
	#emit_signal("reached_target")
	#return reached_target  # Permet `await GameManager.move_player_to_object(...)`

func move_player_to_object(object_name: String):
	last_clicked_object = object_name

	# 🔎 On récupère les infos depuis OBJECT_DATA
	var obj_data = OBJECT_DATA.get(object_name.to_lower(), null)
	if obj_data == null:
		push_error("❌ Objet inconnu : %s" % object_name)
		return false

	var offset_ratio : float = obj_data.get("ratio", 0.0)

	# 🏃 Déplacement du joueur
	if player and player.is_inside_tree():
		player.go_to(offset_ratio)
	else:
		push_error("❌ Le player n'est pas prêt ou a été libéré.")
		return false

	# 📢 Debug infos
	print("🚀 Déplacement demandé vers %s → ratio %.2f" % [object_name, offset_ratio])
	print("👣 Déplacement vers ", object_name)

	await player.reached_target  # ✅ attend vraiment que le joueur arrive
	print("✅ Joueur arrivé à destination !")
	
		# Vérifie si le joueur est déjà sur le même ratio
	#if player and abs(player.path_follower.progress_ratio - offset_ratio) < 0.005:
		#print("⏸️ Pas de déplacement : le joueur est déjà à %.2f" % offset_ratio)
		#emit_signal("reached_target")
		#return

	
	# Si le joueur est déjà arrivé (tolérance de quelques pixels)


	#emit_signal("reached_target")
	## ⏳ Petit délai avant signal
	#var timer = get_tree().create_timer(0.8).timeout
	#await timer
	#print(timer)
	
	
	#await timer
	#print(timer)

	emit_signal("reached_target")
	
	var timer = get_tree().create_timer(0.5).timeout
	
	var texte = obj_data.get("text", "")
	if texte != "":
		await timer
		show_speech_bubble_above(player, texte)
		#show_speech_bubble_above(player, texte, object_name)


#func on_eye_clicked(target: Node2D) -> void:
	#var target_name := target.name.to_lower()
	##if LOOK_TEXTS.has(target_name):
	#if OBJECT_DATA.has(target_name) :
		##var text : String = LOOK_TEXTS[target_name]
		#var text : String = OBJECT_DATA[target_name]["text"]
		#show_speech_bubble_above(target, text)
	#else:
		#show_speech_bubble_above(target, "Je ne vois rien de spécial.")

func is_player_moving() -> bool:
	# Accès simple à l'état de déplacement
	return is_moving

func _on_fade_timeout():
	# Appelé quand le timer expire : on cache tous les menus contextuels visibles
	print("⏳ FadeTimer a expiré dans GameManager.")
	hide_all_context_menus()

func hide_all_context_menus():
	# Cache tous les objets appartenant au groupe "context_objects"
	for object in get_tree().get_nodes_in_group("context_objects"):
		if object.has_method("hide_with_tween"):
			object.hide_with_tween()

func place_player_at_last_offset():
	
	if path_follower and path_follower.progress_ratio:
		print("✅ chemin trouvé :", path_follower.progress_ratio)
	else:
		print("❌ Pas de chemin associé à path_follower !")
	
	#print("📏 Longueur du chemin :", path.curve.get_baked_length())

		
	#if not player or not path_follower:
		#push_error("GameManager: Références manquantes pour placer le joueur.")
		#return
#
	#if last_clicked_object == "":
		#push_error("❌ last_clicked_object est vide ! Impossible de placer le joueur.")
		#return
#
	#if OBJECT_OFFSETS.has(last_clicked_object):
		#var ratio = OBJECT_OFFSETS[last_clicked_object]
		#var curve_length = path_follower.get_parent().curve.get_baked_length()
		#var target_progress = ratio * curve_length
		#print("Calculé target_progress: ", target_progress, " pour ratio ", ratio, " et longueur ", curve_length)
		#path_follower.target_position = target_progress
		#path_follower.moving = true
		#print("✅ Employeur en route vers l'offset de ", last_clicked_object, " à ", target_progress)
	#else:
		#push_warning("⚠️ Aucun offset trouvé pour " + last_clicked_object)
		
	if last_clicked_object == "":
		print("⏩ Aucun objet encore cliqué, le joueur ne sera pas déplacé au démarrage.")
		return
		
	if player == null:
		player = get_tree().get_first_node_in_group("Employeur")
		
	if player == null or player.path_follower == null:
		print("❌ Pas de chemin associé à path_follower ! (player ou path_follower null)")
		return
		
	#var ratio = OBJECT_OFFSETS[last_clicked_object]
	var ratio = OBJECT_DATA[last_clicked_object]["ratio"]
	player.path_follower.progress_ratio = ratio
	print("✅ Joueur replacé sur le chemin à ratio:", ratio)

#Utilisé avec la fonction on_hand_button_pressed du context_menu	
func on_object_clicked(object_name: String):
	last_clicked_object = object_name
	print("Dernier objet cliqué: ", last_clicked_object)  # Ajouter un print pour confirmer

#func show_speech_bubble_above(character: Node2D, text: String) -> void:
	#if not speech_bubble_scene or not speech_bubble_container:
		#print("❌ Pas de scène ou de conteneur défini")
		#return
	## Instancier la bulle et l'ajouter au conteneur
	#var bubble := speech_bubble_scene.instantiate()
	#speech_bubble_container.add_child(bubble)
	#print("✅ Bulle ajoutée :", bubble)
#
	## Position du personnage dans le monde
	#var world_pos := character.global_position - OFFSET_BUBBLE
	#print("🌍 Position monde :", world_pos)
#
	## Convertir en position écran dans le viewport sans Camera2D
	#var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos
	#print("📍 Position écran bulle :", screen_pos)
	#
	#bubble.position = screen_pos
	#bubble.set_text(text)
#
	#await get_tree().create_timer(3.0).timeout
	#if is_instance_valid(bubble):
		#bubble.queue_free()
			#
##func get_player_position() -> Vector2:
	### Renvoie la position globale du joueur
	##if player:
		##return player.global_position
	##return Vector2.ZERO
#
##func _on_player_reached_target():
	### Alternative au signal reached_target
	##if arrival_animation != "":
		##player.play_animation(arrival_animation)
	##else:
		##player.play_animation("idle")  # fallback
	##emit_signal("reached_target")
	#
##func on_scene_name(scene_name: String):
	##last_clicked_object = scene_name

func show_speech_bubble_above(character: Node2D, text: String) -> void:
	if not speech_bubble_scene or not speech_bubble_container:
		print("❌ Pas de scène ou de conteneur défini")
		return

	# Détruire l’ancienne bulle avant d’en créer une nouvelle
	if current_bubble and is_instance_valid(current_bubble):
		current_bubble.queue_free()
		current_bubble = null

	# Nouvelle bulle
	var bubble := speech_bubble_scene.instantiate()
	speech_bubble_container.add_child(bubble)
	current_bubble = bubble

	## Position du joueur
	#var bubble_offset = OBJECT_DATA[last_clicked_object]["bubble_offset"]
	##var world_pos := character.global_position - OFFSET_BUBBLE
	#var world_pos : Vector2 = character.global_position - bubble_offset
#
	#var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos
	
	var bubble_offset = OBJECT_DATA[last_clicked_object]["bubble_offset"]
	var world_pos: Vector2 = character.global_position - bubble_offset
	var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos

	# Clamp pour rester dans l’écran
	var screen_size = get_viewport().size
	screen_pos.x = clamp(screen_pos.x, 0, screen_size.x - bubble.size.x)
	screen_pos.y = clamp(screen_pos.y, 0, screen_size.y - bubble.size.y)

	bubble.position = screen_pos
	bubble.set_text(text)

	# Disparition après 3s
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(bubble):
		bubble.queue_free()
		current_bubble = null

#func show_speech_bubble_above(character: Node2D, text: String) -> void:
	#
	#if not speech_bubble_scene or not speech_bubble_container:
		#print("❌ Pas de scène ou de conteneur défini")
		#return
#
	## Détruire l’ancienne bulle avant d’en créer une nouvelle
	#if current_bubble and is_instance_valid(current_bubble):
		#current_bubble.queue_free()
		#current_bubble = null
#
	## Vérifier que le texte n’est pas vide
	#if text == "":
		#print("⚠️ Texte vide → pas de bulle créée")
		#return
#
	## Nouvelle bulle
	#var bubble := speech_bubble_scene.instantiate()
	##var bubble = $UI/SpeechBubbleContainer
	#speech_bubble_container.add_child(bubble)
	#current_bubble = bubble
#
	#print("💬 Nouvelle bulle créée avec texte:", text)
#
	## Position
	#var world_pos := character.global_position - OFFSET_BUBBLE
	#var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos
#
	#bubble.position = screen_pos
	#bubble.set_text(text)
#
	## Timer pour suppression
	#await get_tree().create_timer(6.0).timeout
	#if is_instance_valid(bubble):
		#bubble.queue_free()
		#current_bubble = null
		#
##func show_speech_bubble_above(character: Node2D, text: String, object_name: String = "") -> void:
	##if not speech_bubble_scene or not speech_bubble_container:
		##print("❌ Pas de scène ou de conteneur défini")
		##return
##
	### Supprimer l’ancienne bulle
	##if current_bubble and is_instance_valid(current_bubble):
		##current_bubble.queue_free()
		##current_bubble = null
##
	##if text == "":
		##print("⚠️ Texte vide → pas de bulle créée")
		##return
##
	### Nouvelle bulle
	##var bubble := speech_bubble_scene.instantiate()
	##speech_bubble_container.add_child(bubble)
	##current_bubble = bubble
##
	##print("💬 Nouvelle bulle créée avec texte:", text)
##
	### 🔹 Choix de l’offset (si défini dans OBJECT_DATA)
	##var offset := OFFSET_BUBBLE
	##if object_name != "" and OBJECT_DATA.has(object_name) and OBJECT_DATA[object_name].has("bubble_offset"):
		##offset = OBJECT_DATA[object_name]["bubble_offset"]
		##print(offset)
##
	### Position finale
	##var world_pos := character.global_position + offset
	##var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos
##
	##bubble.position = screen_pos
	##bubble.set_text(text)
##
	### Timer pour suppression
	##await get_tree().create_timer(6.0).timeout
	##if is_instance_valid(bubble):
		##bubble.queue_free()
		##current_bubble = null
#
##func show_speech_bubble_above(character: Node2D, text: String, object_name: String = "") -> void:
	##if not speech_bubble_scene or not speech_bubble_container:
		##print("❌ Pas de scène ou de conteneur défini")
		##return
##
	### Supprimer l’ancienne bulle
	##if current_bubble and is_instance_valid(current_bubble):
		##current_bubble.queue_free()
		##current_bubble = null
##
	##if text == "":
		##print("⚠️ Texte vide → pas de bulle créée")
		##return
##
	### Nouvelle bulle
	##var bubble := speech_bubble_scene.instantiate()
	##speech_bubble_container.add_child(bubble)
	##current_bubble = bubble
##
	##print("💬 Nouvelle bulle créée avec texte:", text)
##
	### 🔹 Choix de l’offset (si défini dans OBJECT_DATA)
	##var offset := OFFSET_BUBBLE
	##if object_name != "" and OBJECT_DATA.has(object_name) and OBJECT_DATA[object_name].has("bubble_offset"):
		##offset = OBJECT_DATA[object_name]["bubble_offset"]
##
	### Position finale
	##var world_pos := character.global_position + offset
	###var screen_pos := get_viewport().get_canvas_transform().affine_inverse() * world_pos
	##
	##var screen_pos := character.global_position + offset
	##var screen_size = get_viewport().size  # (960, 540 dans ton cas)
	##
	### Empêche la bulle de sortir de l’écran
	##screen_pos.x = clamp(screen_pos.x, 0, screen_size.x - bubble.size.x)
	##screen_pos.y = clamp(screen_pos.y, 0, screen_size.y - bubble.size.y)
	##
	##print("🟢 Character:", character.global_position, " Offset:", offset, " → Position finale bulle:", screen_pos)
##
	##bubble.position = screen_pos
##
	###bubble.position = screen_pos
	##bubble.set_text(text)
##
	### Timer pour suppression
	##await get_tree().create_timer(6.0).timeout
	##if is_instance_valid(bubble):
		##bubble.queue_free()
		##current_bubble = null
