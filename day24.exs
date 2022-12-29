Code.require_file("priority_queue.ex")

defmodule Day24 do

def input do
    "day24.txt"
    |> File.read!
end

def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index(-1)
    |> Enum.map(&parse_line/1)
    |> List.flatten()
    |> Map.new()
end

def parse_line({line, r}) do
    line 
    |> String.split("", trim: true) 
    |> Enum.with_index(fn item, c -> {{c-1, r}, [item]} end)
    |> Enum.reject(fn {_, [item]} -> item == "." or item == "#" end)
end

@w 120
@h 25
@start {0, -1}
@finish {@w-1, @h}

def search({heap, seen}, blizzard_cache, goal) do
    {candidate, new_heap} = PriorityQueue.pop(heap)
    {{n, _}, {point, path}} = candidate
    #IO.inspect(candidate, label: "point")
    if point == goal do
        path
    else
        {blizzard, blizzard_cache} = blizzard_get(blizzard_cache, n+1)
        gen_moves(point, blizzard, seen)
        |> add_moves(n, new_heap, seen, path)
        |> search(blizzard_cache, goal)
    end
end

def add_moves(points, n, heap, seen, path) do
    Enum.reduce(
        points,
        {heap, seen},
        fn point, {heap, seen} ->
            {PriorityQueue.push(heap, {{n+1, manhattan(point, @finish)}, {point, [point|path]}}),
            MapSet.put(seen, point)}
        end)
end

def within?({x, y} = p), do: (0 <= x and x < @w and 0 <= y and y < @h) or p in [@start, @finish]

def gen_moves({x, y}, blizzard, seen) do
    [{x+1, y}, {x-1, y}, {x, y-1}, {x, y+1}]
    |> Enum.reject(fn p -> !within?(p) or Map.has_key?(blizzard, p) or MapSet.member?(seen, p) end)
    |> then(&if(! Map.has_key?(blizzard, {x, y}), do: &1 ++ [{x, y}], else: &1))
end

def blizzard_generate(previous, w \\ @w, h \\ @h) do
    Enum.reduce(
        previous,
        %{},
        fn {p, items}, new_blizzard ->
            Enum.reduce(
                items,
                new_blizzard,
                fn item, new_blizzard ->
                    Map.update(new_blizzard, move({p, item}, w, h), [item], &([item | &1]))
                end)
        end
    )
end

def move({{x, y}, ">"}, w, _), do: {rem(x+1, w), y}
def move({{x, y}, "<"}, w, _), do: {rem(w+x-1, w), y}
def move({{x, y}, "^"}, _, h), do: {x, rem(h+y-1, h)}
def move({{x, y}, "v"}, _, h), do: {x, rem(y+1, h)}

defp blizzard_get(blizzard_cache, i) do
    if Map.has_key?(blizzard_cache, i) do
        {blizzard_cache[i], blizzard_cache}
    else
        {prev, blizzard_cache} = blizzard_get(blizzard_cache, i-1)
        current = blizzard_generate(prev)
        {current, Map.put(blizzard_cache, i, current)}
    end
end

def display(grid, highlight \\ nil) do
    {cols, rows} = Map.keys(grid) |> Enum.unzip()
    max_col = Enum.max(cols)
    max_row = Enum.max(rows)

    for row <- 0..max_row do
        for col <- 0..max_col do
            if {row, col} == highlight do
                "E"
            else
                list = Map.get(grid, {col, row}, ["."])
                if(length(list) > 1, do: "#{length(list)}", else: hd(list))
            end
        end |> Enum.join("")
    end 
    |> Enum.join("\n")
    |> IO.puts()

    grid
end

def part1() do
    blizzards = %{0 => parse(input())}
    PriorityQueue.new
    |> PriorityQueue.push({{0, manhattan(@start)}, {@start, []}})
    |> then(&{&1, MapSet.new})
    |> search(blizzards, @finish)
end

def manhattan({x, y}, {xt, yt} \\ @finish), do: abs(xt-x) + abs(yt-y)

def part2, do: []
end

