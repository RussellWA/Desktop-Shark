extends Node

var mic_player

func _ready():
	var devices = AudioServer.get_input_device_list()
	print("Available Microphones: ", devices)

	if devices.size() > 0:
		AudioServer.input_device = devices[0]  # Select first microphone
		print("Using microphone: ", AudioServer.input_device)

		# Create AudioStreamMicrophone
		var mic_stream = AudioStreamMicrophone.new()

		# Play mic input through an AudioStreamPlayer
		mic_player = AudioStreamPlayer.new()
		mic_player.stream = mic_stream
		mic_player.bus = "Master"  # Make sure Master bus is not muted
		add_child(mic_player)

		mic_player.play()
		print("Microphone started!")

func _exit_tree():
	if mic_player:
		mic_player.stop()
