defmodule Day03 do
    def encode(x), do: if(x in ?a..?z, do: x - ?a + 1, else: x - ?A + 27)

    def input, do: "day03.txt" |> File.read! |> String.split("\n", trim: true)

    def part1 do
        input()
        |> Enum.map(
            fn s ->
                l = s |> to_charlist()
                {a, b} = Enum.split(l, div(Enum.count(l), 2))
                MapSet.intersection(MapSet.new(a), MapSet.new(b))
                |> Enum.at(0)
                |> encode()
            end
        )
        |> Enum.sum
    end

    def part2 do
        input()
        |> Enum.chunk_every(3)
        |> Enum.map(
            fn as ->
                as 
                |> Enum.map(&(&1 |> to_charlist() |> MapSet.new()))
                |> Enum.reduce(&MapSet.intersection/2)
                |> Enum.at(0)
                |> encode()
            end
        )
        |> Enum.sum
    end
end
        
Day03.part1() |> IO.inspect(label: "part1")
Day03.part2() |> IO.inspect(label: "part2")
