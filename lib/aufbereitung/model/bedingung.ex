defmodule Aufbereitung.Model.Bedingung do
  alias Aufbereitung.Model.Bedingung, as: Bedingung

  defmodule Und do
    defstruct bedingungen: nil

    def new(bedingungen) when is_list(bedingungen) do
      %Und{bedingungen: bedingungen}
    end
  end

  defmodule Oder do
    defstruct bedingungen: nil

    def new(bedingungen) when is_list(bedingungen) do
      %Oder{bedingungen: bedingungen}
    end
  end

  # -----------------------------------------------------------

  defstruct merkmal: nil

  def new(merkmal), do: %Bedingung{merkmal: merkmal}

  def verknuepfe_und(bedingungen),
    do:
      bedingungen
      |> Bedingung.Und.new()

  def verknuepfe_oder(bedingungen),
    do:
      bedingungen
      |> Bedingung.Oder.new()

  def get_merkmale(bedingung),
    do:
      bedingung
      |> extract_merkmale()
      |> List.flatten()

  defp extract_merkmale(%{merkmal: merkmal}), do: merkmal

  defp extract_merkmale(bedingung),
    do:
      bedingung.bedingungen
      |> Enum.map(&extract_merkmale/1)
end
