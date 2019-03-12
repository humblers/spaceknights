extends HTTPRequest

const LOBBY_DEFAULT_HOST = "https://www.humbler.games/"
const LOBBY_DEFAULT_HEADER = [
	"Content-Type: application/json"
]

var lobby_host
var queued_requests = []

func _ready():
	lobby_host = config.get("LOBBY_HOST")
	if lobby_host == null:
		lobby_host = LOBBY_DEFAULT_HOST
	if not lobby_host.begins_with("http"):
		lobby_host = "http://%s:8080" % lobby_host

func New(path, params = {}):
	params["UID"] = user.Id
	params["HumblerToken"] = user.HumblerToken
	params["IssuedAt"] = user.IssuedAt
	var resource = $ResourcePreloader.get_resource("queued_request")
	var req = resource.new(self, "%s%s" % [lobby_host, path], to_json(params))
	queued_requests.push_back(req)
	requestNext()
	return req

func requestNext():
	var next = queued_requests.pop_front()
	if next == null:
		return
	var err = request(next.url, LOBBY_DEFAULT_HEADER, true,
				HTTPClient.METHOD_POST, next.body)
	match err:
		OK:
			self.connect("request_completed", next, "requestCompleted")
		ERR_BUSY:
			queued_requests.push_front(next)
		_:
			next.call_deffered("requestCompleted", [err, OK, PoolStringArray(), "{}"])
