defmodule DokkuRemote.Commands.Ps.Scale do
  @keys [:app_name, :proctypes]
  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          app_name: String.t(),
          proctypes: %{String.t() => non_neg_integer()}
        }

  @spec from_all_output(String.t()) :: {:ok, %{String.t() => t()}}
  def from_all_output(output) do
    output
    |> String.split(~r/(?=-----> Scaling for )/, trim: true)
    |> Enum.map(&from_output/1)
    |> Enum.map(fn {:ok, scale} -> {scale.app_name, scale} end)
    |> Enum.into(%{})
    |> then(&{:ok, &1})
  end

  @spec from_output(String.t()) :: {:ok, t()}
  def from_output(output) do
    app_data =
      output
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reduce(%{}, &parse_line/2)

    {:ok, struct!(__MODULE__, app_data)}
  end

  def parse_line("-----> Scaling for " <> app_name, _app_data) do
    %{app_name: String.trim(app_name), proctypes: %{}}
  end

  def parse_line("--------: ---", app_data), do: app_data

  def parse_line(line, app_data) do
    case Regex.run(~r/^(\w+):\s+(\d+)$/, line) do
      [_, proctype, qty] ->
        proctypes = Map.put(app_data.proctypes, proctype, String.to_integer(qty))
        %{app_data | proctypes: proctypes}

      _ ->
        app_data
    end
  end
end
