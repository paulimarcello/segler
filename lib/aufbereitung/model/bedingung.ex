defmodule Aufbereitung.Model.Bedingung do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Merkmal, as: Merkmal

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

  # --------------------------------------------------------------------------------------------------
  # new
  # --------------------------------------------------------------------------------------------------
  def new(merkmal), do:
    %Bedingung{merkmal: merkmal}

  # --------------------------------------------------------------------------------------------------
  # verknuepfe
  # --------------------------------------------------------------------------------------------------
  def verknuepfe_und(bedingungen), do:
    bedingungen
    |> Bedingung.Und.new()

  def verknuepfe_oder(bedingungen), do:
    bedingungen
    |> Bedingung.Oder.new()

  # --------------------------------------------------------------------------------------------------
  # erfuellt_durchget_merkmale
  # --------------------------------------------------------------------------------------------------
  def get_merkmale(bedingung), do:
    bedingung
    |> extract_merkmale()
    |> List.flatten()

  defp extract_merkmale(%{merkmal: merkmal}), do:
    [merkmal]

  defp extract_merkmale(bedingung), do:
    bedingung.bedingungen
    |> Enum.map(&extract_merkmale/1)

  # --------------------------------------------------------------------------------------------------
  # erfuellt_durch?
  # --------------------------------------------------------------------------------------------------
  def erfuellt_durch?(_, []), do:
    false

  def erfuellt_durch?(%Bedingung{merkmal: merkmal}, merkmale) do
    single_or_empty =
      merkmale
      |> Enum.split_with(&Merkmal.bezieht_sich_auf?&1, (merkmal))

    case single_or_empty do
      {[], _} -> false
      {[m], _} -> Merkmal.erfuellt_durch?(merkmal, m)
    end
  end

  def erfuellt_durch?(bedingung = %Bedingung.Und{}, merkmale), do:
    bedingung.bedingungen
    |> Enum.all?(fn einzelbedingung ->
                  erfuellt_durch?(einzelbedingung, merkmale)
                 end)

  def erfuellt_durch?(bedingung = %Bedingung.Oder{}, merkmale), do:
    bedingung.bedingungen
    |> Enum.any?(fn einzelbedingung ->
                  erfuellt_durch?(einzelbedingung, merkmale)
                 end)
end
