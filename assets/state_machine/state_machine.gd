extends Node
# Skrypt właściwy state machine'a. Odpowiada za przekazywanie informacji do
# skryptów poszczególnych stanów, oraz za zmianę pomiędzy stanami.

# Stan początkowy dla gracza
@export var starting_state: State

# Stan bieżący
var current_state: State


# Inicjalizuje state machine
func init(player: Player):
	# Daje wszystkim stanom odniesienie do gracza
	for state in get_children():
		state.player = player
	
	# Ustawia stan na stan początkowy
	change_state(starting_state)


# Wywoływana co klatkę, odpowiada za procesy fizyczne
func physics(delta: float):
	var new_state = current_state.physics(delta)
	if new_state:
		change_state(new_state)


# Wywoływana co klatkę
func process(delta: float):
	var new_state = current_state.process(delta)
	if new_state:
		change_state(new_state)


# Zmiana stanu
func change_state(state: State):
	if current_state:
		current_state.exit()
	current_state = state
	current_state.enter()

#	print(current_state)

