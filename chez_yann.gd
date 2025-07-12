extends Node2D

@onready var path = $Path2D
@onready var path_follower = $Path2D/PathFollower
@onready var player = $Path2D/PathFollower/Employeur

func _ready():
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
		
		#position = GameManager.last_player_position
		#player.global_position = path_follower.global_position
		#print("✅ Joueur positionné précisément sur le chemin à :", player.global_position)
		#print("🎮 last_clicked_object au ready:", GameManager.last_clicked_object)
		#GameManager.speech_bubble_container = $UI/SpeechBubbleContainer
		#GameManager.show_speech_bubble_above(self, "Coucou !")
