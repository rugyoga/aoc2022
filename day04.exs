defmodule Day04 do

    def input do
        "day04.txt"
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.map(fn s -> 
            s
            |> String.split(",", trim: true) 
            |> Enum.map(fn range -> range |> String.split("-", trim: true) |> Enum.map(&String.to_integer/1) end)
            end)
    end

    def solve(f), do: input() |> Enum.filter(f) |> Enum.count

    def contained?([[a, b], [c ,d]]), do: (a <= c and b >= d) or  (a >= c and b <= d)
    def overlapped?([[a, b], [c ,d]]), do: (b >= c and a <= d) or  (c >= b and a >= d)

    def part1, do: solve(&contained?/1)
    def part2, do: solve(&overlapped?/1)
end

Day04.part1 |> IO.inspect(label: "part1")
Day04.part2 |> IO.inspect(label: "part2")
