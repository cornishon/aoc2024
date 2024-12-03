package aoc2024

import "core:strconv"
import "core:strings"

// Try to parse an integer from a prefix of the given string.
// If succesful, advance the string past the matched prefix
// 
// **Inputs**  
// - s: A mutable reference to input string. Modified only if ok == true
// - base: optional base to parse the number with
//
// **Returns**
// - ok: whether the string started with a number
// - x: value of the number, if present
chop_int :: proc(s: ^string, base := 10) -> (x: int, ok: bool) {
	n: int
	x, _ = strconv.parse_int(s^, base, &n)
	s^ = s[n:]
	return x, n != 0
}

// if `s` starts with `prefix`, advance past the match
chop_prefix :: proc(s: ^string, prefix: string) -> (ok: bool) {
	strings.has_prefix(s^, prefix) or_return
	s^ = s[len(prefix):]
	return true
}


