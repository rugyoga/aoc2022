defmodule Day18 do
    def input do
        "day18.txt"
        |> File.read!
#         """
# 2,2,2
# 1,2,2
# 3,2,2
# 2,1,2
# 2,3,2
# 2,2,1
# 2,2,3
# 2,2,4
# 2,2,6
# 1,2,5
# 3,2,5
# 2,1,5
# 2,3,5
# """
        |> String.split("\n", trim: true)

        |> Enum.map(fn line -> line |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1) |> List.to_tuple() end)
        |> Enum.reduce(
            %{}, 
            fn {x, y, z}, faces ->
                [{x+0.5, y, z}, 
                 {x-0.5, y, z}, 
                 {x, y+0.5, z}, 
                 {x, y-0.5, z}, 
                 {x, y, z+0.5}, 
                 {x, y, z-0.5}]
                 |> Enum.reduce(faces, &Map.update(&2, &1, 1, fn n -> n+1 end))
            end)
        |> Enum.flat_map(fn {face, count} -> if(count == 1, do: [face], else: []) end)
        |> MapSet.new
    end

    def part1 do
        input()
        |> Enum.count()
    end

    def interior_faces(faces, grouper, sorter) do
        faces
        |> Enum.group_by(grouper) 
        |> Enum.map(
            fn {_, xyzs} ->
                xyzs
                |> Enum.sort_by(sorter) 
                |> Enum.drop(1) 
                |> Enum.drop(-1) 
            end)
        |> List.flatten()
        |> MapSet.new()
    end
    
    def part2 do
        faces = input()
        faces
        |> MapSet.difference(interior_faces(faces, fn {x,y,_} -> {x,y} end, fn {_,_,z} -> z end))
        |> MapSet.difference(interior_faces(faces, fn {x,_,z} -> {x,z} end, fn {_,y,_} -> y end))
        |> MapSet.difference(interior_faces(faces, fn {_,y,z} -> {y,z} end, fn {x,_,_} -> x end))
        |> Enum.count()
    end
end

Day18.part1() |> IO.inspect(label: "part1")
Day18.part2() |> IO.inspect(label: "part2", limit: :infinity)