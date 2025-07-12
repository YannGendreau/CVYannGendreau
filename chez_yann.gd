extends Node2D

@onready var path = $Path2D
@onready var path_follower = $Path2D/PathFollower
@onready var player = $Path2D/PathFollower/Employeur

func _ready():
	#print("Appel de place_player_at_last_offset, last_object_interacted: ", get_node("/root/GameManager").last_object_interacted)
	#get_node("/root/GameManager").place_player_at_last_offset()
	print("Appel de place_player_at_last_offset, last_clicked_object: ", get_node("/root/GameManager").last_clicked_object)
	get_node("/root/GameManager").place_player_at_last_offset()
	#GameManager.move_player_to_object("centre")
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
		
		#position = GameManager.last_player_position
		#player.global_position = path_follower.global_position
		#print("✅ Joueur positionné précisément sur le chemin à :", player.global_position)
		#print("🎮 last_clicked_object au ready:", GameManager.last_clicked_object)
		#GameManager.speech_bubble_container = $UI/SpeechBubbleContainer
		#GameManager.show_speech_bubble_above(self, "Coucou !")
