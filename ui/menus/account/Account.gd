extends Control

onready var flags: PoolStringArray = ["rainbow"]
onready var flagchoice: GridMenuButton = $choose/signup/flag
onready var data: Dictionary = SaveLoad.get_data("id")
onready var status: Label = $H/InfoLabel  # not a StatusLabel
onready var loading = $LoadingAnimation

onready var tabs := {
	"signup": $choose/signup/usernamepass,
	"signin": $choose/signin/usernamepass,
}

var signed_in = false setget set_signed_in
var autologin = true

onready var tabcontainer = $choose


func set_signed_in(new):
	signed_in = new
	Events.emit_signal("set_signed_in", new)


func _ready():
	loading.show()
	tabcontainer.hide()
	if Globals.network:
		Globals.network.connect("signinresult", self, "_on_signin_result")
		Globals.network.connect("signupresult", self, "_on_signup_result")
		Globals.network.connect("connection_established", self, "attempt_autologin")
	flags.append_array(Utils.walk_dir("res://assets/flags", false, ["rainbow"]))
	for i in flags:  # add the items
		flagchoice.add_item(load("res://assets/flags/%s.png" % i), i.replace("_", " "))
	flagchoice.selected = 0


func attempt_autologin():
	if data.name and data.password:
		Globals.network.signin(data)
	else:
		reset("", false)


func _on_signin_pressed():
	$choose/signin/signinbutton.disabled = true
	update_data(tabs.signin.username, tabs.signin.pw)
	Globals.network.signin(data)


func _on_signin_result(result):
	var status_set = !autologin
	if autologin:
		autologin = false
		yield(get_tree().create_timer(.5), "timeout")
	$choose/signin/signinbutton.disabled = false
	if typeof(result) == TYPE_STRING:  # ew, error, get it away from me
		return reset(result, status_set)
	data.id = result.id
	data.country = result.country
	_after_result()


func _on_signup_pressed():
	$choose/signup/signupbutton.disabled = true
	data.country = flags[flagchoice.selected]
	update_data(tabs.signup.username, tabs.signup.pw)
	Globals.network.signup(data)


func _on_signup_result(result: String):
	$choose/signup/signupbutton.disabled = false
	if "err:" in result:  # ew error go awway
		return reset(result)
	data.id = result
	_after_result()


func reset(reason: String, set_status := true):
	if set_status:
		status.set_text(reason)
	data = SaveLoad.default_id_data
	tabcontainer.show()
	loading.hide()
	set_signed_in(false)
	save_data()
	tabcontainer.show()


func _after_result():
	save_data()
	status.set_text("Signed in to " + SaveLoad.get_data("id").name)
	self.signed_in = true  # yay
	$H/LogOut.show()
	tabcontainer.hide()


func update_data(username, pw):
	username.text = username.get_text().strip_edges().strip_escapes()
	data.name = username.get_text()
	data.password = pw.get_text()
	save_data()


func save_data():
	SaveLoad.files.id.data = data
	SaveLoad.save("id")


func _on_choose_tab_changed(tab: int):
	var new: VBoxContainer = $choose.get_children()[tab].get_node("usernamepass")
	var old = $choose.get_children()[1 if tab == 0 else 0].get_node("usernamepass")
	new.update_data(old.export_data())


func log_out():
	$H/LogOut.hide()
	reset("You are now logged out!")
