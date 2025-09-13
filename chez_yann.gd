extends Node2D

@onready var path = $Path2D
@onready var path_follower = $Path2D/PathFollower
@onready var player = $Path2D/PathFollower/Employeur
@onready var animated_sprite = $Path2D/PathFollower/Employeur/AnimatedSprite2D

func _ready():
	print("Appel de place_player_at_last_offset, last_clicked_object: ", get_node("/root/GameManager").last_clicked_object)
	get_node("/root/GameManager").place_player_at_last_offset()
	if GameManager and GameManager.last_clicked_object != "":
		await get_tree().process_frame
		GameManager.place_player_at_last_offset()
		print('place_player_at_last_offest est appelé')
	else:
		print("⏩ Aucun objet encore cliqué, le joueur ne sera pas déplacé au démarrage.")
		GameManager.init_refs(self)
		path_follower.progress_ratio = GameManager.player_path_ratio
		await get_tree().process_frame
		#GameManager.place_player_at_last_offset()
	if player and GameManager:
		print("✅ Scène chez_yann prête avec Employeur et GameManager")
	else:
		push_error("❌ Erreur : Employeur ou GameManager non trouvé dans chez_yann.tscn")	
		
	if GameManager:
		GameManager.reset_bubbles()
		# 🔄 Reset complet des références
	if GameManager:
		# 🔄 Reset des bulles
		GameManager.current_bubble = null
		
		# 👇 Réassigne le container à chaque retour
		
		var bubble_container = $UI/SpeechBubbleContainer
		if bubble_container:
			GameManager.speech_bubble_container = bubble_container
		else:
			push_error("⚠️ Aucun SpeechBubbleContainer trouvé dans chez_yann.tscn")

	animated_sprite.play('front')
