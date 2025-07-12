extends TextureButton

func _on_pressed():
	GameManager.on_click_interactable(get_parent())
