defmodule Day01 do
    def input do
        "day01.txt"
        |> File.read!
        |> String.split("\n\n", trim: true)
        |> Enum.map(fn s -> s |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1) |> Enum.sum() end)
    end

    def part1, do: input() |> Enum.max
    def part2, do: input() |> Enum.sort(:desc) |> Enum.take(3) |> Enum.sum
end

Day01.part1() |> IO.inspect(label: "part1")
Day01.part2() |> IO.inspect(label: "part2")