extends Control

const PAGES = {
	"Shop": -2,
	"Card": -1,
	"Battle": 0,
	"Explore": 1,
	"Social": 2,
}
const PAGE_WIDTH_MIN = 1440

func _ready():
	reorder_pages()
	self.connect("resized", self, "reorder_pages")

func reorder_pages():
	yield(get_tree(), "idle_frame") # wait for sub control's size update
	var size = rect_size
	if size.x < PAGE_WIDTH_MIN:
		size.x = PAGE_WIDTH_MIN
	for page in PAGES:
		get_node(page).rect_position.x = size.x * PAGES[page]