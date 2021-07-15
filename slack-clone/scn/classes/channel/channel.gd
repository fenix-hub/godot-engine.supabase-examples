extends VBoxContainer
class_name Channel

signal new_message(message)

export (PackedScene) var message_instance : PackedScene

var _loaded : bool = false
var created_by : String
var id : int
var inserted_at : String
var slug : String

var realtime_client : RealtimeClient

func _ready():
    hide()

func initialize(created_at : String, id : int, inserted_at : String, slug : String) -> void:
    self.created_by = created_at
    self.id = id
    self.inserted_at = inserted_at
    self.slug = slug
    
    connect_client()

func connect_client():
    realtime_client = Supabase.realtime.client()
    realtime_client.connect("connected", self, "_on_connected")
    realtime_client.connect_client()

func _on_connected() -> void:
    realtime_client.channel("public", "messages", "channel_id=eq.%s"%id).on("insert", self, "_on_insert").subscribe()

func load_messages() -> void:
    if _loaded: return
    _loaded = true
    var task : DatabaseTask = yield(RequestsManager.get_messages(id), "completed")
    for message in task.data:
        _on_insert(message, null)

func _on_insert(new_record : Dictionary, channel : RealtimeChannel) -> void:
    var message : Message = message_instance.instance()
    add_child(message)
    var user : UsersManager.User
    if UsersManager.has_user(new_record.user_id):
        user = UsersManager.get_user_by_id(new_record.user_id)
    else:
        user = UsersManager.add_user(new_record.user_id, RequestsManager.get_user(new_record.user_id), RequestsManager.get_user_avatar(new_record.user_id))
    message.set_user(user)
    message.initialize(user.username, new_record.message, user.avatar, user.status)
    emit_signal("new_message", new_record)
