defmodule RPS do
    @map1 %{ "A" => :rock, "B" => :paper, "C" => :scissors }
    @map2 %{ "X" => :rock, "Y" => :paper, "Z" => :scissors }
    @score %{ rock: 1, paper: 2, scissors: 3}

    def map1(x), do: @map1[x]
    def map2(x), do: @map2[x]
    def score(x), do: @score[x]

    def result(:rock, :paper), do: 6
    def result(:rock, :scissors), do: 0
    def result(:rock, :rock), do: 3
    def result(:paper, :paper), do: 3
    def result(:paper, :scissors), do: 6
    def result(:paper, :rock), do: 0
    def result(:scissors, :paper), do:  0
    def result(:scissors, :scissors), do: 3
    def result(:scissors, :rock), do: 6

    def wanted(:rock, "X"), do: :scissors
    def wanted(:rock, "Y"), do:  :rock
    def wanted(:rock, "Z"), do:  :paper
    def wanted(:paper, "X"), do:  :rock
    def wanted(:paper, "Y"), do:  :paper
    def wanted(:paper, "Z"), do:  :scissors
    def wanted(:scissors, "X"), do:  :paper
    def wanted(:scissors, "Y"), do: :scissors
    def wanted(:scissors, "Z"), do:  :rock

    def input(f) do
        f
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, " ", trim: true))
    end

    def part1([a, b]) do
        x = map1(a)
        y = map2(b)
        result(x, y) + score(y)
    end

    def part2([a, b]) do
        x = map1(a)
        y = wanted(x, b)
        result(x, y)+ score(y)
    end
end