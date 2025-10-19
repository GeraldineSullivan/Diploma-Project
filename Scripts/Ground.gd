#changes the tilemap background to black

extends TileMap

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
