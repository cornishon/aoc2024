package day12

import ba "core:container/bit_array"
import "core:strings"
import "../utils"

main :: proc() {
	utils.solve_day(12, part1, part2)
}

part1 :: proc(input: string) -> (result: int) {
	return do_part(input, region_area_perimeter)
}

part2 :: proc(input: string) -> (result: int) {
	return do_part(input, region_area_sides)
}

do_part :: proc(input: string, measure: proc(^Region, Grid) -> (int, int)) -> (result: int) {
	grid := parse_grid(input)
	defer delete(grid.values)

	visited: ba.Bit_Array
	ba.init(&visited, len(grid.values))
	defer ba.destroy(&visited)
	r: Region
	ba.init(&r, len(grid.values))
	defer ba.destroy(&r)

	for _, i in grid.values {
		if ba.get(&visited, i) {
			continue
		}
		region(grid, i, &r)
		for &word in soa_zip(v=visited.bits[:], r=r.bits[:]) {
			word.v |= word.r
		}
		a, s := measure(&r, grid)
		result += a * s
	}
	return
}

Grid :: struct {
	width, height: int,
	values: []u8,
}

parse_grid :: proc(s: string, allocator := context.allocator) -> (grid: Grid) {
	lines := strings.split_lines(s, allocator)
	defer delete(lines, allocator)

	assert(len(lines) != 0, "grid can't be empty")
	grid.height = len(lines)
	grid.width = len(lines[0])
	for line in lines[1:] {
		assert(len(line) == grid.width, "all rows must be the same length")
	}

	grid.values = make([]u8, grid.width * grid.height, allocator)

	for line, y in lines {
		row_offset := y * grid.width
		for x in 0 ..< grid.width {
			grid.values[row_offset + x] = line[x]
		}
	}
	
	return grid
}

Region :: ba.Bit_Array

Direction :: enum {
	North,
	East,
	South,
	West,
}

neighbors :: proc(grid: Grid, v: int) -> [Direction]int {
	return {
		.East = v + 1 if (v + 1) % grid.width != 0 else -1,
		.West = v - 1 if v % grid.width != 0 else -1,
		.South = v + grid.width,
		.North = v - grid.width,
	}
}

region :: proc(grid: Grid, start: int, r: ^Region, allocator := context.allocator) {
	ba.clear(r)
	size := len(grid.values)
	stack := make([dynamic]int, 1, 16, allocator)
	stack[0] = start
	defer delete(stack)

	for len(stack) != 0 {
		v := pop(&stack)
		ba.set(r, v)
		nbors := neighbors(grid, v)
		for n in nbors {
			if 0 <= n && n < size && !ba.get(r, n) && grid.values[n] == grid.values[v] {
				append(&stack, n)
			}
		}
	}
}

Corner :: enum {
	NW, NE, SW, SE,
}
CORNER_OFFSETS :: [Corner][2]int{
	.NW = {-1,-1},
	.NE = {-1, 0},
	.SW = { 0,-1},
	.SE = { 0, 0},
}

region_area_sides :: proc(r: ^Region, grid: Grid) -> (area, sides: int) {
	it := ba.make_iterator(r)
	min_i, max_i := max(int), min(int)
	for i in ba.iterate_by_set(&it) {
		if i < min_i do min_i = i
		if i > max_i do max_i = i
		area += 1
	}

	w, h := grid.width, grid.height
	min_y := min_i / w
	max_y := max_i / w

	for y in min_y ..= max_y+1 {
		for x in 0 ..= w {
			corner_set: bit_set[Corner]
			for d, corner in CORNER_OFFSETS {
				cx := x + d.x
				cy := y + d.y
				if 0 <= cx && cx < w && 0 <= cy && cy < h && ba.get(r, cy*w + cx) {
					corner_set |= {corner}
				}
			}

			if corner_set == {.NW, .SE} || corner_set == {.SW, .NE} {
				sides += 2
			} else if n := card(corner_set); n == 1 || n == 3 {
				sides += 1
			}
		}
	}
	return
}

region_area_perimeter :: proc(r: ^Region, grid: Grid) -> (area, perimeter: int) {
	grid_size := len(grid.values)
	it := ba.make_iterator(r)
	for i in ba.iterate_by_set(&it) {
		area += 1
		perimeter += 4
		for n in neighbors(grid, i) {
			if 0 <= n && n < grid_size && grid.values[n] == grid.values[i] {
				perimeter -= 1
			}
		}
	}
	return
}

import "core:testing"

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE1), 140)
	testing.expect_value(t, part1(SAMPLE), 1930)
}

@(test)
test_part2_ABCDE :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE1), 80)
}
@(test)
test_part2_EX :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE2), 236)
}
@(test)
test_part2_AB :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE3), 368)
}
@(test)
test_part2_XO :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE4), 436)
}
@(test)
test_part2_big :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE), 1206)
}

SAMPLE1 ::
	"AAAA\n" +
	"BBCD\n" +
	"BBCC\n" +
	"EEEC"

SAMPLE2 ::
	"EEEEE\n" +
	"EXXXX\n" +
	"EEEEE\n" +
	"EXXXX\n" +
	"EEEEE"

SAMPLE3 ::
	"AAAAAA\n" +
	"AAABBA\n" +
	"AAABBA\n" +
	"ABBAAA\n" +
	"ABBAAA\n" +
	"AAAAAA" 

SAMPLE4 ::
	"OOOOO\n" +
	"OXOXO\n" +
	"OOOOO\n" +
	"OXOXO\n" +
	"OOOOO"

SAMPLE ::
	"RRRRIICCFF\n" +
	"RRRRIICCCF\n" +
	"VVRRRCCFFF\n" +
	"VVRCCCJFFF\n" +
	"VVVVCJJCFE\n" +
	"VVIVCCJJEE\n" +
	"VVIIICJJEE\n" +
	"MIIIIIJJEE\n" +
	"MIIISIJEEE\n" +
	"MMMISSJEEE"
