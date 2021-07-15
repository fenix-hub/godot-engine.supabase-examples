extends Control

onready var task_list : VBoxContainer = $MainContainer/TaskContainer/TaskList
onready var task_text : TextEdit = $MainContainer/NewTask/TaskText
onready var add_task_btn : Button = $MainContainer/NewTask/AddTaskBtn
onready var log_screen : Control = $LogScreen
onready var user_id : Label = $MainContainer/UserContainer/UserId
onready var error_lbl : Label = $MainContainer/ErrorLbl

var task_scene : PackedScene = preload("res://scn/Task/task.tscn")
var user : SupabaseUser

var tasks : Array = []
var last_id : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Supabase.auth.connect("signed_in", self, "_on_signed")
	Supabase.auth.connect("signed_up", self, "_on_signed")
	Supabase.database.connect("inserted", self, "_on_inserted")
	Supabase.database.connect("selected", self, "_on_selected")
	Supabase.database.connect("error", self, "_on_database_error")
	Supabase.auth.connect("error", self, "_on_auth_error")
	log_screen.show()
	error_lbl.hide()

func clear_tasks():
	for task in task_list.get_children() : task.queue_free()
	tasks.clear()
	user_id.set_text("user-id")

func _on_signed(user : SupabaseUser):
	self.user = user
	user_id.set_text(self.user.id)
	Supabase.database.query(SupabaseQuery.new().from("todos").select(["*"]).eq("user_id",user.id))
	var tasks_found : Array = yield(Supabase.database, "selected")
	for task_found in tasks_found:
		add_task(task_found.task, task_found.is_complete, task_found.id)
		if last_id < task_found.id: last_id = task_found.id
	log_screen.hide()

func add_task(text : String, is_complete : bool = false, id : int = -1):
	var new_task : Task = task_scene.instance()
	tasks.append(new_task)
	task_list.add_child(new_task)
	new_task.content.text = text
	if id == -1 : 
		last_id+=1
		new_task.id = last_id
	else: new_task.id = id
	new_task.set_is_complete(is_complete)

func _on_add_new_task():
	error_lbl.hide()
	if task_text.get_text().length() > 1:
		Supabase.database.query(SupabaseQuery.new().from("todos").insert([{"user_id":user.id, "task":task_text.get_text(), "is_complete":false}]))
		yield(Supabase.database, "inserted")
		add_task(task_text.get_text())
		task_text.set_text("")
	else:
		print_error("Cannot create an empty task!")

func _on_inserted():
	pass

func _on_selected(result : Array):
	pass

func _on_database_error(database_error : SupabaseDatabaseError):
	printerr(database_error)
	print_error(str(database_error))

func _on_auth_error(auth_error : SupabaseAuthError):
	print_error(str(auth_error))

func _on_LogOut_pressed():
	Supabase.auth.log_out()
	yield(Supabase.auth, "logged_out")
	clear_tasks()
	log_screen.show()

func print_error(error : String):
	error_lbl.set_text(error)
	error_lbl.show()
	$ErrorTimer.start()


func _on_ErrorTimer_timeout():
	error_lbl.hide()
