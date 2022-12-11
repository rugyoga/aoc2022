defmodule Day10 do
    def input do
        "day10.txt"
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.map(
            fn "noop" -> :noop
               line -> line |> String.split(" ", trim: true) |> then(fn [_, n] -> String.to_integer(n) end)
            end)
    end

    def register([], _), do: []
    def register([:noop | lines], r), do: [r | register(lines, r)]
    def register([n | lines], r), do: [r | [r | register(lines, r+n)]]

    def strength(l), do: l |> Enum.with_index(1) |> Enum.map(fn {a, b} -> a*b end)

    def strengths(l, rs), do: rs |> Enum.map(&Enum.at(l, &1-1)) |> Enum.sum

    def crt(l) do
        l
        |> Enum.with_index()
        |> Enum.map(fn {s, i} -> if(rem(i, 40) in (s - 1)..(s + 1), do: "#", else: " ") end)
        |> Enum.chunk_every(40)
        |> Enum.map(&Enum.join(&1, ""))
        |> Enum.join("\n")
    end

    def part1, do: input() |> register(1) |> strength() |> strengths([20, 60, 100, 140, 180, 220])
    def part2, do: input() |> register(1) |> crt()
end

Day10.part1() |> IO.inspect(label: "part1")
Day10.part2() |> IO.puts