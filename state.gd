extends Node
class_name State
# Klasa bazowa dla stanów state machine'a. Nie jest używana bezpośrednio, lecz
# służy jako baza do robienia stanów gracza.


# Odniesienie do gracza
var player: Player


# Funkcja wywoływana gdy gracz wejdzie w dany stan
func enter():
	pass

# Funkcja wywoływana gdy gracz opuści dany stan
func exit():
	pass

# Wywoływana na każdej klatce, odpowiada za procesy fizyczne
func physics(delta: float) -> State:
	return null

# Wywoływana na każdej klatce
func process(delta: float) -> State:
	return null
