defmodule Day21 do
    def input do
        "day21.txt"
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
            line
            |> String.split(": ", trim: true)
            |> parse()
            end)
        |> Map.new
    end

    def op("+"), do: &Kernel.+/2
    def op("-"), do: &Kernel.-/2
    def op("/"), do: &div(&1, &2)
    def op("*"), do: &Kernel.*/2

    def parse([a, b]) do
        case String.split(b, " ", trim: true) do
        [x, op, y] -> {a, {fn env -> op(op).(eval(env, x), eval(env, y)) end, [x, y]}}
        [k]        -> {a, {fn _ -> String.to_integer(k) end, []}}
        end
    end

    def eval(monkeys, name) do
        {f, _} = monkeys[name]
        f.(monkeys)
    end

    def part1 do
        input() |> eval("root")
    end

    def part2() do
    end
end

Day21.part1() |> IO.inspect(label: "part1")
#Day21.part2() |> IO.inspect(label: "part2")
