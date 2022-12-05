"day04.txt"
|> File.read!
|> String.split("\n", trim: true)
|> Enum.map(fn s -> 
    s
    |> String.split(",", trim: true) 
    |> Enum.map(
        fn s ->
            s 
            |> String.split("-", trim: true)
            |> Enum.map(&String.to_integer/1)
        end
    )
    end)
|> IO.inspect
|> Enum.filter(fn [[a, b], [c ,d]] -> (b >= c and a <= d) or  (c >= b and a >= d) end)
|> Enum.count
|> IO.inspect
