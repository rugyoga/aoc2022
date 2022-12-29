defmodule Day19 do
    def input do
        # "day19.txt"
        # |> File.read!
"""
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"""
        |> String.split("\n", trim: true)
        |> Enum.map(
            fn line -> 
                line
                |> String.split(".", trim: true)
                |> Enum.map(
                    fn s -> 
                        s
                        |> String.split(" robot costs ", trim: true)
                        |> then(
                            fn [a, b] ->
                                target = a |> String.split(" ", trim: true) |> List.last()
                                costs = b |> String.split(" and ", trim: true) |> Enum.map(fn a -> a |> String.split(" ", trim: true) end)
                                {target, costs |> Enum.map(fn [a, b] -> {b, String.to_integer(a)} end) |> Map.new()}
                            end)
                    end)
                |> Map.new()
            end
        )
        |> Enum.with_index(1)
    end

    @priority ["geode", "obsidian", "clay", "ore"]

    def part1 do
        input()
        |> Enum.map(
            fn rules -> 
                simulate(
                %{
                    robots: %{"ore" => 1, "clay" => 0, "obsidian" => 0, "geode" => 0},
                    minerals: %{"ore" => 0, "clay" => 0, "obsidian" => 0, "geode" => 0}
                },
                rules,
                24)
            end)
        |> Enum.sum

    end

    def log(inventory, n, i) do
        IO.puts("\nRules #{n}, Step #{24 - i + 1}")
        IO.inspect(inventory.robots, label: "robots")
        IO.inspect(inventory.minerals, label: "minerals")
        inventory
    end

    def simulate(inventory, {_, n}, 0), do: n * inventory.minerals["geode"]
    def simulate(inventory, {rules, n} = blueprint, i) do
        rules
        |> build_robots(inventory)
        |> produce_minerals(inventory.robots)
        |> log(n, i)
        |> simulate(blueprint, i-1)
    end

    def build_robots(rules, inventory) do
        Enum.reduce(
            @priority,
            inventory,
            fn robot, %{robots: robots, minerals: minerals} -> 
                requirements = rules[robot]
                purchased = minerals |> Stream.iterate(&buy(requirements, &1)) |> Stream.take_while(&sufficient?/1)
                %{
                    robots: Map.update!(robots, robot, &(&1 + Enum.count(purchased) - 1)),
                    minerals: Enum.at(purchased, -1)
                }
            end)
    end
    
    def produce_minerals(inventory, robots) do
        %{inventory | minerals: produce(robots, inventory.minerals)}
    end
                
    def sufficient?(available) do
        Enum.all?(available, fn {_, quantity} -> quantity >= 0 end)
    end

    def delta(target, available, f) do
        Enum.reduce(target, available, fn {mineral, quantity}, available -> Map.update!(available, mineral, &f.(&1, quantity)) end)
    end

    def buy(costs, minerals), do: delta(costs, minerals, &Kernel.-/2)

    def produce(robots, minerals), do: delta(robots, minerals, &Kernel.+/2)

    def part2 do
        input()
    end
end

Day19.part1() |> IO.inspect(label: "part1")
#Day19.part2() |> IO.inspect(label: "part2", limit: :infinity)