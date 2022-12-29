Code.require_file("priority_queue.ex")

defmodule Day16 do
    def input do
        # "day16.txt"
        # |> File.read!
"""
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"""
        |> String.split("\n", trim: true)
        |> Enum.map(&extract/1)
        |> Map.new
    end

    def extract(line) do
        ~r/Valve (?<valve>..) has flow rate=(?<flow>\d+); tunnel(?:s)? lead(?:s)? to valve(?:s)? (?<valves>.*)/
        |> Regex.named_captures(line)
        |> then(fn m -> {m["valve"], %{rate: String.to_integer(m["flow"]), edges: String.split(m["valves"], ", ", trim: true)}} end)
    end

    def closed(graph) do
        graph
        |> Enum.flat_map(fn {name, v} -> if(v.rate > 0, do: [name], else: []) end)
        |> MapSet.new
    end

    def generate_costs(pq, graph, costs, uncosted) do
        {result, pq} = PriorityQueue.pop(pq)
        if result == :empty do
            costs
        else
            {cost, {a, b}} = result
            extend_b = for from_b <- graph[b].edges, a != from_b and !Map.has_key?(costs, order(a, from_b)), do: order(a, from_b)
            extend_a = for from_a <- graph[a].edges, from_a != b and !Map.has_key?(costs, order(from_a, b)), do: order(from_a, b)
            {pq, costs, uncosted} =
                Enum.reduce(
                    extend_a ++ extend_b,
                    {pq, costs, uncosted},
                    fn edge, {pq, costs, uncosted} -> 
                        {pq |> PriorityQueue.push({cost+1, edge}),
                         costs |> Map.put(edge, cost+1),
                         uncosted |> MapSet.delete(edge)}
                    end)
            generate_costs(pq, graph, costs, uncosted)
        end
    end

    def order(a, b), do: if a < b, do: {a, b}, else: {b, a}

    def generate_costs(graph, closed) do
        costs = Enum.reduce(graph, %{}, fn {valve, %{edges: valves}}, costs -> Enum.reduce(valves, costs, &Map.put(&2, order(&1, valve), 1)) end)
        uncosted = for x <- closed, y <- closed, x < y and !Map.has_key?(costs, {x,y}), into: MapSet.new, do: {x, y}
        costs
        |> Enum.reduce(PriorityQueue.new, fn {edge, cost}, costs -> PriorityQueue.push(costs, {cost, edge}) end)
        |> generate_costs(graph, costs, uncosted)
        |> Enum.flat_map(fn {{a, b}, cost} -> [{{a, b}, cost}, {{b, a}, cost}] end)
        |> Enum.group_by(fn {{a, _}, _} -> a end)
        |> Enum.map(fn {a, a_b_costs} -> {a, a_b_costs |> Enum.map(fn {{_, b}, cost} -> {b, cost} end) |> Map.new()} end)
        |> Map.new
    end

    def search(pq, graph, costs) do
        {result, pq} = PriorityQueue.pop(pq)
        if result != :empty do
            {{minute, neg_cost} = pq_key, {edge, closed, path}} = result
            if minute == 0 or Enum.empty?(closed) do
                {-neg_cost, path}
            else
                costs[edge]
                |> Enum.sort_by(fn {_, cost} -> -cost end)
                |> Enum.filter(fn {edge, _} -> MapSet.member?(closed, edge) end)
                |> Enum.reduce(pq, &open(&1, &2, pq_key, graph, closed, path))
                |> search(graph, costs)
            end
        end
    end

    @open_cost 1 

    def open({to_edge, move_cost}, pq, {minutes, neg_cost}, graph, closed, path) do
        new_minutes = minutes - move_cost - @open_cost
        if minutes >= 0 do
            PriorityQueue.push(pq, {{neg_cost - new_minutes * graph[to_edge].rate, new_minutes}, {to_edge, MapSet.delete(closed, to_edge), [to_edge | path]}})
        else
            pq
        end
        |> IO.inspect(label: "open")
    end

    def first_move(graph, closed, minutes, start \\ "AA") do
        pq = PriorityQueue.new |> PriorityQueue.push({{minutes, 0}, {start, closed, []}})
        if MapSet.member?(closed, start) do
            pq |> PriorityQueue.push({{(1-minutes) * graph[start].rate, minutes - 1}, {start, MapSet.delete(closed, start), [start]}})
        else
            pq
        end
        |> IO.inspect(label: "first_move")
    end

    def part1 do
        graph = input()
        closed = closed(graph)
        costs = generate_costs(graph, closed)
        search(first_move(graph, closed, 30), graph, costs)
    end

    def part2 do
        input() 
    end
end

Day16.part1() |> IO.inspect(label: "part1", limit: :infinity)
#Day16.part2() |> IO.inspect(label: "part2", limit: :infinity)