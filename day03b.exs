p = fn x ->
        if x in ?a..?z do
            (x - ?a + 1)
        else
            (x - ?A + 27)
        end
    end

"day03.txt"
|> File.read!
|> String.split("\n", trim: true)
|> Enum.chunk_every(3)
|> Enum.map(
    fn as ->
        [x, y, z] = as |> Enum.map(&String.codepoints/1)
        MapSet.intersection(MapSet.new(x), MapSet.new(y)) 
            |>  MapSet.intersection( MapSet.new(z))
            |> Enum.to_list
            |> List.first
            |> :binary.first 
            |> then(p)
    end
)
|> Enum.sum
|> IO.inspect