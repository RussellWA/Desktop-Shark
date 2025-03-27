extends Control

signal send_scale(size: int)

@onready var scale_up_btn: Button = $NinePatchRect/GridContainer/ScaleUpBtn
@onready var scale_down_btn: Button = $NinePatchRect/GridContainer/ScaleDownBtn

func _ready():
	scale_up_btn.pressed.connect(_scale_up_shark)
	scale_down_btn.pressed.connect(_scale_down_shark)

func _scale_up_shark():
	send_scale.emit(1)

func _scale_down_shark():
	send_scale.emit(-1)
	
