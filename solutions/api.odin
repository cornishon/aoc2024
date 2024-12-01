package aoc2024

import "core:fmt"
import "core:time"

Solution :: union {
	proc(input: string) -> int,
	proc(input: string) -> string,
}

@(private)
table: [25][2]Solution

@(init, private)
day1 :: proc() {
	// table[0] = {day1_part1, day1_part2}
	// table[1] = {day2_part1, day2_part2}
	// table[2] = {day3_part1, day3_part2}
	// table[3] = {day4_part1, day4_part2}
	// table[4] = {day5_part1, day5_part2}
	// table[5] = {day6_part1, day6_part2}
	// table[6] = {day7_part1, day7_part2}
	// table[7] = {day8_part1, day8_part2}
	// table[8] = {day9_part1, day9_part2}
	// table[9] = {day10_part1, day10_part2}
	// table[10] = {day11_part1, day11_part2}
	// table[11] = {day12_part1, day12_part2}
	// table[12] = {day13_part1, day13_part2}
	// table[13] = {day14_part1, day14_part2}
	// table[14] = {day15_part1, day15_part2}
	// table[15] = {day16_part1, day16_part2}
	// table[16] = {day17_part1, day17_part2}
	// table[17] = {day18_part1, day18_part2}
	// table[18] = {day19_part1, day19_part2}
	// table[19] = {day20_part1, day20_part2}
	// table[20] = {day21_part1, day21_part2}
	// table[21] = {day22_part1, day22_part2}
	// table[22] = {day23_part1, day23_part2}
	// table[23] = {day24_part1, day24_part2}
	// table[24] = {day25_part1, day25_part2}
}

solve :: proc(day: int, part: int, input: string) -> (elapsed: time.Duration) {
	switch solve in table[day - 1][part - 1] {
		case proc(input: string) -> int:
			t := time.tick_now()
			result := solve(input)
			elapsed = time.tick_since(t)
			fmt.printfln("Part %v: %v (took %v)", part, result, elapsed)
			free_all(context.temp_allocator)
		case proc(input: string) -> string:
			t := time.tick_now()
			result := solve(input)
			elapsed = time.tick_since(t)
			fmt.printfln("Part %v: %v (took %v)", part, result, elapsed)
			free_all(context.temp_allocator)
		case nil:
			fmt.printfln("Part %v is not implemented yet", part)
	}
	return
}
