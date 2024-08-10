extends Node2D

@onready var animal_start = $AnimalStart

const ANIMAL = preload("res://scenes/animal.tscn")


func _ready():
	SignalManager.on_animal_died.connect(add_animal)
	add_animal()
	pass

func add_animal() -> void:
	var animal_instance = ANIMAL.instantiate()
	animal_instance.position = animal_start.position
	add_child(animal_instance)
	pass
	
