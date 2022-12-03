p = fn x ->
        if x in ?a..?z do
            (x - ?a + 1) |> IO.inspect
        else
            (x - ?A + 27) |> IO.inspect
        end
    end

"day03.txt"
|> File.read!
|> String.split("\n", trim: true)
|> Enum.map(
    fn s ->
        l = String.codepoints(s)
        n = div(Enum.count(l), 2)
        a = Enum.take(l, n) |> MapSet.new()
        b = Enum.drop(l, n) |> MapSet.new()
        MapSet.intersection(a, b) |> Enum.to_list |> List.first |> :binary.first |> then(p)
        #p.(Enum.at(c, 0))
    end
)
|> Enum.sum
|> IO.inspect
