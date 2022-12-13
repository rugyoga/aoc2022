defmodule Day12 do
    @finish_value ?E - ?a
    @start_value ?S - ?a
    def input do
        locations = "day12.txt"
            |> File.read!
            |> String.split("\n", trim: true)
            |> Enum.with_index(
                fn line, row -> 
                    line
                    |> String.to_charlist()
                    |> Enum.map(&(&1 -?a))
                    |> Enum.with_index(fn height, col -> {{col, row}, height} end)
                end)
            |> List.flatten
        start = find(locations, @start_value)
        %{ start: start,
           finish: find(locations, @finish_value),
           locations: Map.new(locations) |> Map.put(start, 0)}
    end

    def find(locations, target), do: locations |> Enum.find(locations, fn {_, h} -> h == target end) |> elem(0)

    def search(%{start: start, finish: finish, locations: locations}) do
        search(SkewHeap.push(SkewHeap.new(), {0, start}), finish, locations, MapSet.new([start]))
    end

    def search(heap, goal, locations, seen) do
        result = SkewHeap.pop(heap)
        if result == :empty do
            10_000_000
        else
            {{n, point}, heap} = result
            if point == goal do
                n
            else
                candidates = neighbours(point, locations, seen)
                heap = candidates |> Enum.reduce(heap, fn neighbour, heap -> heap |> SkewHeap.push({n+1, neighbour}) end)
                seen = MapSet.new(candidates) |> MapSet.union(seen)
                search(heap, goal, locations, seen)
            end
        end
    end

    def neighbours({x, y} = point, locations, seen) do
        h = Map.get(locations, point)
        [{x+1, y}, {x-1, y}, {x, y-1}, {x, y+1}]
        |> Enum.flat_map(
            fn p -> h_n = Map.get(locations, p)
                if h_n == @start_value or
                   (!is_nil(h_n) and h_n <= h+1 and !MapSet.member?(seen, p)) do
                   [p]
                else
                    []
                end
            end)
    end

    def candidates(t) do
        t.locations
        |> Enum.filter(fn {_, v} -> v == 0 end)
        |> Enum.map(fn {p, _} -> %{ t | start: p} end)
    end

    def part1, do: input() |> search()
    def part2, do: input() |> candidates |> Enum.map(&search/1) |> Enum.min
end

defmodule SkewHeap do
  @type heap(a) :: node(a) | nil
  @type node(a) :: {a, heap(a), heap(a)}

  @spec tree(a, heap(a), heap(a)) :: heap(a) when a: var
  def tree(x, l \\ nil, r \\ nil), do: {x, l, r}

  @spec new :: heap(term)
  def new, do: nil

  @spec union(heap(a), heap(a)) :: heap(a) when a: var
  def union(nil, t2), do: t2
  def union(t1, nil), do: t1
  def union({{p1, _} = x1, l1, r1}, {{p2, _}, _, _} = t2) when p1 <= p2, do: tree(x1, union(t2, r1), l1)
  def union(t1, {x2, l2, r2}), do: tree(x2, union(t1, r2), l2)

  @spec push(heap(a), a) :: heap(a) when a: var
  def push(heap, x), do: x |> tree |> union(heap)

  @spec pop(heap(a)) :: :empty | {a, heap(a)} when a: var
  def pop(nil), do: :empty
  def pop({x, l, r}), do: {x, union(l, r)}
end

Day12.part1() |> IO.inspect(label: "part1")
Day12.part2() |> IO.inspect(label: "part2")
