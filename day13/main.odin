package day13

import "core:math/linalg"
import "core:strings"
import "../utils"

main :: proc() {
	utils.solve_day(13, part1, part2)
}

do_part :: proc(input: string, goal_adjustment := 0) -> (result: int) {
	it := input
	for s in strings.split_iterator(&it, "\n\n") {
		a, b, goal, ok := parse(s)
		assert(ok, "failed to parse input")
		goal += goal_adjustment
		
		if ca, cb, is_solution := solve(a, b, goal); is_solution {
			result += 3*ca + cb
		}
	}
	return
}

part1 :: proc(input: string) -> (result: int) {
	return do_part(input)
}

part2 :: proc(input: string) -> (result: int) {
	return do_part(input, 10000000000000)
}

parse :: proc(s: string) -> (a, b, goal: [2]int, ok: bool) {
	s := s
	utils.chop_prefix(&s, "Button A: X+") or_return
	ax := utils.chop_int(&s) or_return
	utils.chop_prefix(&s, ", Y+") or_return
	ay := utils.chop_int(&s) or_return
	utils.chop_prefix(&s, "\n") or_return

	utils.chop_prefix(&s, "Button B: X+") or_return
	bx := utils.chop_int(&s) or_return
	utils.chop_prefix(&s, ", Y+") or_return
	by := utils.chop_int(&s) or_return
	utils.chop_prefix(&s, "\n") or_return

	utils.chop_prefix(&s, "Prize: X=") or_return
	gx := utils.chop_int(&s) or_return
	utils.chop_prefix(&s, ", Y=") or_return
	gy := utils.chop_int(&s) or_return

	if s == "" {
		a = {ax, ay}
		b = {bx, by}
		goal = {gx, gy}
		ok = true
	}
	return
}

solve :: proc(a, b, goal: [2]int) -> (int, int, bool) {
	m: matrix[2,2]f64 = {f64(a.x), f64(b.x), f64(a.y), f64(b.y)}
	solution := linalg.inverse(m) * linalg.array_cast(goal, f64)
	s := linalg.array_cast(linalg.round(solution), int)
	if 0 <= s[0] && 0 <= s[1] && s[0]*a + s[1]*b == goal {
		return s[0], s[1], true
	}
	return 0, 0, false
}

import "core:testing"

@(test)
test_solve1 :: proc(t: ^testing.T) {
	a, b, ok := solve({94, 34}, {22, 67}, {8400, 5400})
	cost := 3*a + b
	testing.expect(t, ok)
	testing.expect_value(t, cost, 280)
}

@(test)
test_solve2 :: proc(t: ^testing.T) {
	a, b, ok := solve({26, 66}, {67, 21}, {12748, 12176})
	cost := 3*a + b
	testing.expect(t, !ok)
	testing.expect_value(t, cost, 0)
}

@(test)
test_solve3 :: proc(t: ^testing.T) {
	a, b, ok := solve({17, 86}, {84, 37}, {7870, 6450})
	cost := 3*a + b
	testing.expect(t, ok)
	testing.expect_value(t, cost, 200)
}

@(test)
test_solve4 :: proc(t: ^testing.T) {
	a, b, ok := solve({69, 23}, {27, 71}, {18641, 10279})
	cost := 3*a + b
	testing.expect(t, !ok)
	testing.expect_value(t, cost, 0)
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE), 480)
}

SAMPLE ::
	"Button A: X+94, Y+34\n" +
	"Button B: X+22, Y+67\n" +
	"Prize: X=8400, Y=5400\n" +
	"\n" +
	"Button A: X+26, Y+66\n" +
	"Button B: X+67, Y+21\n" +
	"Prize: X=12748, Y=12176\n" +
	"\n" +
	"Button A: X+17, Y+86\n" +
	"Button B: X+84, Y+37\n" +
	"Prize: X=7870, Y=6450\n" +
	"\n" +
	"Button A: X+69, Y+23\n" +
	"Button B: X+27, Y+71\n" +
	"Prize: X=18641, Y=10279"

