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

  def splitte(tarifvarianten, split_merkmale) when is_list(split_merkmale) and is_list(tarifvarianten) do
    tarifvarianten
    |> splitte(split_merkmale)
    |> List.flatten()
    #split_merkmale
    #|> Enum.reduce([tarifvariante], &Tarifvariante.splitte(&2, &1))
  end

  def splitte(tarifvariante = %Tarifvariante{}, split_merkmale) when is_list(split_merkmale) do
    split_merkmale
    |> Enum.map(&splitte(tarifvariante, &1))
  end

  def splitte(tarifvarianten, split_merkmal = %Merkmal{}) when is_list(tarifvarianten) do
    tarifvarianten
    |> Enum.map(&splitte(&1, split_merkmal))
  end

  def splitte(tarifvariante = %Tarifvariante{}, split_merkmal = %Merkmal{}) do
    {[merkmal], _} =
      tarifvariante.leistungsumfang
      |> Enum.split_with(fn m -> Merkmal.bezieht_sich_auf?(m, split_merkmal) end)

    neuer_leistungsumfang = tarifvariante.leistungsumfang -- [merkmal]

    merkmal
    |> Merkmal.splitte(split_merkmal)
    |> Enum.map(&%Tarifvariante{tarifvariante | leistungsumfang: [&1 | neuer_leistungsumfang]})
  end

  # --------------------- ??? -------------------------

  def erweitere_leistungsumfang(tarifvariante, leistungsumfang) do
    neuer_leistungsumfang =
      leistungsumfang
      |> Enum.reduce(tarifvariante.leistungsumfang, &Merkmal.hinzufuegen_wenn_nicht_vorhanden(&2, &1))

    %Tarifvariante{tarifvariante | leistungsumfang: neuer_leistungsumfang}
  end

  def fuege_tarifbereiche_hinzu(tarifvariante, tarifbereiche) do
    %Tarifvariante{tarifvariante | tarifbereiche: Enum.uniq(tarifvariante.tarifbereiche ++ tarifbereiche)}
  end
end
