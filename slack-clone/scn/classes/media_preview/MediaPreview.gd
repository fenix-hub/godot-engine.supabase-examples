extends PanelContainer
class_name MediaPreview

signal show_media(media)

var texture : ImageTexture  setget set_texture
var id : String             setget set_id

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func set_texture(_texture: ImageTexture) -> void:
    texture = _texture
    $Image.texture = texture
    if texture != null:
        $Loader.queue_free()

func set_id(_id : String) -> void:
    id = _id
    texture.set_meta("id", id)



func _on_MediaPreview_gui_input(event):
    if event is InputEventMouseButton:
        if event.get_button_index() == 1 and event.is_pressed():
            emit_signal("show_media", self)
