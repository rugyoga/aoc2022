Code.require_file("rps.ex")

"day02.txt" |> RPS.input |> Enum.map(&RPS.part2/1) |> Enum.sum |> IO.inspect