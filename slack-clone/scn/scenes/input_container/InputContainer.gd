extends MarginContainer

signal send_message(text, images)

export (PackedScene) var image_holder_scene : PackedScene

onready var input : LineEdit = $PanelContainer/VBoxContainer/LineEdit
onready var imgs_container : HBoxContainer = $PanelContainer/VBoxContainer/Imgs

onready var send_btn : PrimaryButton = $PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/SendBtn

func _ready():
    send_btn.disabled = true

func load_images(images : PoolStringArray) -> void:
    if not imgs_container.visible: imgs_container.show()
    for image in images:
        var texture : ImageTexture = get_texture(image)
        var img_rect : TImageHolder = image_holder_scene.instance()
        imgs_container.add_child(img_rect)
        img_rect.set_texture(texture)
        img_rect.show()
        img_rect.connect("image_removed", self, "_on_remove_image")
        img_rect.path = image
        img_rect.id = "%s.%s" % [OS.get_unix_time(), image.get_extension()]

func get_texture(file_path : String) -> ImageTexture:
    var img : Image = Image.new()
    img.load(file_path)
    var texture : ImageTexture = ImageTexture.new()
    texture.create_from_image(img, 4)
    return texture

func set_placeholder_text(text : String) -> void:
    input.placeholder_text = text


func _on_remove_image(img : TImageHolder):
    img.queue_free()
    if imgs_container.get_child_count() < 1 : imgs_container.hide()
    
func stop_loading():
    send_btn.stop_loading()

func send_message(text : String) -> void:
    emit_signal("send_message", text, imgs_container.get_children())

func _on_SendBtn_pressed():
    send_message(input.get_text())

func _on_text_entered(text : String) -> void:
    if text!="":
        send_btn.start_loading()
        send_message(text)

func _on_LineEdit_text_changed(new_text : String):
    send_btn.disabled = (new_text == "")

# ---------------------------------------------------------

func clear():
    _clear_imgs()
    _clear_input()
    stop_loading()

func _clear_input():
    input.clear()

func _clear_imgs():
    for image in imgs_container.get_children():
        image.queue_free()
    imgs_container.hide()
