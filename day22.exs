defmodule Day22 do
    @moves ["L", "R"]

    def input do
        [map, path] = "day22.txt" |> File.read! |> String.split("\n\n", trim: true)
        {parse_path(path), parse_map(map)}
    end

    def parse_path(path) do
        path 
        |> String.split("", trim: true) 
        |> Enum.chunk_by(&(&1 in @moves))
        |> Enum.map(&Enum.join/1)
        |> Enum.map(fn chars -> if(chars in @moves, do: chars, else: String.to_integer(chars)) end)
    end 

    def col({{c, _}, _}), do: c
    def row({{_, r}, _}), do: r
    def item({_, i}), do: i
    def pos({p, _}), do: p

    def bounds(xs, get_x, get_y), do: xs |> Enum.map(fn x -> {get_x.(List.first(x)), Enum.min_max_by(x, get_y)} end) |> Map.new

    def parse_map(map) do
        remove_blanks = &Enum.reject(&1, fn {_, ch} -> ch == " " end)
        rows = map |> String.split("\n", trim: true) |> Enum.map(&String.pad_trailing(&1, 3*@size))|> Enum.with_index(1) |> Enum.map(&parse_row/1)
        trimmed_rows = Enum.map(rows, remove_blanks)
        %{cols: rows |> transpose() |> Enum.map(remove_blanks) |> bounds(&col/1, &row/1),
          rows: bounds(trimmed_rows, &row/1, &col/1),
          map:  Map.new(List.flatten(trimmed_rows))}
    end

    def parse_row({row, r}) do
        row
        |> String.split("", trim: true) 
        |> Enum.with_index(fn ch, c -> {{c+1, r}, ch} end)
    end

    def transpose(xs), do: xs |> Enum.zip |> Enum.map(&Tuple.to_list/1)

    def dir("U", "L"), do: "L"
    def dir("R", "L"), do: "U"
    def dir("D", "L"), do: "R"
    def dir("L", "L"), do: "D"
    def dir("U", "R"), do: "R"
    def dir("R", "R"), do: "D"
    def dir("D", "R"), do: "L"
    def dir("L", "R"), do: "U"

    @deltas %{"U" => {0, -1}, "L" => {-1, 0}, "D" => {0, 1}, "R" => {1, 0}}

    def navigate({path, map}, handle_nil) do
        navigate({map.rows[1] |> elem(0) |> pos(), "R"}, path, map, handle_nil)
    end

    def navigate(position, [], _, _), do: position
    def navigate({xy, h}, [t | rest], data, handle_nil) when t in @moves do
        new_h = dir(h, t)
        navigate({xy, new_h}, rest, data, handle_nil)
    end
    def navigate(pos, [0 | rest], map, handle_nil) do
        navigate(pos, rest, map, handle_nil)
    end
    def navigate({{c, r}, h} = pos, [n | rest], map, handle_nil) do
        {cd, rd} = @deltas[h]
        cr_new = {c+cd, r+rd}
        case map.map[cr_new] do
        nil ->
            handle_nil.(pos, [n | rest], map)
        "#" ->
            navigate(pos, rest, map, handle_nil)
        "." -> navigate({cr_new, h}, [n-1 | rest], map, handle_nil)
        end
    end

    def part1_handle_nil({{c, r}, h} = pos, [n | rest], map) do
        bounds = if(h in @moves, do: map.rows[r], else: map.cols[c])
        {cr_wrapped, tile} = if(h in ["R", "D"], do: elem(bounds, 0), else: elem(bounds, 1))
        if tile == "#" do
            navigate(pos, rest, map, &part1_handle_nil/3)
        else
            navigate({cr_wrapped, h}, [n-1 | rest], map, &part1_handle_nil/3)
        end
    end

    def part2_handle_nil({pos, h} = pos_h, [move | moves], map) do
        case h do
        "L" -> transition_l(pos)
        "R" -> transition_r(pos)
        "U" -> transition_u(pos)
        "D" -> transition_d(pos)
        end
        |> show_transition(pos_h)
        |> then(
            fn {new_pos, _} = new_pos_h ->
                if map.map[new_pos] == "#" do
                    navigate(pos_h, moves, map, &part2_handle_nil/3)
                else
                    navigate(new_pos_h, [move | moves], map, &part2_handle_nil/3)
                end
            end
        )
    end

    @size 50

    def face({c, r}) do
        cond do
        c <= @size -> if(r > 3*@size, do: "F", else: "E")
        r <= @size -> if(c > 2*@size, do: "B", else: "A")
        true -> if(r > 2*@size, do: "D", else: "C")
        end
    end

    def show_transition({y_pos, _} = y, {x_pos, _} = x) do
        IO.puts("#{inspect(x)}:#{face(x_pos)}) -> #{inspect(y)}:#{face(y_pos)})")
        y
    end

    def transition_l({_, r} = p) do
        cond do
        r <= @size   -> {{        1, 3*@size+1-r}, "R"} # A left -> E left
        r <= 2*@size -> {{  r-@size,   2*@size+1}, "D"} # C left -> E top
        r <= 3*@size -> {{  @size+1, 3*@size+1-r}, "R"} # E left -> A left
        r <= 4*@size -> {{r-2*@size,           1}, "D"} # F left -> A top
        true -> IO.inspect(p, label: "transition_l")
        end
    end

    def transition_r({_, r} = p) do
        cond do
        r <= @size   -> {{  2*@size, 3*@size+1-r}, "L"} # B right -> D right
        r <= 2*@size -> {{  r+@size,       @size}, "U"} # C right -> B bottom
        r <= 3*@size -> {{  3*@size, 3*@size+1-r}, "L"} # D right -> B right
        r <= 4*@size -> {{r-2*@size,     3*@size}, "U"} # F right -> D bottom
        true -> IO.inspect(p, label: "transition_r")
        end
    end

    def transition_u({c, _} = p) do
        cond do
        c <= @size   -> {{  @size+1,   c+@size}, "R"} # E top -> C left
        c <= 2*@size -> {{        1, c+2*@size}, "R"} # A top -> F left
        c <= 3*@size -> {{c-2*@size,   4*@size}, "U"} # B top -> F bottom
        true -> IO.inspect(p, label: "transition_u")
        end
    end

    def transition_d({c, _} = p) do
        cond do
        c <= @size   -> {{c+2*@size,         1}, "D"} # F bottom -> B top
        c <= 2*@size -> {{    @size, c+2*@size}, "L"} # D bottom -> F right
        c <= 3*@size -> {{  2*@size,   c-@size}, "L"} # B bottom -> C right
        true -> IO.inspect(p, label: "transition_d")
        end
    end

    @values %{"R" => 0, "D" => 1, "L" => 2, "U" => 3}
    def calculate({{c, r}, h}), do: 1000*r + 4*c + @values[h]

    def part1, do: input() |> navigate(&part1_handle_nil/3) |> calculate()
    def part2, do: input() |> navigate(&part2_handle_nil/3) |> calculate()
end

Day22.part1() |> IO.inspect(label: "part1")
Day22.part2() |> IO.inspect(label: "part2")