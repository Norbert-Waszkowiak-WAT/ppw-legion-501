extends AnimatedSprite2D

@export var heal: float = 50
@export var animation_timer: float = 0.7
@onready var player: Player =  get_node("../../player")

func _ready():
	animation = "full"
	play()

func _process(_delta):
	health_restoring()

#Funkcja odpowiadająca za leczenie gracza
func health_restoring():
	#if sprawdza czy gracz jest w zasięgu leczenia i czy nie ma pełnego zdrowia
	if $Area2D.get_overlapping_bodies() and animation == "full" and PlayerVariables.health < PlayerVariables.MAX_HEALTH:
		#zmiana animacji na pusty odnawiacz zdrowia
		animation = "empty"
		#odgrywa animację
		play()
		if PlayerVariables.health <= PlayerVariables.MAX_HEALTH - PlayerVariables.health:
			PlayerVariables.health += heal
		else:
			PlayerVariables.health += PlayerVariables.MAX_HEALTH - PlayerVariables.health
