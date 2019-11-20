defmodule Aufbereitung.Model.Tarifvariante do
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.TarifvariantenbausteinId, as: TarifvariantenbausteinId
  alias Aufbereitung.Model.Merkmal, as: Merkmal

  defstruct baustein_id: nil,
            leistungsumfang: [],
            tarifbereiche: []

  def new(grundtarif_id, grundpraemie_id, leistungsumfang) do
    baustein_id = TarifvariantenbausteinId.new(grundtarif_id, grundpraemie_id)
    %Tarifvariante{baustein_id: baustein_id, leistungsumfang: leistungsumfang}
  end

  # --------------------------------------------------------------------------------------------------
  # Anwendung Split
  # --------------------------------------------------------------------------------------------------
  def splitte(tarifvariante = %Tarifvariante{}, split_merkmale) when is_list(split_merkmale), do:
    split_merkmale
    |> Enum.reduce([tarifvariante], &splitte(&2, &1, []))
    |> List.flatten()

  def splitte(tarifvariante = %Tarifvariante{}, split_merkmal = %Merkmal{}) do
    {[merkmal], _} =
      tarifvariante.leistungsumfang
      |> Enum.split_with(&Merkmal.bezieht_sich_auf?(&1, split_merkmal))

    merkmal
    |> Merkmal.splitte(split_merkmal)
    |> Enum.map(&%Tarifvariante{tarifvariante | leistungsumfang: [&1 | tarifvariante.leistungsumfang -- [merkmal]]})
  end

  defp splitte([], _, acc), do:
    acc

  defp splitte([variante|tail], split_merkmal, acc), do:
    splitte(tail, split_merkmal, acc ++ splitte(variante, split_merkmal))

  # --------------------------------------------------------------------------------------------------
  # Leistungsumfang
  # --------------------------------------------------------------------------------------------------

  def get_leistungsumfang(tarifvariante), do:
    tarifvariante.leistungsumfang

  def erweitere_leistungsumfang(tarifvariante, leistungsumfang) do
    neuer_leistungsumfang =
      leistungsumfang
      |> Enum.reduce(tarifvariante.leistungsumfang, &Merkmal.hinzufuegen_wenn_nicht_vorhanden(&2, &1))

    %Tarifvariante{tarifvariante | leistungsumfang: neuer_leistungsumfang}
  end

  def fuege_tarifbereiche_hinzu(tarifvariante, tarifbereiche), do:
    %Tarifvariante{tarifvariante | tarifbereiche: Enum.uniq(tarifvariante.tarifbereiche ++ tarifbereiche)}
end
