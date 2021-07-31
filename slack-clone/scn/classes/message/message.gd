extends PanelContainer
class_name Message

var id : int                setget set_id
var user_name : String      setget set_user_name
var message : String        setget set_message
var avatar : ImageTexture   setget set_avatar
var media : Array           setget set_media
var timestamp : Dictionary      setget set_timestamp

onready var avatar_container : Avatar = $Box/Avatar
onready var popup_message_menu : PopupMessageMenu = $Box/Options/PopupMessageMenu


export (PackedScene) var _media_preview_scn : PackedScene


func _ready():
    hide()
    set_mode(Globals.mode)
    popup_message_menu.set_message(self)

func set_mode(_mode : int) -> void:
    $Box/Container/Info/Name.set_mode(_mode)
    $Box/Container/Content.set_mode(_mode)
    $Box/Options.set_mode(_mode)
    popup_message_menu._set_mode(_mode)

func initialize(message : String, timestamp : Dictionary, media : Array = []) -> void:
    set_message(message)
    set_timestamp(timestamp)
    set_media(media)
    show()

func set_id(_id : int) -> void:
    id = _id



func set_user(user : UsersManager.User) -> void:
    user.connect("update_picture", self, "set_avatar")
    user.connect("update_user", self , "_on_update_user")
    set_user_name(user.username)
    avatar_container.set_status(user.status)
    popup_message_menu.set_permissions(Globals.user.role)
    if user.avatar!=null:
        set_avatar(user.avatar)


func _on_update_user(user) -> void:
    popup_message_menu.set_permissions(Globals.user.role)
    avatar_container.set_status(user.status)
    set_user_name(user.username)
    

func set_user_name(_name : String) -> void:
    user_name = _name
    $Box/Container/Info/Name.set_text(user_name)


func set_message(_message : String) -> void:
    message = _message
    $Box/Container/Content.set_text(message)

func set_timestamp(_ts : Dictionary) -> void:
    timestamp = _ts
    $Box/Container/Info/Timestamp.set_text("{hour}:{minute}".format(timestamp))

func set_avatar(_avatar : ImageTexture) -> void:
    avatar_container.set_avatar(_avatar)

func set_media(_media : Array) -> void:
    if _media.empty(): return
    for texture in _media:
        add_media(texture, texture.get_meta("id"))

func add_media(texture : ImageTexture = null, _name : String = "") -> MediaPreview:
    var preview : MediaPreview = _media_preview_scn.instance()
    preview.connect("show_media", Globals.main, "_on_show_media")
    preview.set_texture(texture)
    $Box/Container/Media.add_child(preview)
    media.append(_name)
    return preview

func fetch_media(_media : Array) -> void:
    if _media[0] is Dictionary: pass
    for m in _media:
        var media_preview : MediaPreview = add_media(null, m)
        var media_task : StorageTask = RequestsManager.get_message_media(m)
        media_task.connect("completed" , self, "_on_fetchmedia_completed", [media_preview])

func _on_fetchmedia_completed(task : StorageTask, media_preview : MediaPreview) -> void:
    media_preview.texture = (Utilities.task2image(task))


func _on_Options_pressed():
    popup_message_menu.popup_on_pos($Box/Options.rect_global_position)
