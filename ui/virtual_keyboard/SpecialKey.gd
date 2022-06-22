extends KeyUtils
class_name SpecialKey

export(int) var k_scncode := 0
var unicode := 0


func pressed():
	simulate_key_input_event(k_scncode, unicode)


func released():
	simulate_key_input_event(k_scncode, unicode, false)
