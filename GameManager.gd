extends Node  # Le GameManager gère les déplacements du joueur, les bulles de dialogue, et les interactions globales


@onready var speech_bubble_container := get_node("/root/ChezYann/UI/SpeechBubbleContainer")
@onready var context_menu = get_node("/root/ChezYann/ContextMenu")  # Menu contextuel global.
@onready var arrow_green = preload("res://assets/ui/cursors/arrow_1.png")
@onready var arrow_blue = preload("res://assets/ui/cursors/arrow_2.png")
@onready var path_follower: PathFollow2D = get_node_or_null("/root/ChezYann/Path2D/PathFollower")
@onready var player: CharacterBody2D = path_follower.get_node("Employeur")
@onready var anim_sprite: AnimatedSprite2D = null

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

var speed : float = 300.0
var target_offset :float  = 0.0
@export var move_speed_ratio: float = 0.5  # vitesse en unité de ratio par seconde
var fade_timer: Timer = null
var is_moving :bool = false
var current_bubble: SpeechBubble = null
var arrival_animation: String = ""  # Nom de l'animation à jouer une fois arrivé
var object_name = ""


const OBJECT_DATA := {
	"tv": {
		"ratio": 0.1,
		"facing": "back",
		"text": "Une bande démo vidéo.",
		"bubble_offset": Vector2(100, 320),
		"animation": "idle"  # par défaut
		
	},
	"ordi": {
		"ratio": 0.8,
		"facing": "back",
		"text": "Ses compétences informatiques.",
		"bubble_offset": Vector2(100, 350),
		"animation": "idle"  # par défaut
	},
	"carton": {
		"ratio": 0.7,
		"facing": "back",
		"text": "Divers. Apparemment, il s'agit de son expérience professionelle inclassable.",
		"bubble_offset": Vector2(100, 400),
		"animation": "back"  # par défaut
	},
	"cadre": {
		"ratio": 0.6,
		"facing": "left",
		"text": "Ses études et diplômes.",
		"bubble_offset": Vector2(170, 320),
		"animation": "back"  # par défaut
	},
	"centre": {
		"ratio": 0.5,
		"facing": "right",
		"text": "Le centre de la pièce, un point de rencontre.",
		"bubble_offset": Vector2(480, 270)
	},
	"kiki": {
	"ratio": 0.4,
	"facing": "right",
	"text": "Le kiki.",
	"bubble_offset": Vector2(170, 320)
	}
}

const OFFSET_BUBBLE := Vector2(90, 370) 

# Signal personnalisé émis quand le joueur atteint la cible
signal reached_target
#
#version avec position dynamique
func _ready():

	anim_sprite = player.get_node("AnimatedSprite2D")

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

func move_player_to_object(object_name: String):
	last_clicked_object = object_name

	var obj_data = OBJECT_DATA.get(object_name.to_lower(), null)
	if obj_data == null:
		push_error("❌ Objet inconnu : %s" % object_name)
		return false

	var offset_ratio : float = obj_data.get("ratio", 0.0)

	if player and player.is_inside_tree():
		# 🔄 Réinitialise forced_anim avant tout nouveau déplacement
		player.forced_anim = ""
		player.update_animation()

		player.go_to(offset_ratio)
	else:
		push_error("❌ Le player n'est pas prêt ou a été libéré.")
		return false

	print("🚀 Déplacement demandé vers %s → ratio %.2f" % [object_name, offset_ratio])

	await player.reached_target
	print("✅ Joueur arrivé à destination !")

	# 🎬 Animation spéciale si définie dans OBJECT_DATA
	var anim_name = obj_data.get("animation", null)
	#if anim_name:
		#anim_sprite.play(anim_name)
	if anim_name and anim_sprite and is_instance_valid(anim_sprite):
		anim_sprite.play(anim_name)
	else:
		print("⚠️ Impossible de jouer l’anim :", anim_name, "car anim_sprite est invalide.")

	# 🔙 Cas particulier pour les objets "carton" ou "cadre"
	if object_name in ["carton", "cadre"]:
		player.forced_anim = "back"
		player.update_animation()

	var timer = get_tree().create_timer(0.5).timeout
	
	var texte = obj_data.get("text", "")
	if texte != "":
		await timer
		show_speech_bubble_above(player, texte)
		#show_speech_bubble_above(player, texte, object_name)



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
