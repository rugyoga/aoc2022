defmodule Day25 do

    def input do
        "day25.txt"
        |> File.read! 
        |> String.split("\n", trim: true)
        |> Enum.map(&snafu_to_dec/1)
    end

    def snafu_to_digit("="), do: -2
    def snafu_to_digit("-"), do: -1
    def snafu_to_digit("0"), do: 0
    def snafu_to_digit("1"), do: 1
    def snafu_to_digit("2"), do: 2

    def digit_to_snafu(-2), do: "="
    def digit_to_snafu(-1), do: "-"
    def digit_to_snafu(0), do: "0"
    def digit_to_snafu(1), do: "1"
    def digit_to_snafu(2), do: "2"


    def snafu_to_dec(s) do
        String.split(s, "", trim: true)
        |> Enum.reverse
        |> Enum.reduce({1, 0}, fn snafu, {base, acc} -> {base*5, acc + snafu_to_digit(snafu) * base} end)
        |> elem(1)
    end

    def dec_to_snafu(n) when is_binary(n), do: dec_to_snafu(String.to_integer(n))
    def dec_to_snafu(n) do
        n
        |> Integer.digits(5)
        |> Enum.reverse()
        |> Enum.reduce(
            {[], 0},
            fn digit, {digits, carry} ->
                combined = digit + carry
                if combined > 2 do
                    {[combined-5 | digits], 1}
                else    
                    {[combined | digits], 0}
                end
            end
        )
        |> then(fn {digits, carry} -> if(carry == 1, do: [1 | digits], else: digits) end)
        |> Enum.map(&digit_to_snafu/1)
        |> Enum.join()
    end

    def part1, do: input() |> Enum.sum() |> dec_to_snafu()
end

Day25.part1() |> IO.inspect(label: "part1")