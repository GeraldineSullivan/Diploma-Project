#Display number of lives and number of coins collected at top of screen
extends CanvasLayer

const HEART_ROW_SIZE = 8 # Number of hearts
const HEART_OFFSET = 16 # Distance between hearts

func _ready():
	#find hearts in group "Hearts" and connect signal
	var heart_nodes = get_tree().get_nodes_in_group("Hearts")
	for heart in heart_nodes:
		heart.connect("heart_collected", Callable(self, "_on_heart_collected"))
	
	_refresh_hearts()

#refreshes the hearts display when heart is collected
func _on_heart_collected():
	_refresh_hearts()

func _refresh_hearts():
	for heart in $Heart.get_children():
		heart.queue_free()

	for i in range(Globals.player_max_lives):
		var new_heart = Sprite2D.new()
		new_heart.texture = $Heart.texture
		new_heart.hframes = $Heart.hframes
		$Heart.add_child(new_heart)

func _process(_delta):
	$Coins.text = str(Globals.player_coin)

	var end_heart = floor(Globals.player_lives) # Gets number of full hearts
	var heart_fraction = Globals.player_lives - end_heart # Get the fractional part of the heart at the end

	for heart in $Heart.get_children():
		var index = heart.get_index()
		var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
		var y = (index / HEART_ROW_SIZE) * HEART_OFFSET
		heart.position = Vector2(x, y)

		if index < end_heart:
			# Set to frame 0 if heart is full
			heart.frame = 0
		elif index == end_heart:
			# Set the heart frame (for the end heart) according to how much life is taken away
			heart.frame = int((1 - heart_fraction) * 4)
		else:
			# If the life is empty, set to frame 4 ( the empty frame)
			heart.frame = 4


