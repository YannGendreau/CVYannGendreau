extends CharacterBody2D  # Le noeud représente un objet interactif pouvant être placé dans le monde 2D.

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # Référence au sprite animé de l'objet.
@onready var context_menu = get_node("/root/ChezYann/ContextMenu")  # Menu contextuel global.
@export var target_scene: String  # Scène cible à charger si interaction avec la main.```

var hover_count: int = 0  # Nombre de zones actuellement survolées (pour éviter de cacher le menu trop tôt).

# Constantes pour gérer l'apparence du menu
const MENU_OFFSET := Vector2(-20, -30)  # Position du menu par rapport à l'objet.
const MENU_HIDE_OFFSET := Vector2(0, 50)  # Décalage quand le menu se replie.
const MENU_SCALE_ZERO := Vector2(0.0, 0.0)  # Échelle invisible.
const MENU_SCALE_ONE := Vector2(1.0, 1.0)# Échelle normale.
const FADE_DURATION := 1.5  # Durée avant repli automatique du menu.

func _ready():
	context_menu.visible = false  # Cache le menu au démarrage.
	input_pickable = true  # Permet la détection des clics sur l'objet.
	context_menu.mouse_filter = Control.MOUSE_FILTER_STOP  # Stoppe la propagation des événements souris.

	# Prépare un timer pour replier automatiquement le menu après un délai.
	var timer = GameManager.fade_timer
	timer.wait_time = FADE_DURATION
	timer.one_shot = true
	if not timer.timeout.is_connected(_on_fade_timeout):
		timer.timeout.connect(_on_fade_timeout)
		
	# Connecte les signaux de souris aux boutons du menu.
	for button_name in ["EyeButton", "HandButton"]:
		var button = context_menu.get_node(button_name)
		if button:
			connect_mouse_signals(button)

	add_to_group("context_objects")  # Permet une gestion groupée de tous les objets interactifs.
	context_menu.add_to_group("context_menus")  # Permet de gérer tous les menus contextuels ensemble.

func connect_mouse_signals(node):
	# Connecte les signaux de survol à des handlers communs.
	if not node.mouse_entered.is_connected(_on_hover_area_mouse_entered):
		node.mouse_entered.connect(_on_hover_area_mouse_entered)
	if not node.mouse_exited.is_connected(_on_hover_area_mouse_exited):
		node.mouse_exited.connect(_on_hover_area_mouse_exited)

func _input_event(_viewport, event, _shape_idx):
	# Détecte le clic gauche sur l’objet pour afficher le menu.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_context_menu()

func show_context_menu():
	GameManager.hide_all_context_menus()  # Cache les autres menus contextuels.
	context_menu.global_position = global_position + MENU_OFFSET  # Positionne le menu.
	context_menu.visible = true  # Affiche le menu.
	context_menu.scale = MENU_SCALE_ZERO  # Commence invisible.
	context_menu.modulate.a = 0.0  # Opacité à 0.
	context_menu.set_target_scene(target_scene)  # Associe la scène cible.
	context_menu.target_position = global_position
	context_menu.target_node = self

	GameManager.fade_timer.start()  # Lance le timer de repli automatique.

	# Animation du menu avec Tween (position, échelle, opacité)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(context_menu, "scale", MENU_SCALE_ONE, 0.5)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(context_menu, "global_position", global_position + MENU_OFFSET, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(context_menu, "modulate:a", 1.0, 0.3)

	print("🎯 Menu affiché pour :", name)

func hide_with_tween():
	if not visible:
		return  # Évite une animation inutile si déjà invisible.
	var tween = create_tween().set_parallel(true)
	tween.tween_property(context_menu, "global_position", context_menu.global_position + MENU_HIDE_OFFSET, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(context_menu, "scale", MENU_SCALE_ZERO, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.2)
	tween.tween_callback(Callable(self, "_on_hide_menu"))
	
func _on_fade_timeout():
	print("Timer terminé → on replie les menus.")
	#print("⏳ Timer déclenché pour :", self.name, "→ ID menu:", context_menu.get_instance_id())
	hide_with_tween()
	
func _on_hover_area_mouse_entered():
	hover_count += 1  # Empêche le repli si la souris est sur le menu.
	if not GameManager.fade_timer.is_stopped():
		GameManager.fade_timer.stop()

func _on_hover_area_mouse_exited():
	hover_count = max(hover_count - 1, 0)  # Décrémente sans descendre en dessous de zéro.
	if hover_count == 0:
		call_deferred("start_timer_safe")  # Lance un appel différé pour éviter conflit avec d'autres signaux.
	
func start_timer_safe():
	if hover_count == 0:
		GameManager.fade_timer.start()  # Redémarre le timer si rien n’est survolé.
		print('Timer lancé')

######################################
func _on_context_menu_action_chosen(action: String):
	if action == "hand":
		# Fait déplacer le joueur à côté de l’objet.
		if GameManager:
			GameManager.move_player_to(global_position - Vector2(30, 0))
			if not GameManager.is_connected("reached_target", Callable(self, "_on_player_reached_target_once")):
				GameManager.connect("reached_target", Callable(self, "_on_player_reached_target_once"))
	elif action == "eye":
		# Rien à faire ici, l'action est déjà gérée dans le bouton du menu.
		print("👁 Action œil ignorée ici car déjà gérée dans le bouton.")
########################################
