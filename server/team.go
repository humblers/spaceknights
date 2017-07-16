package main

type Team struct {
    Players map[string]*Player
    Mothership *Mothership
}

func NewTeam() *Team {
    return &Team{
        Players: make(map[string]*Player),
        Mothership: NewMothership(),
    }
}

func (team *Team) AddPlayer(id string, player *Player) {
    team.Players[id] = player
}
