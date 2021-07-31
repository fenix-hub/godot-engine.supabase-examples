extends ColorRect

func _ready():
    hide()

func show_media(media_preview : MediaPreview) -> void:
    $Media.set_texture(media_preview.texture)
    show()


func _on_MediaHolder_gui_input(event):
    if event is InputEventMouseButton:
        if event.get_button_index() == 1 and event.is_pressed():
            hide()
