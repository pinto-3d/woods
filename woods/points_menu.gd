extends Node3D
class_name PointsMenu

var lblPoints: Label3D
var lblHighScore: Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lblPoints = $PointsScore
	lblHighScore = $HighScore
	
	lblPoints.text = "0"
	lblHighScore.text = "0"
	
	RoundManager.i.scoreUpdated.connect(update_score_display)
	RoundManager.i.scoreUpdated.connect(update_high_score_display)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score_display(amt: int):
	lblPoints.text = str(amt)
	pass

func update_high_score_display(amt: int):
	lblHighScore.text = str(amt)
	pass
