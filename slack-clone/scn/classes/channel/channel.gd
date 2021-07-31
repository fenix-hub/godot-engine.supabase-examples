extends VBoxContainer
class_name Channel

signal new_message(message)
signal update_channel(channel)

export (PackedScene) var message_instance : PackedScene

var _loaded : bool = false
var is_dm : bool = false
var created_by : String
var id : int
var inserted_at : String
var slug : String
var description : String
var with_user : UsersManager.User

var realtime_client : RealtimeClient

var last_message_id : int

func _ready():
    hide()

func initialize(created_by : String, id : int, inserted_at : String, slug : String, description : String, is_dm : bool = false) -> void:
    self.is_dm = is_dm
    self.created_by = created_by
    self.id = id
    self.inserted_at = inserted_at
    self.slug = slug
    self.description = description
    connect_client()

func set_with_user(with_user : UsersManager.User) -> void:
    self.with_user = with_user
    self.with_user.connect("update_user", self, "_on_update_user")

func _on_update_user(user : UsersManager.User) -> void:
    slug = with_user.username
    emit_signal("update_channel", self)

func connect_client():
    realtime_client = Supabase.realtime.client()
    realtime_client.connect("connected", self, "_on_connected")
    realtime_client.connect_client()

func _on_connected() -> void:
    realtime_client.channel("public", "messages", "channel_id=eq.%s"%[id]) \
    .on("insert", self, "_on_insert") \
    .on("delete", self, "_on_delete") \
    .subscribe()

func load_messages() -> void:
    if _loaded: return
    _loaded = true
    var task : DatabaseTask = yield(RequestsManager.get_messages(id), "completed")
    for message in task.data:
        _on_insert(message, null)

func _on_delete(old_record : Dictionary, channel : RealtimeChannel) -> void:
    for message in get_children():
        if message.id == int(old_record.id):
            message.queue_free()
            return

func get_message(id : int) -> Message:
    for message in get_children():
        if message.id == id:
            return message
    return null

func _on_insert(new_record : Dictionary, channel : RealtimeChannel) -> void:
    if Globals.sending_message:
        return
    if get_message(int(new_record.id)):
        return
    var message : Message = message_instance.instance()
    add_child(message)
    var media_attached = new_record.media_attached
    message.initialize(new_record.message, Utilities.parse_timestamp(new_record.inserted_at))
    var user : UsersManager.User = UsersManager.get_user_by_id(new_record.user_id)
    message.set_user(user) 
    message.set_id(int(new_record.id))
    if media_attached is String: 
        media_attached = media_attached.lstrip("{").rstrip("}")
        if media_attached == "" or media_attached == null:
            media_attached = []
        else:
            media_attached = media_attached.split(",")
    if media_attached != null and not media_attached.empty():
        message.fetch_media(media_attached)
    emit_signal("new_message", message)

func add_user_message(id : int, text : String, images : Array = []) -> void:
    var message : Message = message_instance.instance()
    add_child(message)
    var user : UsersManager.User = UsersManager.get_user_by_id(Supabase.auth.client.id)
    var media : Array = []
    for m in images:
        var imageHolder : TImageHolder = m as TImageHolder
        media.append(imageHolder.texture)
    message.initialize(text, OS.get_datetime(), media)
    message.set_user(Globals.user)
    message.set_id(id)
    emit_signal("new_message", message)   
