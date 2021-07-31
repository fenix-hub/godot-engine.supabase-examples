extends Control
class_name TImageHolder

signal image_removed(img)

var path : String
var id : String             setget set_id
var texture : ImageTexture  setget set_texture


# Called when the node enters the scene tree for the first time.
func _ready():
    hide()
    $Button.hide()

func set_id(_id : String) -> void:
    id = _id
    texture.set_meta("id", id)

func set_texture(_texture : ImageTexture) -> void:
    texture = _texture
    $TextureRect.set_texture(texture)

func get_texture() -> ImageTexture:
    return $TextreRect.get_texture()

func _on_PanelContainer_mouse_entered():
    $Button.show()


func _on_PanelContainer_mouse_exited():
    $Button.hide()


func _on_Button_pressed():
    emit_signal("image_removed", self)
