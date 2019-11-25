defmodule Aufbereitung.Model.Bedingung do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Merkmal, as: Merkmal

  defmodule Und do
    defstruct bedingungen: nil

    @spec new([Aufbereitung.Model.Bedingung.t()]) :: Aufbereitung.Model.Bedingung.Und.t()
    def new(bedingungen) when is_list(bedingungen) do
      %Und{bedingungen: bedingungen}
    end
  end

  defmodule Oder do
    defstruct bedingungen: nil

    @spec new([Aufbereitung.Model.Bedingung.t()]) :: Aufbereitung.Model.Bedingung.Oder.t()
    def new(bedingungen) when is_list(bedingungen) do
      %Oder{bedingungen: bedingungen}
    end
  end

  # -----------------------------------------------------------

  defstruct merkmal: nil

  @spec new(Aufbereitung.Model.Merkmal.t()) :: Aufbereitung.Model.Bedingung.t()
  def new(merkmal) do
    %Bedingung{merkmal: merkmal}
  end

  @spec verknuepfe_und([Aufbereitung.Model.Bedingung.t()]) :: Aufbereitung.Model.Bedingung.Und.t()
  def verknuepfe_und(bedingungen) do
    bedingungen
    |> Bedingung.Und.new()
  end

  @spec verknuepfe_oder([Aufbereitung.Model.Bedingung.t()]) :: Aufbereitung.Model.Bedingung.Oder.t()
  def verknuepfe_oder(bedingungen) do
    bedingungen
    |> Bedingung.Oder.new()
  end

  @spec get_merkmale(Aufbereitung.Model.Bedingung.t()) :: [Aufbereitung.Model.Merkmal.t()]
  def get_merkmale(nil) do
    []
  end

  def get_merkmale(bedingung) do
    bedingung
    |> extract_merkmale()
    |> List.flatten()
  end

  defp extract_merkmale(%{merkmal: merkmal}) do
    [merkmal]
  end

  defp extract_merkmale(bedingung) do
    bedingung.bedingungen
    |> Enum.map(&extract_merkmale/1)
  end

  @spec erfuellt_durch?(Aufbereitung.Model.Bedingung.t(), [Aufbereitung.Model.Merkmal.t()]) :: boolean
  def erfuellt_durch?(nil, _) do
    true
  end

  def erfuellt_durch?(_, []) do
    false
  end

  def erfuellt_durch?(%Bedingung{merkmal: merkmal}, merkmale) do
    single_or_empty =
      merkmale
      |> Enum.split_with(&Merkmal.bezieht_sich_auf?(&1, merkmal))

    case single_or_empty do
      {[], _} -> false
      {[m], _} -> Merkmal.erfuellt_durch?(merkmal, m)
    end
  end

  def erfuellt_durch?(bedingung = %Bedingung.Und{}, merkmale) do
    bedingung.bedingungen
    |> Enum.all?(fn einzelbedingung ->
                  erfuellt_durch?(einzelbedingung, merkmale)
                 end)
  end

  def erfuellt_durch?(bedingung = %Bedingung.Oder{}, merkmale) do
    bedingung.bedingungen
    |> Enum.any?(fn einzelbedingung ->
                  erfuellt_durch?(einzelbedingung, merkmale)
                 end)
  end
end
