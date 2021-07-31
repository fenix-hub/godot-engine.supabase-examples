extends SPanel

signal hide_add_channel()

onready var slug : SInput = $VBoxContainer/Name
onready var description : SInput = $VBoxContainer/Description



# Called when the node enters the scene tree for the first time.
func _ready():
    $VBoxContainer/HBoxContainer/Confirm.disabled = true

func clear():
    slug.set_text("")
    description.set_text("")


func _on_Cancel_pressed():
    hide()
    emit_signal("hide_add_channel")
    clear()


func _on_Confirm_pressed():
    yield(RequestsManager.add_new_channel(slug.get_text(), description.get_text()), "completed")
    $VBoxContainer/HBoxContainer/Confirm.stop_loading()
    $VBoxContainer/HBoxContainer/Confirm.disabled = true
    _on_Cancel_pressed()

func _on_Name_text_changed(text):
    $VBoxContainer/HBoxContainer/Confirm.disabled = not (slug.get_text() != "" and description.get_text() != "")
    

func _on_Description_text_changed(text):
    $VBoxContainer/HBoxContainer/Confirm.disabled = not (slug.get_text() != "" and description.get_text() != "")




