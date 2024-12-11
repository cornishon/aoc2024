package day4

import "core:strings"
import "../utils"

main :: proc() {
	utils.solve_day(4, part1, part2)
}

part1 :: proc(input: string) -> (result: int) {
	p := strings.split_lines(input, context.temp_allocator)
	if len(p) == 0 { return 0}
	if len(p[0]) == 0 { return 0}
	for row in 0 ..< len(p) {
		for col in 0 ..< len(p[0]) {
			result += xmas_at(p, row, col)
		}
	}
	return
}

xmas_at :: proc(puzzle: []string, row: int, col: int) -> (count: int) {
	// #no_bounds_check improves the performance by about 350% here
	check :: proc(puzzle: []string, x: int, dxs: [3]int, y: int, dys: [3]int) -> bool #no_bounds_check {
		return puzzle[y][x] == 'X' &&
			0 <= y+dys[2] && y+dys[2] < len(puzzle) &&
			0 <= x+dxs[2] && x+dxs[2] < len(puzzle[0]) &&
			puzzle[y+dys[0]][x+dxs[0]] == 'M' &&
			puzzle[y+dys[1]][x+dxs[1]] == 'A' &&
			puzzle[y+dys[2]][x+dxs[2]] == 'S'
	}

	count += int(check(puzzle, col, { 1,  2,  3}, row, { 0,  0,  0}))
	count += int(check(puzzle, col, {-1, -2, -3}, row, { 0,  0,  0}))
	count += int(check(puzzle, col, { 0,  0,  0}, row, { 1,  2,  3}))
	count += int(check(puzzle, col, { 0,  0,  0}, row, {-1, -2, -3}))
	count += int(check(puzzle, col, { 1,  2,  3}, row, { 1,  2,  3}))
	count += int(check(puzzle, col, { 1,  2,  3}, row, {-1, -2, -3}))
	count += int(check(puzzle, col, {-1, -2, -3}, row, {-1, -2, -3}))
	count += int(check(puzzle, col, {-1, -2, -3}, row, { 1,  2,  3}))

	return
}

part2 :: proc(input: string) -> (result: int) {
	p := strings.split_lines(input, context.temp_allocator)
	if len(p) < 3 { return 0 }
	if len(p[0]) < 3 { return 0 }
	for y in 1 ..< len(p) - 1 {
	    #no_bounds_check for x in 1 ..< len(p[0]) - 1 {
			(p[y][x] == 'A') or_continue
			if (p[y-1][x-1] == 'M' && p[y+1][x+1] == 'S' || p[y-1][x-1] == 'S' && p[y+1][x+1] == 'M') &&
			   (p[y-1][x+1] == 'M' && p[y+1][x-1] == 'S' || p[y-1][x+1] == 'S' && p[y+1][x-1] == 'M')
			{
				result += 1
			}
		}
	}
	return
}

import "core:testing"

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t,
		part1(
			"MMMSXXMASM\n" +
			"MSAMXMSMSA\n" +
			"AMXSXMAAMM\n" +
			"MSAMASMSMX\n" +
			"XMASAMXAMM\n" +
			"XXAMMXXAMA\n" +
			"SMSMSASXSS\n" +
			"SAXAMASAAA\n" +
			"MAMMMXMMMM\n" +
			"MXMXAXMASX",
		),
		18
	)
	free_all(context.temp_allocator)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t,
		part2(
			"MMMSXXMASM\n" +
			"MSAMXMSMSA\n" +
			"AMXSXMAAMM\n" +
			"MSAMASMSMX\n" +
			"XMASAMXAMM\n" +
			"XXAMMXXAMA\n" +
			"SMSMSASXSS\n" +
			"SAXAMASAAA\n" +
			"MAMMMXMMMM\n" +
			"MXMXAXMASX",
		),
		9
	)
	free_all(context.temp_allocator)
}
