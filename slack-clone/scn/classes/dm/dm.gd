extends VBoxContainer
class_name DM

signal new_message(message)

export (PackedScene) var message_instance : PackedScene

var _loaded : bool = false
var id : int
var dm_id : String
var user1 : UsersManager.User
var user2 : UsersManager.User

var realtime_client : RealtimeClient

var last_message_id : int

func _ready():
    hide()

func initialize(created_at : String, id : int, inserted_at : String, slug : String, description : String) -> void:
    self.created_by = created_at
    self.id = id
    self.inserted_at = inserted_at
    self.slug = slug
    self.description = description
    connect_client()

func connect_client():
    realtime_client = Supabase.realtime.client()
    realtime_client.connect("connected", self, "_on_connected")
    realtime_client.connect_client()

func _on_connected() -> void:
    realtime_client.channel("public", "dms", "id=eq.%s"%[dm_id]) \
    .on("insert", self, "_on_insert") \
    .on("delete", self, "_on_delete") \
    .subscribe()

func load_messages() -> void:
    if _loaded: return
    _loaded = true
    var task : DatabaseTask = yield(RequestsManager.get_dms(id), "completed")
    for message in task.data:
        _on_insert(message, null)

func _on_delete(old_record : Dictionary, channel : RealtimeChannel) -> void:
    for message in get_children():
        if message.id == int(old_record.id):
            message.queue_free()
            return


func _on_insert(new_record : Dictionary, channel : RealtimeChannel) -> void:
    if Globals.sending_message:
        return
    var message : Message = message_instance.instance()
    add_child(message)
    var media_attached = new_record.media_attached
    message.initialize(new_record.message, Utilities.parse_timestamp(new_record.inserted_at))
    var user : UsersManager.User
    if UsersManager.has_user(new_record.user_id):
        user = UsersManager.get_user_by_id(new_record.user_id)
    else:
        user = UsersManager.add_user(new_record.user_id, RequestsManager.get_user(new_record.user_id), RequestsManager.get_user_avatar(new_record.user_id))
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
