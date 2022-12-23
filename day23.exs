defmodule Day23 do
    def input do
        "day23.txt"
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.with_index(1)
        |> Enum.map(&parse_row/1)
        |> List.flatten()
        |> Enum.flat_map(fn {p, t} -> if(t == "#", do: [p], else: []) end)
        |> MapSet.new()
    end

    @cycle [~w(N NW NE)a, ~w(S SW SE)a, ~w(W SW NW)a, ~w(E SE NE)a]

    @directions %{N: {0, -1}, NE: {1, -1}, NW: {-1, -1},
                  S: {0, 1}, SW: {-1, 1}, SE: {1, 1},
                  W: {-1, 0}, E: {1, 0}}

    def parse_row({row, r}) do
        row
        |> String.split("", trim: true) 
        |> Enum.with_index(fn ch, c -> {{c+1, r}, ch} end)
    end

    def empty?(elves, elf), do: !MapSet.member?(elves, elf)

    def stationary?(elves, {a, b}) do
        Enum.all?(@directions, fn {_, {x, y}} -> empty?(elves, {a+x,b+y}) end)
    end

    def simulate(elves, order, n, i) when i == n, do: elves
    def simulate(elves, order, n, i) do
        {_, moving} = elves |> Enum.split_with(&stationary?(elves, &1))
        if Enum.empty?(moving) do
            i+1
        else
            moving
            |> Enum.map(&pick_direction(&1, order, elves))
            |> Enum.reject(&is_nil(&1))
            |> Enum.group_by(&elem(&1, 0))
            |> Enum.filter(fn {_to, froms} -> Enum.count(froms) == 1 end)
            |> Enum.reduce(
                elves,
                fn {to, [{_, from}]}, elves ->
                    elves |> MapSet.delete(from) |> MapSet.put(to)
                end)
            |> simulate(rotate(order), n, i+1)
        end
    end

    def rotate([a | b]), do: b ++ [a]

    def all_free?(dirs, pos, elves) do
        Enum.all?(dirs, fn dir -> !MapSet.member?(elves, move(dir, pos)) end)
    end

    def move(dir, {c, r}) do
        {cd, rd} = @directions[dir]
        {c+cd, r+rd}
    end

    def pick_direction(pos, dirs_list, elves) do
        results = Enum.filter(dirs_list, &all_free?(&1, pos, elves))
        case results do
        [[dir | _] | _] -> {move(dir, pos), pos}
        _ -> nil
        end
    end

    def compute(elves) do
        {{min_x, _}, {max_x, _}} = Enum.min_max_by(elves, fn {x, _} -> x end) |> IO.inspect(label: "xs")
        {{_, min_y}, {_, max_y}} = Enum.min_max_by(elves, fn {_, y} -> y end) |> IO.inspect(label: "ys")

        (1+max_x-min_x)*(1+max_y-min_y) - Enum.count(elves)
    end

    def show(elves) do
        {x_max, _} = Enum.max_by(elves, &elem(&1, 0))
        {_, y_max} = Enum.max_by(elves, &elem(&1, 1))
        for y <- 1..y_max do
            for x <- 1..x_max do
                if MapSet.member?(elves, {x, y}) do
                    "#"
                else
                    "."
                end
            end |> Enum.join("")
        end |> Enum.join("\n")
    end

    def part1 do
        input() |> simulate(@cycle, 20, 0) |> compute() #|> show() |> IO.puts()
    end

    def part2 do
        input() |> simulate(@cycle, nil, 0)
    end
end

Day23.part1 |> IO.inspect(label: "part1")
Day23.part2 |> IO.inspect(label: "part2")