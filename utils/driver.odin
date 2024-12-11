package utils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:sys/posix"
import "core:time"

Args :: struct {
	part:       int    `args:"" usage:"Part (1 or 2), leave unset to run both"`,
	session:    string `args:"" usage:"custom cookie for authentication for automatic input download"`,
	input_path: string `args:"pos=0" usage:"use given file as input, if not given, input will be automatically downloaded"`,
}

arg_checker :: proc(model: rawptr, name: string, value: any, args_tag: string) -> (error: string) {
	if name == "part" {
		v := value.(int)
		if !(1 <= v && v <= 2) {
			error = "Valid part range is 1 ..= 2"
		}
	}
	return
}

Solution_Proc :: #type proc(string) -> int

solve_part :: proc(part_idx: int, input: string, part: Solution_Proc) -> time.Duration {
	if part == nil {
		fmt.printfln("Part %v: (not implemented)", part_idx)
		return 0
	}
	t := time.tick_now()
	result := part(input)
	elapsed := time.tick_since(t)
	fmt.printfln("Part %v: %v (took %v)", part_idx, result, elapsed)
	return elapsed
}

solve_day :: proc(day: int, part1, part2: Solution_Proc) {
	defer free_all(context.temp_allocator)
	flags.register_flag_checker(arg_checker)
	args := Args{}
	flags.parse_or_exit(&args, os.args)
	should_download := args.input_path == ""
	if should_download do args.input_path = "input.txt"
	if should_download && !os.exists(args.input_path) {
		if args.session == "" {
			session, ok := os.read_entire_file("../aoc.session")
			if ok {
				args.session = string(session)
			}
		}
		if args.session == "" {
			fmt.eprintln(
				"Error: To download the input you must specify a session cookie in 'aoc.session' file or through the '-session' flag",
			)
			fmt.eprintfln("Or just download the file manually and save int in %v", args.input_path)
			os.exit(1)
		}

		child_pid := posix.fork()
		switch child_pid {
		case -1:
			// `fork` failed.
			panic("fork failed")

		case 0:
			// This is the child.
			fmt.eprintln("Downloading input...")
			err := os.execvp(
				"curl",
				{
					fmt.tprintf("https://adventofcode.com/2024/day/%v/input", day),
					"--cookie",
					fmt.tprintf("session=%v", args.session),
					"-o",
					args.input_path,
				},
			)
			if err != nil {
				fmt.eprintln("Error downloading input:", err)
				os.exit(1)
			}

		case:
			status: i32
			for {
				wpid := posix.waitpid(child_pid, &status, {.UNTRACED, .CONTINUED})
				if wpid == -1 {
					panic("waitpid failure")
				}

				switch {
				case posix.WIFEXITED(status):
					fmt.printfln("child exited, status=%v", posix.WEXITSTATUS(status))
				case posix.WIFSIGNALED(status):
					fmt.printfln("child killed (signal %v)", posix.WTERMSIG(status))
				case posix.WIFSTOPPED(status):
					fmt.printfln("child stopped (signal %v", posix.WSTOPSIG(status))
				case posix.WIFCONTINUED(status):
					fmt.println("child continued")
				case:
					// Should never happen.
					fmt.println("unexpected status (%x)", status)
				}

				if posix.WIFEXITED(status) || posix.WIFSIGNALED(status) {
					break
				}
			}
		}
	}

	input_bytes, err := os.read_entire_file_or_err(args.input_path)
	if err != nil {
		fmt.eprintfln("Error reading input file %v: %v", args.input_path, err)
		os.exit(1)
	}

	input := string(input_bytes)
	if input[len(input) - 1] == '\n' {
		input = input[:len(input) - 1]
	}

	fmt.println()

	switch args.part {
	case 0:
		dur1 := solve_part(1, input, part1)
		dur2 := solve_part(2, input, part2)
		fmt.printfln("Day % 2v total time: %v", day, dur1 + dur2)
	case 1:
		solve_part(1, input, part1)
	case 2:
		solve_part(2, input, part2)
	}

	return
}
