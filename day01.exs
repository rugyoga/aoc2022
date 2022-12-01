"day01.txt"
|> File.read!
|> String.split("\n\n", trim: true)
|> Enum.map(fn s -> s |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1) |> Enum.sum() end)
|> Enum.max
|> IO.inspect
