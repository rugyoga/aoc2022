defmodule Day14 do
    def input do
        "day14.txt"
        |> File.read!
        |> String.split("\n", trim: true)
        |> Enum.map(fn line -> 
                        line 
                        |> String.split(" -> ", trim: true) 
                        |> Enum.map(fn pair -> pair |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1) end)
                        end)
        |> build_blocks(MapSet.new())
    end

    def build_blocks(lines, blocks) do
        lines
        |> Enum.reduce(
            blocks, 
            fn line, blocks ->
                line 
                |> Enum.chunk_every(2, 1, :discard)
                |> Enum.reduce(
                    blocks,
                    fn [[x1, y1], [x2, y2]], blocks ->
                        if x1 == x2 do
                            y1..y2 |> Enum.reduce(blocks, fn y, blocks -> MapSet.put(blocks, {x1, y}) end)
                        else
                            x1..x2 |> Enum.reduce(blocks, fn x, blocks -> MapSet.put(blocks, {x, y1}) end)
                        end
                    end)
            end)
    end

    def drop_all_sand(blocks) do
        {_, y_max} = Enum.max_by(blocks, fn {_, y} -> y end)
        blocks
        |> Stream.iterate(&drop_sand(&1, {500, 0}, y_max))
    end

    def create_floor(blocks) do
        {{x_min, _}, {x_max, _}} = Enum.min_max_by(blocks, fn {x, _} -> x end)
        {_, y_max} = Enum.max_by(blocks, fn {_, y} -> y end)
        x_min-y_max..x_max+y_max
        |> Enum.reduce(blocks, &MapSet.put(&2, {&1, y_max+2}))
    end

    def drop_sand(blocks, {x, y}, y_max) do
        #IO.inspect({x, y}, label: "drop_sand")
        cond do
        y > y_max+2 -> blocks
        MapSet.member?(blocks, {x, y}) ->
                cond do
                !MapSet.member?(blocks, {x-1, y}) -> drop_sand(blocks, {x-1, y}, y_max) 
                !MapSet.member?(blocks, {x+1, y}) -> drop_sand(blocks, {x+1, y}, y_max)
                true -> MapSet.put(blocks, {x, y-1})
                end
        true -> drop_sand(blocks, {x, y+1}, y_max)
        end
    end

    def part1 do
        input() 
        |> drop_all_sand() 
        |> Stream.chunk_every(2, 1, :discard) 
        |> Enum.take_while(fn [a, b] -> Enum.count(b) > Enum.count(a) end)
        |> Enum.count()
    end

    def part2 do        
        input() 
        |> create_floor()
        |> drop_all_sand()
        |> Enum.take_while(fn blocks -> !Enum.member?(blocks,{500, 0}) end) 
        |> Enum.count()
    end
end

Day14.part1() |> IO.inspect(label: "part1")
Day14.part2() |> IO.inspect(label: "part2")