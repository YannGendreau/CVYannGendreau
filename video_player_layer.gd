extends CanvasLayer

@onready var player := get_node('/root/scene_tv/VideoPlayerLayer/VideoStreamPlayer') 
@onready var play_pause_btn := $PlayerUI/HBoxContainer/PlayPauseButton
@onready var progress := $PlayerUI/HBoxContainer/ProgressBar
@onready var time_label := $PlayerUI/HBoxContainer/TimeLabel
@onready var volume_slider := $PlayerUI/HBoxContainer/VolumeSlider
#@onready var close_btn := $CloseButton

var is_playing := false

func _ready():
	player.connect("finished", _on_video_finished)
	play_pause_btn.pressed.connect(_on_play_pause_pressed)
	#progress.value_changed.connect(_on_seek)
	volume_slider.value_changed.connect(_on_volume_changed)
	#close_btn.pressed.connect(_on_close_pressed)

	progress.min_value = 0
	progress.max_value = 1
	progress.step = 0.001
	volume_slider.min_value = 0
	volume_slider.max_value = 1
	volume_slider.value = 1

func _process(_delta):
	if player.stream and player.is_playing():
		progress.value = player.get_stream_position() / player.get_stream_length()
		var t = int(player.get_stream_position())
		var total = int(player.get_stream_length())
		time_label.text = "%02d:%02d / %02d:%02d" % [t/60, t%60, total/60, total%60]

func _on_play_pause_pressed():
	is_playing = !is_playing
	if is_playing:
		player.play()
	else:
		player.pause()

#func _on_seek(value):
	#if player.stream:
		#player.seek(value * player.get_stream_length())

func _on_volume_changed(value):
	player.volume_db = linear_to_db(value)

func _on_video_finished():
	is_playing = false
	play_pause_btn.pressed = false

func _on_close_pressed():
	player.stop()
	get_parent().visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):  # touche Entrée ou Espace
		_on_play_pause_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
