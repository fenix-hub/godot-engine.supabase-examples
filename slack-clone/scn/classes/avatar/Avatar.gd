class_name Avatar
extends TextureRect

func _ready():
    pass # Replace with function body.

func set_status(status : String) -> void:
    match status:
        "OFFLINE": $Status.hide()
        "ONLINE": $Status.show()

func free_loader() -> void:
    if has_node("Loader"):
        $Loader.queue_free()

func set_avatar(texture : Texture) -> void:
    if texture:
        set_texture(texture)
    free_loader()
