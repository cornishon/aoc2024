package day3

import "core:strings"
import "../utils"

main :: proc() {
	utils.solve_day(3, part1, part2)
}

part1 :: proc(input: string) -> (result: int) {
	s := input
	for advance_past_mul(&s) {
		x, y := parse_mul_args(&s) or_continue
		result += x * y
	}
	return
}

part2 :: proc(input: string) -> (result: int) {
	s := input
	mul_enabled := true
	for {
		idx, width := strings.index_multi(s, {"mul", "do()", "don't()"})
		(idx >= 0) or_break
		s = s[idx + width:]

		switch width {
		case 3:
			if mul_enabled {
				x, y := parse_mul_args(&s) or_continue
				result += x * y
			}
		case 4:
			mul_enabled = true
		case 7:
			mul_enabled = false
		}
	}
	return
} 

@(private="file")
advance_past_mul :: proc(s: ^string) -> (ok: bool) {
	_, m, t := strings.partition(s^, "mul")
	if m == "mul" {
		ok = true
		s^ = t
	}
	return
}

@(private="file")
// parse a string like "(3,7)" into two numbers
parse_mul_args :: proc(s: ^string) -> (x, y: int, ok: bool) {
	t := s^

	utils.chop_prefix(&t, "(") or_return
	x = utils.chop_int(&t) or_return
	utils.chop_prefix(&t, ",") or_return
	y = utils.chop_int(&t) or_return
	utils.chop_prefix(&t, ")") or_return

	s^ = t
	ok = true
	return
}

import "core:testing"

@(test)
test_parse_args :: proc(t: ^testing.T) {
	{
		s := "(2,4)"
		x, y, ok := parse_mul_args(&s)
		testing.expect_value(t, ok, true)
		testing.expect_value(t, x, 2)
		testing.expect_value(t, y, 4)
		testing.expect_value(t, s, "")
	}
	{
		s := "(2,4]"
		x, y, ok := parse_mul_args(&s)
		testing.expect_value(t, ok, false)
		testing.expect_value(t, x, 2)
		testing.expect_value(t, y, 4)
		testing.expect_value(t, s, "(2,4]")
	}
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t,
		part1("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"),
		161,
	)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t,
		part2("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"),
		48,
	)
}
