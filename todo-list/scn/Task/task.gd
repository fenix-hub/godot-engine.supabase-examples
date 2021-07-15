extends HBoxContainer
class_name Task

onready var content : Label = $Content
onready var check : CheckBox = $Check

var id : int
var is_complete : bool setget set_is_complete
var deleting : bool = false

func _ready():
	Supabase.database.connect("deleted", self, "_on_deleted")


func _on_Check_toggled(button_pressed : bool):
	if button_pressed : 
		content.set("custom_colors/font_color", Color("#787878"))
	else : 
		content.set("custom_colors/font_color", Color.white)
	Supabase.database.query(SupabaseQuery.new().from("todos").update({"is_complete":button_pressed}).eq("id",str(id)))

func set_is_complete(complete : bool):
	is_complete = complete
	check.pressed = (is_complete)

func _on_RemoveBtn_pressed():
	deleting = true
	Supabase.database.query(SupabaseQuery.new().from("todos").delete().eq("id",str(id)))

func _on_deleted():
	if deleting : queue_free()
