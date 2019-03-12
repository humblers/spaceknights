package token

import (
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"golang.org/x/crypto/blake2b"
)

const validDuration = 10 * time.Minute

var key []byte = []byte("7E7A4A754292AC2BBF1FCEC4C8DDE")

var ErrExpired = errors.New("token expired")
var ErrInvalid = errors.New("token invalid")

func NewToken(uid string) (string, int64) {
	hash, err := blake2b.New256(key)
	if err != nil {
		panic(err)
	}
	issuedAt := time.Now().Unix()
	b := []byte(fmt.Sprintf("%v%v", issuedAt, uid))
	return hex.EncodeToString(hash.Sum(b)), issuedAt
}

func VerifyToken(uid, token string, issuedAt int64) error {
	if time.Now().After(time.Unix(issuedAt, 0).Add(validDuration)) {
		return ErrExpired
	}
	hash, err := blake2b.New256(key)
	if err != nil {
		panic(err)
	}
	b := []byte(fmt.Sprintf("%v%v", issuedAt, uid))
	if token != hex.EncodeToString(hash.Sum(b)) {
		return ErrInvalid
	}
	return nil
}
