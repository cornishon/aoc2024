package day11

import "core:math"
import "../utils"

main :: proc() {
    utils.solve_day(11, part1, part2)
}

part1 :: proc(input: string) -> (result: int) {
    stones: [dynamic]int
    defer delete(stones)
    assert(utils.parse_ints(input, &stones, " "), "failed to parse input")
    return count_only(stones[:], 25)
}

part2 :: proc(input: string) -> (result: int) {
    stones: [dynamic]int
    defer delete(stones)
    assert(utils.parse_ints(input, &stones, " "), "failed to parse input")
    return count_only(stones[:], 75)
}

count_only :: proc(stones: []int, iterations: int) -> (count: int) {
    count_proc :: proc(stone, iter: int, memo: ^map[[2]int]int) -> (count: int) {
        if iter <= 0 {
            return 0
        }
        if cnt, ok := memo[{stone, iter}]; ok {
            return cnt
        }

        if stone == 0 {
            count += count_proc(1, iter - 1, memo)
        } else if nd := num_digits(stone); nd & 1 == 0 {
            pow10 := int(math.pow10(f64(nd >> 1)))
            l, r := stone / pow10, stone % pow10
            count += 1
            count += count_proc(l, iter - 1, memo)
            count += count_proc(r, iter - 1, memo)
        } else {
            count += count_proc(stone * 2024, iter - 1, memo)
        }

        memo[{stone, iter}] = count
        return count
    }

    memo: map[[2]int]int
    defer delete(memo)

    for stone in stones {
        count += count_proc(stone, iterations, &memo)
    }
    return count + len(stones)
}

num_digits :: proc(n: int) -> int {
    return auto_cast math.floor(math.log10(f64(n))) + 1
}

import "core:testing"

@(test)
test_part1 :: proc(t: ^testing.T) {
    testing.expect_value(t, part1("125 17"), 55312)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    testing.expect_value(t, part2("125 17"), 65601038650482)
}
