
extends Node  # Le GameManager gère les déplacements du joueur, les bulles de dialogue, et les interactions globales


#@onready var speech_bubble_container := get_node_or_null("/root/ChezYann/UI/SpeechBubbleContainer")
#@onready var context_menu = get_node_or_null("/root/ChezYann/ContextMenu")  # Menu contextuel global.
#@onready var arrow_green = preload("res://assets/ui/cursors/arrow_1.png")
#@onready var arrow_blue = preload("res://assets/ui/cursors/arrow_2.png")
#@onready var path_follower: PathFollow2D = get_node_or_null("/root/ChezYann/Path2D/PathFollower")
#@onready var player: CharacterBody2D = path_follower.get_node_or_null("Employeur")
#@onready var anim_sprite: AnimatedSprite2D = null

var speech_bubble_container: Node = null
var context_menu: Node = null
var path_follower: PathFollow2D = null
var player: CharacterBody2D = null
var anim_sprite: AnimatedSprite2D = null

@onready var arrow_green = preload("res://assets/ui/cursors/arrow_1.png")
@onready var arrow_blue = preload("res://assets/ui/cursors/arrow_2.png")

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
var player_path_ratio := 0.25  # Position par défaut
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
var last_action: String = ""   # mémorise l’action en cours ("eye" ou "hand")

var required_objects := ["tv", "ordi", "carton", "cadre"]  # 👈 à adapter
#var visited_objects := {}
var door_opened := false

var visited_objects: Array = []

#var all_objects_visited := false
#var open_door_on_return := false


const ARRIVAL_THRESHOLD := 10.0

const OBJECT_DATA := {
	"tv": {
		"ratio": 0.05,
		"facing": "idle_right",
		"animation": "idle_right",
		"text": "La TV est allumée. Apparemment une sélection de courts-métrages. J'aurais du apporter des popcorns",
		"bubble_offset": Vector2(600, 900),
		"menu_offset": Vector2(0, -40),
	},
	"ordi": {
		"ratio": 0.48,
		"facing": "idle",
		"animation": "idle",
		"text": "Ses compétences techniques.",
		"bubble_offset": Vector2(700, 900),
		"menu_offset": Vector2(-230, -240),
	},
	"carton": {
		"ratio": 0.42,
		"facing": "back",
		"animation": "back",
		"text": "Un carton au sommet de l'armoire. Il doit porter son contenu en haute estime !",
		"bubble_offset": Vector2(600,950),
		"menu_offset": Vector2(0, -40),
	},
	"cadre": {
		"ratio": 0.38,
		"facing": "back",
		"animation": "back",
		"text": "Son diplôme trône fièrement au milieu de la pièce.",
		"bubble_offset": Vector2(600,950),
		"menu_offset": Vector2(20, -140),
	},
	"kiki": {
		"ratio": 0.15,
		"facing": "front",
		"animation": "front",
		"text": "Quel mignon petit chien ! C'est lui qu'il faudrait embaucher !",
		"bubble_offset": Vector2(600, 950),
		"menu_offset": Vector2(0, -40),
		
	},
	"porte": {
		"ratio": 1,
		"facing": "idle",
		"animation": "idle",
		"text": "La porte.",
		"bubble_offset": Vector2(600, 950),
		"menu_offset": Vector2(-230, -240),
		
	},
	
}

const OFFSET_BUBBLE := Vector2(90, 370) 

