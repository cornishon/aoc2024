package aoc2024

import math "core:math"
import "core:slice"
import "core:strings"


day7_part1 :: proc(input: string) -> (result: int) {
	return do_part(input, false)
}

day7_part2 :: proc(input: string) -> (result: int) {
	return do_part(input, true)
}

do_part :: proc(input: string, $CONCAT: bool) -> (result: int) {
	lines := strings.split_lines(strings.trim_space(input), context.temp_allocator)
	numbers := make([dynamic]int, context.temp_allocator)
	results := make([dynamic]int, context.temp_allocator)
	for line in lines {
		test_value, ok := parse_line(line, &numbers)
		assert(ok, "failed to parse the line")

		do_ops(numbers[:], &results, CONCAT)
		for r in results {
			if r == test_value {
				result += test_value
				break
			}
		}
		
		clear(&numbers)
		clear(&results)
	}
	return
}

@(private="file")
parse_line :: proc(line: string, out: ^[dynamic]int) -> (test_value: int, ok: bool) {
	s := line
	test_value = chop_int(&s) or_return
	chop_prefix(&s, ": ") or_return
	parse_ints(s, out, " ") or_return
	ok = true
	return
}

@(private="file")
do_ops_acc :: proc(x: int, xs: []int, out: ^[dynamic]int, $CONCAT: bool) {
	if len(xs) == 0 {
		append(out, x)
	} else {
		do_ops_acc(x + xs[0], xs[1:], out, CONCAT)
		do_ops_acc(x * xs[0], xs[1:], out, CONCAT)
		when CONCAT {
			n_digits := math.floor(math.log10(f64(xs[0]))) + 1
			do_ops_acc(x * int(math.pow10(n_digits)) + xs[0], xs[1:], out, CONCAT)
		}
	}
}

@(private="file")
do_ops :: proc(xs: []int, results: ^[dynamic]int, $CONCAT: bool) {
	if len(xs) != 0 {
		do_ops_acc(xs[0], xs[1:], results, CONCAT)
	}
	return
}

import "core:testing"

@(test)
test_operators :: proc(t: ^testing.T) {
	result: [dynamic]int
	defer delete(result)
	do_ops({81, 40, 37}, &result, false)
	expected := []int{81+40+37, (81+40)*37, 81*40+37, 81*40*37}
	testing.expectf(t, slice.simple_equal(result[:], expected), "expected %v == %v", result[:], expected)
}

@(test)
test_day7_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day7_part1(SAMPLE), 3749)
}

@(test)
test_day7_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, day7_part2(SAMPLE), 11387)
}

@(private="file")
SAMPLE ::
	"190: 10 19\n" +
	"3267: 81 40 27\n" +
	"83: 17 5\n" +
	"156: 15 6\n" +
	"7290: 6 8 6 15\n" +
	"161011: 16 10 13\n" +
	"192: 17 8 14\n" +
	"21037: 9 7 18 13\n" +
	"292: 11 6 16 20";
