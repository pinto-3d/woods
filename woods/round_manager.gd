extends Node3D
class_name RoundManager

static var i: RoundManager

var currentScore: int = 0
var highScore: int = 0
var isGettingHighscore: bool = false

signal roundStarted()
signal scoreUpdated(newScore: int)
signal highscoreUpdated(newScore: int)


func reset():
	currentScore = 0
	isGettingHighscore = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if RoundManager.i:
		return
	RoundManager.i = self
	
	GridManager.i.match_made.connect(add_score)
	
	start()
	pass # Replace with function body.

func start():
	roundStarted.emit()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_score(amt: int):
	currentScore += amt
	scoreUpdated.emit(currentScore)
	if currentScore > highScore:
		set_high_score(currentScore)
	pass
func set_high_score(amt: int):
	highScore = amt
	isGettingHighscore = true
	highscoreUpdated.emit(highScore)
	pass
