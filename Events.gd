extends Node

# warning-ignore-all:unused_signal
signal turn_over
signal just_before_turn_over  # called just before turn over
signal outoftime  # called when the time is up
signal game_over(reason, isok)  # called when the game is over
signal go_back(reason, isok)  # called when the game is over, and were ready to go back
signal data_recieved  # called every time the data comes in
signal set_signed_in(signed_in)
