extends Node


class User:
    var _default_avatar = preload("res://res/imgs/default-user-avatar.png")
    
    var id : String
    var username : String
    var email : String
    var status : String
    var role : String
    var avatar : Texture = null
    var document : Dictionary
    var picture_task : StorageTask
    var document_task : DatabaseTask

    signal update_picture(avatar)
    signal update_document(document)
    signal update_user(user)

    func _init(id : String, doc_task : DatabaseTask = null, pic_task : StorageTask = null):
        self.id = id
        if doc_task != null:
            document_task = doc_task
            document_task.connect("completed", self, "_on_get_document")
        if pic_task != null:
            picture_task = pic_task
            picture_task.connect("completed", self, "_on_picture_received")
    
    func _on_get_document(doc : DatabaseTask):
        if not doc.error:
            update_document(doc.data[0])

    func update_document(doc : Dictionary) -> void:
            emit_signal("update_document", doc)
            document = doc
            username = document.username
            email = document.username
            status = document.status
            if document.has("user_roles"):
                if not document.user_roles.empty():
                    role = document.user_roles[0].role
                else:
                    role = "user"
            emit_signal("update_user", self)
    
    func get_avatar(id : String) -> void:
        picture_task = RequestsManager.get_user_avatar(id)
        picture_task.connect("completed", self, "_on_picture_received")

    func _on_picture_received(task : StorageTask):
        if task.data != null:
            avatar = Utilities.task2image(task)
        else:
            avatar = _default_avatar
        emit_signal("update_picture", avatar)


var users : Array = []
var rt_client : RealtimeClient

func _ready():
    pass

func connect_rt_users() -> void:
    rt_client = Supabase.realtime.client()
    rt_client.connect("connected", self, "_on_client_connected")
    rt_client.connect_client()
    
func _on_client_connected():
    rt_client.channel("public","users").on("update", self, "_on_user_updated").subscribe()

func _on_user_updated(old_record : Dictionary, new_record : Dictionary, channel : RealtimeChannel):
    if has_user(new_record.id):
        var user : User = get_user_by_id(new_record.id)
        user.update_document(new_record)
        user.get_avatar(new_record.id)

func add_user(id : String, database_task : DatabaseTask = null, picture_task : StorageTask = null) -> User:
    var user : User = User.new(id, database_task, picture_task)
    users.append(user)
    return user

func has_user(id : String) -> bool:
    for user in users:
        if user.id == id:
            return true
    return false

func get_user_by_id(id : String) -> User:
    for user in users:
        if user.id == id:
            return user
    return add_user(id, RequestsManager.get_user(id), RequestsManager.get_user_avatar(id))
