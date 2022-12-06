defmodule Day02 do
    @them %{ "A" => :rock, "B" => :paper, "C" => :scissors }
    @us %{ "X" => :rock, "Y" => :paper, "Z" => :scissors }
    @score %{ rock: 1, paper: 2, scissors: 3}

    def them(x), do: @them[x]
    def us(x), do: @us[x]
    def score(x), do: @score[x]

    def result(:rock,     :paper),    do: 6
    def result(:rock,     :scissors), do: 0
    def result(:rock,     :rock),     do: 3
    def result(:paper,    :paper),    do: 3
    def result(:paper,    :scissors), do: 6
    def result(:paper,    :rock),     do: 0
    def result(:scissors, :paper),    do: 0
    def result(:scissors, :scissors), do: 3
    def result(:scissors, :rock),     do: 6

    def wanted(:rock, "X"), do: :scissors
    def wanted(:rock, "Y"), do: :rock
    def wanted(:rock, "Z"), do: :paper
    def wanted(:paper, "X"), do: :rock
    def wanted(:paper, "Y"), do: :paper
    def wanted(:paper, "Z"), do: :scissors
    def wanted(:scissors, "X"), do: :paper
    def wanted(:scissors, "Y"), do: :scissors
    def wanted(:scissors, "Z"), do: :rock

    def input() do
        "day02.txt"
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, " ", trim: true))
    end

    def standard([a, b]) do
        x = them(a)
        y = us(b)
        result(x, y) + score(y)
    end

    def to_order([a, b]) do
        x = them(a)
        y = wanted(x, b)
        result(x, y) + score(y)
    end

    def part1, do: input() |> Enum.map(&standard/1) |> Enum.sum
    def part2, do: input() |> Enum.map(&to_order/1) |> Enum.sum
end

Day02.part1() |> IO.inspect(label: "part1")
Day02.part2() |> IO.inspect(label: "part2")