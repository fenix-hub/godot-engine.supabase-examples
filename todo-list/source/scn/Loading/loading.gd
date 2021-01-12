extends Control
class_name LoadingScene

onready var throbber : TextureRect = $Throbber

var i : float = 0
var value : float = 0
var speed : float = 3.2

func _ready():
	add_to_group("loading_scene", true)
	set_loading()

func set_loading(is_loading : bool = false):
	set_process(is_loading)
	if is_loading: show()
	else : hide()

func _process(delta):
	i+=delta*speed
	if i > 100 : i = 1
	value = sin(i)
	throbber.modulate.a = max(0.2, value)
	throbber.set_rotation(PI*value)
