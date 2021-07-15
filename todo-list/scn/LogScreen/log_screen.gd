extends Control

onready var user_email : LineEdit = $LogPanel/LogContainer/UserData/Email
onready var user_passwrd : LineEdit = $LogPanel/LogContainer/UserData/Password
onready var error_lbl : Label = $LogPanel/LogContainer/Error

var mail : String
var pwd : String

# Called when the node enters the scene tree for the first time.
func _ready():
	Supabase.auth.connect("error", self, "_on_auth_error")
	error_lbl.hide()

func _on_auth_error(error : SupabaseAuthError):
	print(error)
	print_error(str(error))
	match error.type :
		"invalid_grant":
			sign_up(mail ,pwd)

func sign_in(email : String, password : String):
	Supabase.auth.sign_in(email, password)
	error_lbl.hide()

func sign_up(email : String, password : String):
	Supabase.auth.sign_up(email, password)
	error_lbl.hide()

func _on_SignInBtn_pressed():
	mail = user_email.get_text()
	pwd = user_passwrd.get_text()
	if mail.length() > 1 and pwd.length() > 1:
		 sign_in(mail, pwd)

func print_error(text : String):
	error_lbl.show()
	error_lbl.set_text(text)
