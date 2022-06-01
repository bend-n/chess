extends Control

onready var flags: PoolStringArray = ["rainbow"]
onready var flagchoice: OptionButton = $choose/signup/flag
onready var data: Dictionary = SaveLoad.files.id.data
onready var status: StatusLabel = $StatusLabel
onready var signup: UsernamePass = $choose/signup/usernamepass
onready var signin: UsernamePass = $choose/signin/usernamepass

var autologin = false
var signed_in = false


func _ready():
	Globals.network.connect("signinresult", self, "_on_signin_result")
	Globals.network.connect("signupresult", self, "_on_signup_result")
	Globals.network.connect("connection_established", self, "attempt_autologin")
	flags.append_array(Utils.walk_dir("res://assets/flags", false, "png", ["rainbow"]))
	for i in flags:  # add the items
		flagchoice.add_icon_item(load("res://assets/flags/" + i + ".png"), i.replace("_", " "))


func attempt_autologin():
	autologin = true
	if data.name and data.password:
		Globals.network.signin(data)
		Log.info("Attempting autologin")
	autologin = false


func _on_signin_result(result):
	$choose/signin/signinbutton.disabled = false
	if typeof(result) == TYPE_STRING:  # ew, error, get it away from me
		Log.err(result)
		return
	data.id = result.id
	data.country = result.country
	save_data()
	status.set_text("Sign in sucessfull!")
	signed_in = true  # yay


func _on_signup_result(result: String):
	$choose/signup/signupbutton.disabled = false
	if "err:" in result:  # ew error go awway
		Log.err(result)
		return
	data.id = result
	save_data()
	status.set_text("Sign up sucessfull ( you are now logged in )!")
	signed_in = true  # yay


func _on_signup_pressed():
	$choose/signup/signupbutton.disabled = true
	update_data(signup.username, signup.pw)
	Globals.network.signup(data)


func update_data(username, pw):
	username.text = username.get_text().strip_edges().strip_escapes()
	data.name = username.get_text()
	data.password = pw.get_text()
	save_data()


func save_data():
	SaveLoad.files.id.data = data
	SaveLoad.save("id")


func _on_signin_pressed():
	$choose/signin/signinbutton.disabled = true
	update_data(signin.username, signin.pw)
	Globals.network.signin(data)
