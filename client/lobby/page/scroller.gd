extends CanvasItem

const SCROLL_EXTEND_LIMIT = 100
const MODE_NORMAL = "NORMAL"

export(NodePath) onready var scrollable = get_node(scrollable) if scrollable != null else null
export(String, "Battle", "Card") var name_ = null

var tween = null
var scroll_disabled = true
var scroll_min_y
var scroll_max_y

func _ready():
	if has_node("Tween"):
		tween = $Tween
	event.connect("PageSelected", self, "pageSelected")
	event.connect("VerticalScrollInput", self, "scroll")

func pageSelected(page):
	scroll_disabled = page != name_

func scroll(released, dy):
	if scrollable == null or scroll_disabled:
		return
	if released:
		if scrollable.rect_position.y > scroll_max_y:
			tween.interpolate_property(
					scrollable,
					"rect_position",
					scrollable.rect_position,
					Vector2(scrollable.rect_position.x, scroll_max_y),
					0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			tween.start()
		elif scrollable.rect_position.y < scroll_min_y:
			tween.interpolate_property(
					scrollable,
					"rect_position",
					scrollable.rect_position,
					Vector2(scrollable.rect_position.x, scroll_min_y),
					0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			tween.start()
		return
	if scrollable.rect_position.y < scroll_min_y - SCROLL_EXTEND_LIMIT:
		return
	if scrollable.rect_position.y > scroll_max_y + SCROLL_EXTEND_LIMIT:
		return
	scrollable.rect_position.y -= dy