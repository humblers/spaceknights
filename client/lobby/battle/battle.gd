extends TextureRect

var id

func _ready():
	$Mid/Match.connect("pressed", self, "match_request")

func set_top_information(level, experience, galacticoin, dimensium):
	$Top/Level.text = String(level + 1) # level based on 0
	$Top/Level/Exp.text = String(experience)
	$Top/Galacticoin.text = String(galacticoin)
	$Top/Dimensium.text = String(dimensium)

func match_request():
	var resp = yield(http.new_request(HTTPClient.METHOD_POST, "/match/request"), "response")
	var cfg = resp[1].Config
	tcp.Connect(resp[1].Address, 9999)
	yield(tcp, "connected")
	tcp.Send({"Id": id, "Token": id})
	tcp.Send({"GameId": cfg.Id})
	queue_free()
	var g = preload("res://game/game.tscn").instance()
	g.connected = true
	g.cfg = cfg
	get_tree().get_root().add_child(g)