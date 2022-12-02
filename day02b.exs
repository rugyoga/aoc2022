map1 = %{ "A" => :rock, 
"B" => :paper,
"C" => :scissors }

map2 = %{ "X" => :rock, 
"Y" => :paper,
"Z" => :scissors }


score = %{ rock: 1, paper: 2, scissors: 3}

result = fn {:rock, :paper} -> 6
   {:rock, :scissors} -> 0
   {:rock, :rock} -> 3
   {:paper, :paper} -> 3
   {:paper, :scissors} -> 6
   {:paper, :rock} -> 0
   {:scissors, :paper} -> 0
   {:scissors, :scissors} -> 3
   {:scissors, :rock} -> 6
   end

wanted = fn {:rock, "X"} -> :scissors
   {:rock, "Y"} -> :rock
   {:rock, "Z"} -> :paper
   {:paper, "X"} -> :rock
   {:paper, "Y"} -> :paper
   {:paper, "Z"} -> :scissors
   {:scissors, "X"} -> :paper
   {:scissors, "Y"} -> :scissors
   {:scissors, "Z"} -> :rock
   end

"day02.txt"
|> File.read!
|> String.split("\n", trim: true)
|> Enum.map(
    fn s -> 
         s 
         |> String.split(" ", trim: true)
         |> then(fn [a, b] -> {map1[a], b} end)
         |> then(fn {a, b} -> x = wanted.({a, b})
                             result.({a, x})+ score[x] end)
    end)
|> Enum.sum
|> IO.inspect