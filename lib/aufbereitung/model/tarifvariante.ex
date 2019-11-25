defmodule Aufbereitung.Model.Tarifvariante do
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  alias Aufbereitung.Model.Praemie, as: Praemie

  defstruct baustein_id: nil,
            leistungsumfang: [],
            tarifbereiche: [],
            praemie: nil

  @spec new(integer, %{formel: String.t(), id: integer}, [Aufbereitung.Model.Merkmal.t()], number) :: Aufbereitung.Model.Tarifvariante.t()
  def new(grundtarif_id, %{id: id, formel: formel}, leistungsumfang, versicherungssteuer) do
    %Tarifvariante{
      baustein_id: TarifvarianteBausteinId.new(grundtarif_id, id),
      leistungsumfang: leistungsumfang,
      praemie: Praemie.new(versicherungssteuer, formel)
    }
  end

  @spec splitte(Aufbereitung.Model.Tarifvariante.t(), [Aufbereitung.Model.Merkmal.t()] | Aufbereitung.Model.Merkmal.t()) :: [Aufbereitung.Model.Tarifvariante.t()]
  def splitte(tarifvariante = %Tarifvariante{}, split_merkmale) when is_list(split_merkmale) do
    split_merkmale
    |> Enum.reduce([tarifvariante], &splitte(&2, &1, []))
    |> List.flatten()
  end

  def splitte(tarifvariante = %Tarifvariante{}, split_merkmal = %Merkmal{}) do
    {[merkmal], _} =
      tarifvariante.leistungsumfang
      |> Enum.split_with(&Merkmal.bezieht_sich_auf?(&1, split_merkmal))

    merkmal
    |> Merkmal.splitte(split_merkmal)
    |> Enum.map(&%Tarifvariante{tarifvariante | leistungsumfang: [&1 | tarifvariante.leistungsumfang -- [merkmal]]})
  end

  defp splitte([], _, acc) do
    acc
  end

  defp splitte([variante|tail], split_merkmal, acc) do
    splitte(tail, split_merkmal, acc ++ splitte(variante, split_merkmal))
  end

  @spec get_leistungsumfang(Aufbereitung.Model.Tarifvariante.t()) :: [Aufbereitung.Model.Merkmal.t()]
  def get_leistungsumfang(tarifvariante) do
    tarifvariante.leistungsumfang
  end

  @spec erweitere_leistungsumfang(Aufbereitung.Model.Tarifvariante.t(), [Aufbereitung.Model.Merkmal.t()]) :: Aufbereitung.Model.Tarifvariante.t()
  def erweitere_leistungsumfang(tarifvariante, leistungsumfang) do
    neuer_leistungsumfang =
      leistungsumfang
      |> Enum.reduce(tarifvariante.leistungsumfang, &Merkmal.hinzufuegen_wenn_nicht_vorhanden(&2, &1))

    %Tarifvariante{tarifvariante | leistungsumfang: neuer_leistungsumfang}
  end

  @spec fuege_tarifbereiche_hinzu(Aufbereitung.Model.Tarifvariante.t(), [integer]) :: Aufbereitung.Model.Tarifvariante.t()
  def fuege_tarifbereiche_hinzu(tarifvariante, tarifbereiche) do
    %Tarifvariante{tarifvariante | tarifbereiche: Enum.uniq(tarifvariante.tarifbereiche ++ tarifbereiche)}
  end

  @spec tarif_zuschlag_anwenden(Aufbereitung.Model.Tarifvariante.t(), %{formel: String.t(), id: integer}) :: Aufbereitung.Model.Tarifvariante.t()
  def tarif_zuschlag_anwenden(tarifvariante, %{id: zuschlag_id, formel: formel}) do
    %Tarifvariante{
      tarifvariante |
        baustein_id: TarifvarianteBausteinId.zuschlag_id_hinzufuegen(tarifvariante.baustein_id, zuschlag_id),
        praemie: Praemie.formel_hinzufuegen(tarifvariante.praemie, formel)
      }
  end
end
