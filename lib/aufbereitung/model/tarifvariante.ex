defmodule Aufbereitung.Model.Tarifvariante do
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  alias Aufbereitung.Model.Praemie, as: Praemie

  defstruct baustein_id: nil,
            leistungsumfang: [],
            tarifbereiche: [],
            praemie: nil

  def new(grundtarif_id, %{id: id, formel: formel}, leistungsumfang, versicherungssteuer), do:
    %Tarifvariante{
      baustein_id: TarifvarianteBausteinId.new(grundtarif_id, id),
      leistungsumfang: leistungsumfang,
      praemie: Praemie.new(versicherungssteuer, formel)
    }

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
  # Daten herausgeben
  # --------------------------------------------------------------------------------------------------
  def get_leistungsumfang(tarifvariante), do:
    tarifvariante.leistungsumfang

  # --------------------------------------------------------------------------------------------------
  # Daten hinzufügen
  # --------------------------------------------------------------------------------------------------
  def erweitere_leistungsumfang(tarifvariante, leistungsumfang) do
    neuer_leistungsumfang =
      leistungsumfang
      |> Enum.reduce(tarifvariante.leistungsumfang, &Merkmal.hinzufuegen_wenn_nicht_vorhanden(&2, &1))

    %Tarifvariante{tarifvariante | leistungsumfang: neuer_leistungsumfang}
  end

  def fuege_tarifbereiche_hinzu(tarifvariante, tarifbereiche), do:
    %Tarifvariante{tarifvariante | tarifbereiche: Enum.uniq(tarifvariante.tarifbereiche ++ tarifbereiche)}

  def tarif_zuschlag_anwenden(tarifvariante, %{id: zuschlag_id, formel: formel}) do
    %Tarifvariante{
      tarifvariante |
        baustein_id: TarifvarianteBausteinId.zuschlag_id_hinzufuegen(tarifvariante.baustein_id, zuschlag_id),
        praemie: Praemie.formel_hinzufuegen(tarifvariante.praemie, formel)
      }
  end
end
