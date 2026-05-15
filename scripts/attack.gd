extends Node2D
class_name Attack
@export var move: MoveData

func setup(this_move):
	move = this_move
	$Label.text = str(move.energy_cost)
