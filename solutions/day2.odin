package aoc2024

import "core:slice"
import "core:strconv"
import "core:strings"

day2_part1 :: proc(input: string) -> (result: int) {
	lines := input
	context.allocator = context.temp_allocator
	for line in strings.split_lines_iterator(&lines) {
		levels := slice.mapper(strings.fields(line), strconv.atoi)
		if is_safe(levels) { result += 1 }
	}
	return
}

day2_part2 :: proc(input: string) -> (result: int) {
	lines := input
	context.allocator = context.temp_allocator
	for line in strings.split_lines_iterator(&lines) {
		levels := slice.mapper(strings.fields(line), strconv.atoi)
		if is_safe_adjusted(levels) { result += 1 }
	}
	return
}

bad_incr_idx :: proc(levels: []int) -> int {
	for i in 1 ..< len(levels) {
		if d := levels[i] - levels[i - 1]; !(1 <= d && d <= 3) {
			return i
		}
	}
	return -1
}

bad_decr_idx :: proc(levels: [] int) -> int {
	for i in 1 ..< len(levels) {
		if d := levels[i - 1] - levels[i]; !(1 <= d && d <= 3) {
			return i
		}
	}
	return -1
}

is_safe :: proc(levels: []int) -> bool {
	 return bad_incr_idx(levels) == -1 || bad_decr_idx(levels) == -1
}

is_safe_adjusted :: proc(levels: []int) -> bool {
	if a := bad_incr_idx(levels); a == -1 {
		return true
	} else if a == 1 && is_safe(levels[1:]) {
		return true
	} else {
		ls := slice.clone(levels, context.temp_allocator)
		for i in a ..< len(ls) - 1 {
			ls[i] = ls[i + 1]
		}
		if is_safe(ls[:len(ls) - 1]) {
			return true
		}
	}
	if a := bad_decr_idx(levels); a == -1 {
		return true
	} else if a == 1 && is_safe(levels[1:]) {
		return true
	} else {
		ls := levels
		for i in a ..< len(ls) - 1 {
			ls[i] = ls[i + 1]
		}
		if is_safe(ls[:len(ls) - 1]) {
			return true
		}
	}
	return false
}

import "core:testing"

@(test)
test_is_safe :: proc(t: ^testing.T) {
	testing.expect_value(t, is_safe({7, 6, 4, 2, 1}), true)
	testing.expect_value(t, is_safe({1, 2, 7, 8, 9}), false)
	testing.expect_value(t, is_safe({9, 7, 6, 2, 1}), false)
	testing.expect_value(t, is_safe({1, 3, 2, 4, 5}), false)
	testing.expect_value(t, is_safe({8, 6, 4, 4, 1}), false)
	testing.expect_value(t, is_safe({1, 3, 6, 7, 9}), true)
	testing.expect_value(t, is_safe({2, 1, 2, 3, 4}), false)
	free_all(context.temp_allocator)
}

@(test)
test_is_safe_adjusted :: proc(t: ^testing.T) {
	testing.expect_value(t, is_safe_adjusted({7, 6, 4, 2, 1}), true)
	testing.expect_value(t, is_safe_adjusted({1, 2, 7, 8, 9}), false)
	testing.expect_value(t, is_safe_adjusted({9, 7, 6, 2, 1}), false)
	testing.expect_value(t, is_safe_adjusted({1, 3, 2, 4, 5}), true)
	testing.expect_value(t, is_safe_adjusted({8, 6, 4, 4, 1}), true)
	testing.expect_value(t, is_safe_adjusted({1, 3, 6, 7, 9}), true)
	testing.expect_value(t, is_safe_adjusted({2, 1, 2, 3, 4}), true)
	free_all(context.temp_allocator)
}

@(test)
test_day2_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day2_part1(
		"7 6 4 2 1\n" +
		"1 2 7 8 9\n" +
		"9 7 6 2 1\n" +
		"1 3 2 4 5\n" +
		"8 6 4 4 1\n" +
		"1 3 6 7 9"),
		2)
	free_all(context.temp_allocator)
}

@(test)
test_day2_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, day2_part2(
		"7 6 4 2 1\n" +
		"1 2 7 8 9\n" +
		"9 7 6 2 1\n" +
		"1 3 2 4 5\n" +
		"8 6 4 4 1\n" +
		"1 3 6 7 9"),
		4)
	free_all(context.temp_allocator)
}

