extends Control

@onready var feeling = $HBoxContainer/feeling
@onready var part = $HBoxContainer2/part
@onready var action = $HBoxContainer3/action
@onready var name_input = $name_input
@onready var status = $StatusLabel
@onready var send_btn = $SendButton

@onready var http := HTTPRequest.new()

func _ready():
	add_child(http)
	http.request_completed.connect(_on_request_completed)

	# Remplir les choix
	feeling.add_item("génial")
	feeling.add_item("bizarre")
	feeling.add_item("mystérieux")
	feeling.add_item("frustrant")

	part.add_item("le chien")
	part.add_item("la guitare")
	part.add_item("la télé")
	part.add_item("le carton")

	action.add_item("ajouter des secrets")
	action.add_item("améliorer les graphismes")
	action.add_item("faire rire les gens")

	send_btn.pressed.connect(_on_send_pressed)


func _on_send_pressed():
	var final_text = "Je souhaite vous dire que votre jeu est %s, surtout la partie avec %s. Continuez à %s.\n\nSigné : %s" % [
		feeling.get_item_text(feeling.selected),
		part.get_item_text(part.selected),
		action.get_item_text(action.selected),
		name_input.text.strip_edges()
	]

	#var data = {"name": name_input.text, "message": final_text}
	#var headers = ["Content-Type: application/json"]
#
	#status.text = "Envoi en cours..."
	#http.request("https://francecam.fr/api/contact.php", headers, true, HTTPClient.METHOD_POST, JSON.stringify(data))
	#await FadeLayer.transition()

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		status.text = "✅ Message envoyé ! Merci :)"
	else:
		status.text = "❌ Erreur d’envoi..."