defmodule Alternative do
  def part1(input) do
    {{max_row, max_col} = max_coord, _val} = Enum.max_by(input, fn {coord, _val} -> coord end)

    get_shortest_path(input, max_coord, {{1, 2}, {max_row, max_col - 1}})
    |> elem(0)
  end

  def part2(input) do
    {{max_row, max_col} = max_coord, _val} = Enum.max_by(input, fn {coord, _val} -> coord end)

    from = {1, 2}
    to = {max_row, max_col - 1}
    {lap1, blizzards} = get_shortest_path(input, max_coord, {from, to})
    {lap2, blizzards} = get_shortest_path(blizzards, max_coord, {to, from})
    {lap3, _blizzards} = get_shortest_path(blizzards, max_coord, {from, to})

    lap1 + lap2 + lap3
  end

  defp get_shortest_path(input, max_coord, {source, destination}) do
    {moves, blizzard_paths} = legal_moves({%{0 => input}, max_coord}, source, 1)

    search(
      add_to_queue(PriorityQueue.new(), {moves, 1}),
      destination,
      MapSet.new(),
      blizzard_paths
    )
  end

  defp add_to_queue(queue, {states, turn}) do
    Enum.reduce(states, queue, fn state, queue ->
      PriorityQueue.push(queue, {state, turn}, turn)
    end)
  end

  defp search(queue, destination, cache, blizzard_paths) do
    do_search(PriorityQueue.pop(queue), destination, cache, blizzard_paths)
  end

  defp do_search({:empty, _queue}, _destination, _cache, _blizzard_paths) do
    raise("No winning states!")
  end

  defp do_search({{:value, {position, turn}}, _queue}, position, _cache, {blizzard_paths, _}) do
    # Winner winner chicken dinner.
    {turn, Map.fetch!(blizzard_paths, turn)}
  end

  defp do_search({{:value, {position, turn}}, queue}, destination, cache, blizzard_paths) do
    hash = [position, turn]

    if MapSet.member?(cache, hash) do
      # Seen a better version of this state, scrap this one
      search(queue, destination, cache, blizzard_paths)
    else
      # Calculate legal moves, record seen, etc.
      {moves, blizzard_paths} = legal_moves(blizzard_paths, position, turn + 1)

      search(
        add_to_queue(queue, {moves, turn + 1}),
        destination,
        MapSet.put(cache, hash),
        blizzard_paths
      )
    end
  end

  defp legal_moves({blizzard_paths, max_coord}, {row, col}, turn) do
    blizzard_paths =
      Map.put_new_lazy(blizzard_paths, turn, fn ->
        calculate_blizzard_movements(Map.fetch!(blizzard_paths, turn - 1), max_coord)
      end)

    blizzards = Map.fetch!(blizzard_paths, turn)

    moves =
      [{row - 1, col}, {row + 1, col}, {row, col + 1}, {row, col - 1}, {row, col}]
      |> Enum.filter(fn coord -> Map.get(blizzards, coord) == ["."] end)

    {moves, {blizzard_paths, max_coord}}
  end

  defp calculate_blizzard_movements(state, {max_row, max_col} = max_coord) do
    state =
      Enum.reduce(state, %{}, fn {{row, col}, types}, acc ->
        Enum.reduce(types, acc, fn type, acc ->
          if type == "." do
            acc
          else
            new_coord =
              case type do
                ">" -> maybe_wrap({row, col + 1}, max_coord)
                "<" -> maybe_wrap({row, col - 1}, max_coord)
                "^" -> maybe_wrap({row - 1, col}, max_coord)
                "v" -> maybe_wrap({row + 1, col}, max_coord)
                _ -> {row, col}
              end

            Map.update(acc, new_coord, [type], &[type | &1])
          end
        end)
      end)

    for(row <- 1..max_row, col <- 1..max_col, do: {row, col})
    |> Enum.reduce(state, fn coord, acc -> Map.put_new(acc, coord, ["."]) end)
  end

  defp maybe_wrap({row, col}, {max_row, max_col}) do
    cond do
      row <= 1 && col != 2 ->
        if col == max_col, do: {max_row, col}, else: {max_row - 1, col}

      row >= max_row && col != max_col ->
        if col == 2, do: {1, 2}, else: {2, col}

      col <= 1 ->
        {row, max_col - 1}

      col >= max_col ->
        {row, 2}

      true ->
        {row, col}
    end
  end

  def parse_input(input) do
    Grid.new(input)
    |> Enum.map(fn {coord, val} -> {coord, [val]} end)
    |> Map.new()
  end

  def part1_verify, do: Day24.input() |> parse_input() |> part1()
  def part2_verify, do: Day24.input() |> parse_input() |> part2()
end

defmodule Grid do
  def new(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(Map.new(), &parse_row/2)
  end

  defp parse_row({row, row_no}, map) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(map, fn {col, col_no}, map ->
      Map.put(map, {row_no + 1, col_no + 1}, col)
    end)
  end

  def display(grid, highlight \\ nil) do
    vertices = Map.keys(grid)
    {{min_row, min_col}, {max_row, max_col}} = Enum.min_max(vertices)

    for row <- min_row..max_row, col <- min_col..max_col do
      if {row, col} == highlight do
        "E"
      else
        list = Map.fetch!(grid, {row, col})
        if(length(list) > 1, do: "#{length(list)}", else: hd(list))
      end
    end
    |> Enum.chunk_every(max_col - min_col + 1)
    |> Enum.map(&List.to_string/1)
    |> Enum.map(&IO.puts/1)

    grid
  end
end

Day24.part1 |> IO.inspect(label: "part1", limit: :infinity)
Day24.part2 |> IO.inspect(label: "part2")