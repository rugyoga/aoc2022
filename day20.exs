defmodule Day20 do
    def input do
        # "day20.txt"
        # |> File.read!
"""
1
2
-3
3
-2
0
4
"""
        |> String.split("\n", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index
    end

    def process({pre_xs, _}, {post_xs, _}, i, n) when i == n do
      IO.inspect(Enum.reverse(pre_xs) ++ post_xs, label: "current(a)")
      Enum.reduce(pre_xs, post_xs, &[&1 | &2])
    end
    def process({pre_xs, pre_n}, {[{item, x} | items], post_n}, i, n) when i != x do
      IO.inspect(Enum.reverse(pre_xs) ++ [{item, x} | items], label: "current(b)")
      process({[{item, x} | pre_xs], pre_n+1}, {items, post_n-1}, i, n)
    end
    def process({pre_xs, pre_n} = pre, {[{item, x} | items], post_n}, i, n) when i == x do
      IO.inspect(pre_n, label: "pre_n")
      IO.inspect(item, label: "item")
      IO.inspect(post_n, label: "post_n")
      # IO.inspect(Enum.reverse(pre_xs) ++ [{item, x} | items], label: "current(c)")
      if item < 0 do
        item_abs = abs(item)
        if item_abs > pre_n do
          p = post_n - (item_abs - pre_n)
          {pre_items, post_items} = Enum.split(items, p)   
          process(pre, {pre_items ++ [item | post_items], post_n}, i, n)
        else
          {pre_item, post_item} = Enum.split(pre_xs, item_abs)
          process({pre_item ++ [item | post_item], pre_n+1}, {items, post_n-1}, i+1, n)
        end
      else
        if item > post_n do
          p = pre_n - (item - post_n)
          {pre_item, post_item} = Enum.split(pre_xs, p)   
          process({pre_item ++ [item | post_item], pre_n+1}, {items, post_n-1}, i, n)
        else
          {pre_item, post_item} = Enum.split(items, item)   
          process(pre, {pre_item ++ [item | post_item], post_n}, i+1, n)
        end
      end
    end

    def process({pre_xs, pre_n}, {[item | items], post_n}, i, n) do
      IO.inspect(Enum.reverse(pre_xs), label: "pre_xs(d)")
      IO.inspect(item, label: "item(d)")
      IO.inspect(items, label: "items(d)")
      process({[item | pre_xs], pre_n+1}, {items, post_n-1}, i, n)
    end

    def part1 do
      original = input()
      n = Enum.count(original)
      process({[], 0}, {original, n}, 0, n)
    end

    def part2 do
        input()
    end
end


Day20.part1() |> IO.inspect(label: "part1")
#Day20.part2() |> IO.inspect(label: "part2", limit: :infinity)