# Signal personnalisé émis quand le joueur atteint la cible
signal reached_target
#
#version avec position dynamique
func _ready():
		# 🔹 Ne rien initialiser si la scène de titre est en cours
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path.ends_with("title.tscn"):
		print("🎬 GameManager ignoré sur la scène de titre.")
		return
		
	refresh_references()

	# --- initialisation normale ---

	
	
	anim_sprite = player.get_node("AnimatedSprite2D")
	fade_timer = Timer.new()
	fade_timer.name = "FadeTimer"
	fade_timer.wait_time = 1.5
	fade_timer.one_shot = true
	add_child(fade_timer)
	fade_timer.timeout.connect(_on_fade_timeout)
	
	if not has_node("FadeTimer"):
		fade_timer = Timer.new()
		fade_timer.name = "FadeTimer"
		add_child(fade_timer)
	else:
		fade_timer = get_node("FadeTimer")
	
	Input.set_custom_mouse_cursor(arrow_green, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(arrow_blue, Input.CURSOR_ARROW)
	
	call_deferred("place_player_at_last_offset")
	
	if not player:
		pass
	
	if player:
		player.reached_target.connect(_on_character_reached_object)

	if not path_follower or not player:
		push_error("❌ GameManager : Références manquantes. Vérifie la structure de chez_yann.tscn.")
		print("path_follower: ", path_follower, ", player: ", player)
	else:
		print("✅ Références GameManager initialisées")

	if path_follower and path_follower.progress > 0:
		path_follower.moving = false
		
	get_tree().tree_changed.connect(_on_tree_changed)
	#anim_sprite = player.get_node("AnimatedSprite2D")
#
	##Nouveau timer
	#fade_timer = Timer.new()
	##Nommer le timer
	#fade_timer.name = "FadeTimer"
	##Durée
	#fade_timer.wait_time = 1.5
	##S'arrête à la fin 
	#fade_timer.one_shot = true
	##Ajout d'un enfant
	#add_child(fade_timer)
	##Connecte le timer à une méthode qui est exécutée une fois le temps écoulé
	#fade_timer.timeout.connect(_on_fade_timeout)
	#
	## Curseur vert
	#Input.set_custom_mouse_cursor(arrow_green, Input.CURSOR_POINTING_HAND)
	## Curseur bleu
	#Input.set_custom_mouse_cursor(arrow_blue, Input.CURSOR_ARROW)
	#
	#call_deferred("place_player_at_last_offset")
	#
	#if not player:
		#pass
	#
	#if player:
		#player.reached_target.connect(_on_character_reached_object)
#
	## Recherche des nœuds dans la scène principale (ajuste le chemin selon chez_yann.tscn)
	#if not path_follower or not player:
		#push_error("❌ GameManager : Références manquantes. Vérifie la structure de chez_yann.tscn.")
		#print("path_follower: ", path_follower, ", player: ", player)
	#else:
		#print("✅ Références GameManager initialisées")
## Éviter de réinitialiser la position au démarrage
	#if path_follower.progress > 0:  # Garder la dernière position si existante
		#path_follower.moving = false  # Assurer que le déplacement s’arrête
		#
	#get_tree().tree_changed.connect(_on_tree_changed)
	

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

func move_player_to_object(object_name: String, action: String = "") -> bool:
	last_clicked_object = object_name
	last_action = action  

	var obj_data = OBJECT_DATA.get(object_name.to_lower(), null)
	if obj_data == null:
		push_error("❌ Objet inconnu : %s" % object_name)
		return false

	var offset_ratio: float = obj_data.get("ratio", 0.0)

	if player and player.is_inside_tree():
		var current_ratio: float = player.get_progress_ratio()
		var target_ratio: float = offset_ratio

		if abs(current_ratio - target_ratio) < 0.01:
			print("Déjà devant l’objet → pas besoin de bouger")
		else:
			player.go_to(target_ratio)
			await player.reached_target
			print("✅ Joueur arrivé à destination !")
	else:
		push_error("❌ Le player n'est pas prêt ou a été libéré.")
		return false

	print("🚀 Déplacement demandé vers %s → ratio %.2f" % [object_name, offset_ratio])

	# Petite pause avant bulle éventuelle
	var timer = get_tree().create_timer(0.5).timeout
	var texte = obj_data.get("text", "")
	_on_character_reached_object(object_name)
	# 👁 bulle uniquement pour l’œil
	if last_action == "eye" and texte != "":
		await timer
		reset_bubbles()
		show_speech_bubble_above(player, texte)
		print("💬 bulle affichée")
	else:
		print("👁 pas de bulle")

	# 🐶 Action spéciale pour Kiki
	if object_name == "kiki" and action == "hand":
		var kiki = get_node("/root/ChezYann/kiki")
		if kiki:
			kiki.react_to_action(action)

		await player.animated_sprite.animation_finished
		player.animated_sprite.play("idle")

		await get_tree().create_timer(2.0).timeout
		player.animated_sprite.play("down")

		await player.animated_sprite.animation_finished
		player.animated_sprite.play("ears")

	# 🎬 Joue l’animation de facing une seule fois
	

	return true


	
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
func on_object_clicked(object_name: String, action: String = ""):
	last_clicked_object = object_name
	print("Dernier objet cliqué: ", last_clicked_object)  # Ajouter un print pour confirmer
	
	#visited_objects[object_name] = true  # ✅ Marqué comme visité
	#print("✔️ Objet visité :", object_name)
	#
		# Seule la main valide un objet comme "vu"
	if action == "hand":
		if not visited_objects.has(object_name):
			#visited_objects[object_name] = true  # ✅ Marqué comme visité
			visited_objects.append(object_name)
			print("✔️ Objet visité :", object_name)
	
	else:
		print("👁 Juste observé :", object_name)
		
	#if not visited_objects.has(object_name):
		#visited_objects.append(object_name)
		#print("✅ Objet visité :", object_name)

func all_objects_visited() -> bool:
	for obj in required_objects:
		if not visited_objects.has(obj):
			return false
	return true
	

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
	print(screen_pos)

	# Clamp pour rester dans l’écran
	#var screen_size = get_viewport().size
	#screen_pos.x = clamp(screen_pos.x, 0, screen_size.x - bubble.size.x)
	#screen_pos.y = clamp(screen_pos.y, 0, screen_size.y - bubble.size.y)

	bubble.position = screen_pos
	bubble.set_text(text)

	# Disparition après 3s
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(bubble):
		bubble.queue_free()
		current_bubble = null

func reset_bubbles() -> void:
	if current_bubble and is_instance_valid(current_bubble):
		current_bubble.queue_free()
	current_bubble = null

func _on_character_reached_object(object_name: String) -> void:
	if object_name in OBJECT_DATA:
		var data = OBJECT_DATA[object_name]
		if data.has("facing"):
			var anim_name = data["facing"]

			if player and player.animated_sprite and player.animated_sprite.sprite_frames.has_animation(anim_name):
				player.animated_sprite.play(anim_name)
				print("▶️ Animation jouée :", anim_name)
			else:
				print("⚠️ Animation", anim_name, "non trouvée dans le sprite du joueur.")
				
func go_to_object(object_name: String):
	if not OBJECT_DATA.has(object_name):
		push_error("❌ Objet inconnu : %s" % object_name)
		return

	var offset_ratio: float = OBJECT_DATA[object_name].get("ratio", 0.0)

	if player:
		player.go_to(offset_ratio)
		print("🚪 Déplacement vers", object_name, "→ ratio:", offset_ratio)
	else:
		push_error("❌ Player non trouvé !")
		
func refresh_references():
	speech_bubble_container = get_node_or_null("/root/ChezYann/UI/SpeechBubbleContainer")
	context_menu = get_node_or_null("/root/ChezYann/ContextMenu")
	path_follower = get_node_or_null("/root/ChezYann/Path2D/PathFollower")
	#player = path_follower and path_follower.get_node_or_null("Employeur") or null
	player = get_node_or_null("/root/ChezYann/Path2D/PathFollower/Employeur")
	
	if player:
		print("✅ GameManager : Références mises à jour.")
	else:
		print("⚠️ GameManager : pas encore de ChezYann actif.")

func _on_tree_changed():
	await get_tree().process_frame
	refresh_references()
