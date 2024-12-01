package aoc2024

import "core:slice"
import "core:strconv"
import "core:strings"

day1_part1 :: proc(input: string) -> (result: int) {
	column1, column2 := parse_columns(input, context.temp_allocator)
	slice.sort(column1)
	slice.sort(column2)
	for nums in soa_zip(column1, column2) {
		result += abs(nums._0 - nums._1)
	}
	return
}

day1_part2 :: proc(input: string) -> (result: int) {
	column1, column2 := parse_columns(input, context.temp_allocator)
	slice.sort(column1)
	slice.sort(column2)
	for num in column1 {
		idx, found := slice.binary_search(column2, num)
		found or_continue
		count := 1
		for i := idx - 1; i >= 0 && column2[i] == num; i -= 1 {
			count += 1
		}
		for i := idx + 1; i < len(column2) && column2[i] == num; i += 1 {
			count += 1
		}
		result += count * num
	}
	return
}

parse_columns :: proc(input: string, allocator := context.allocator) -> ([]int, []int) {
	lines := strings.trim_space(input)
	column1 := make([dynamic]int, allocator)
	column2 := make([dynamic]int, allocator)
	for line in strings.split_lines_iterator(&lines) {
		line := line
		num1, ok1 := strings.fields_iterator(&line)
		assert(ok1)
		num2, ok2 := strings.fields_iterator(&line)
		assert(ok2)
		append(&column1, strconv.atoi(num1))
		append(&column2, strconv.atoi(num2))
	}
	return column1[:], column2[:]
}

import "core:testing"

@(test)
test_day1_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day1_part1("3   4\n4   3\n2   5\n1   3\n3   9\n3   3"), 11)
	free_all(context.temp_allocator)
}

@(test)
test_day1_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, day1_part2("3   4\n4   3\n2   5\n1   3\n3   9\n3   3"), 31)
	free_all(context.temp_allocator)
}
