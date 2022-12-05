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
|> Enum.filter(fn [[a, b], [c ,d]] -> (a <= c and b >= d) or  (a >= c and b <= d) end)
|> Enum.count
|> IO.inspect
