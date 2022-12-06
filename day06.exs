defmodule Day06 do
    def input, do: "day06.txt" |> File.read! |> String.split("", trim: true)

    def count(n, message \\ input()) do
        message
        |> Enum.chunk_every(n, 1)
        |> Enum.take_while(fn items -> (Enum.count(MapSet.new(items))) != n end)
        |> Enum.count
        |> then(&(&1+n))
    end

    def part1, do: Day06.count(4)
    def part2, do: Day06.count(14)
end

Day06.part1() |> IO.inspect(label: "part1")
Day06.part2() |> IO.inspect(label: "part2")