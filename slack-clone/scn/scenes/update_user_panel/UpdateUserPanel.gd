extends SPanel

signal hide_update_user()

onready var username : SInput = $VBoxContainer/Name
onready var avatar : TextureRect = $VBoxContainer/Avatar

func _ready():
    pass


func set_user(user : UsersManager.User) -> void:
    user.connect("update_user", self, "_on_update_document")
    user.connect("update_picture", self, "set_avatar")
    username.set_text(user.username)
    if user.avatar:
        avatar.set_texture(user.avatar)

func _on_update_document(data : UsersManager.User):
    username.set_text(data.username)

func set_avatar(texture : Texture) -> void:
    avatar.set_texture(texture)

func set_avatar_path(path : String) -> void:
    avatar.set_meta("path", path)

func clear():
    pass


func _on_Cancel_pressed():
    hide()
    emit_signal("hide_update_user")
    clear()


func _on_Confirm_pressed():
    if Globals.user.avatar != avatar.get_texture():
        yield(RequestsManager.update_user_avatar(avatar.get_meta("path"), Globals.user.avatar == null), "completed")
    RequestsManager.update_username(username.get_text())
    $VBoxContainer/HBoxContainer/Confirm.stop_loading()
    _on_Cancel_pressed()

func _on_FileDropHandler_files_dropped(files):
    set_avatar(Utilities.get_texture(files[0]))
    set_avatar_path(files[0])


func _on_UpdateUserPanel_visibility_changed():
    if visible: Globals.filedrop_handler = $VBoxContainer/Avatar/FileDropHandler
