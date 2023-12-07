extends AnimatedSprite2D

@export var heal: float = 50
@export var animation_timer: float = 0.7
@onready var player: Player =  get_node("../../player")

func _ready():
	animation = "full"
	play()

func _process(delta):
	health_restoring()

#Funkcja odpowiadająca za leczenie gracza
func health_restoring():
	#if sprawdza czy gracz jest w zasięgu leczenia i czy nie ma pełnego zdrowia
	if $Area2D.get_overlapping_bodies() and animation == "full" and player.health < player.MAX_HEALTH:
		#zmiana animacji na pusty odnawiacz zdrowia
		animation = "empty"
		#odgrywa animację
		play()
		if player.health <= player.MAX_HEALTH - player.health:
			player.health += heal
		else:
			player.health += player.MAX_HEALTH - player.health
