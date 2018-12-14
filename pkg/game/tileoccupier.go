package game

type tileRect struct {
	x, y       int
	numX, numY int
}

func (tr *tileRect) minX() int {
	return tr.x - tr.numX/2
}

func (tr *tileRect) maxX() int {
	return tr.x + (tr.numX+1)/2
}

func (tr *tileRect) minY() int {
	return tr.y - tr.numY/2
}

func (tr *tileRect) maxY() int {
	return tr.y + (tr.numY+1)/2
}
