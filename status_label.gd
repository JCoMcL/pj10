extends Label

func _on_win():
	text = "You Win!"

func _on_lose():
	text = "Game Over"

func _ready():
	text = ""
