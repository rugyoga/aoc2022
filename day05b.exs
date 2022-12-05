defmodule Stack do
    def transfer([amount, from, to], stacks) do
        xs = Enum.at(stacks, from-1) |> Enum.take(amount)
        from_new = Enum.at(stacks, from-1) |> Enum.drop(amount)
        to_new = xs ++ Enum.at(stacks, to-1)
        stacks |> List.replace_at(from-1, from_new) |> List.replace_at(to-1, to_new)
    end
end

[stacks, moves] = "day05.txt" |> File.read! |> String.split("\n\n", trim: true) |> Enum.map(&String.split(&1,"\n", trim: true))

stacks =
stacks |> 
Enum.map(
    fn s -> 
        xs = String.split(s, "", trim: true) 
        Enum.map([1,5,9,13,17,21,25,29,33], &Enum.at(xs, &1))
    end) 
|> Enum.zip_with(&(&1))
|> Enum.map(fn l -> Enum.drop_while(l, &(&1 == " ")) end)

moves 
|> Enum.map(
    fn s -> 
        xs = String.split(s, " ", trim: true)
        Enum.map([1,3,5], &Enum.at(xs, &1) |> String.to_integer)
    end)
|> Enum.reduce(stacks, &Stack.transfer/2)
|> Enum.map(&List.first/1)
|> Enum.join("")
|> IO.puts