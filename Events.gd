extends Node

# warning-ignore-all:unused_signal
signal turn_over
signal game_over(reason, isok)  # called when the game is over
signal go_back(reason, isok)  # called when the game is over, and were ready to go back
