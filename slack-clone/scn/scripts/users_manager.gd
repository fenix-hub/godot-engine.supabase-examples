extends Node

class User:
    var id : String
    var username : String
    var email : String
    var status : String
    var avatar : ImageTexture
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

    func update_document(dict : Dictionary):
        pass
#        document_task.connect("get_document", self, "_on_get_document")

    func update_picture(new_picture : ImageTexture) -> void:
        avatar = new_picture
        emit_signal("update_picture", new_picture)
    
    func _on_get_document(doc : DatabaseTask):
        if not doc.error:
            emit_signal("update_document", doc.data[0])
            document = doc.data[0]
            username = document.username
            email = document.username
            status = document.status
            emit_signal("update_user", self)

    func _on_picture_received(task : StorageTask):
        if task.data:
            avatar = Utilities.task2image(task)
            emit_signal("update_picture", avatar)

    func update_status(status : String) -> void:
        self.status = status
        emit_signal("update_user", self)

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
        user.update_status(new_record.status)

func add_user(id : String, firestore_task : DatabaseTask = null, picture_task : StorageTask = null) -> User:
    var user : User = User.new(id, firestore_task, picture_task)
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
    return null
