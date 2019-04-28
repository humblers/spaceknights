package lobby

type HumblerToken struct {
	UID          string
	HumblerToken string
	IssuedAt     int64
}

type CommonResponse struct {
	ErrMessage string
}

type LoginRequest struct {
	UID           string
	HumblerToken  string
	IssuedAt      int64
	FirebaseToken string
}

type LoginResponse struct {
	ErrMessage    string
	User          *user
	UID           string
	HumblerToken  string
	IssuedAt      int64
	FirebaseToken string
}

type DataResponse struct {
	ErrMessage string
	Data       string
}

type DeckSelectRequest struct {
	Num int
}

type DeckSetRequest struct {
	Num  int
	Deck deck
}

type CardUpgradeRequest struct {
	Name string
}

type CardUpradeResponse struct {
	ErrMessage  string
	Card        card
	Galacticoin int
}

type ChestOpenRequest struct {
	Name    string
	Slot    int
	UseCash bool
}

type ChestOpenResponse struct {
	ErrMessage string
	Gold       int
	Cash       int
	Cards      map[string]int
	OpenedAt   int64
	UsedCash   int
}
