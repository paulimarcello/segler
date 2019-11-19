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

  def erweitere_leistungsumfang(tarifvariante = %Tarifvariante{}, leistungsumfang) do
    neuer_leistungsumfang =
      leistungsumfang
      |> Enum.reduce(tarifvariante.leistungsumfang, &Merkmal.hinzufuegen_wenn_nicht_vorhanden(&2, &1))

    %Tarifvariante{tarifvariante | leistungsumfang: neuer_leistungsumfang}
  end

  @spec fuege_tarifbereiche_hinzu(Aufbereitung.Model.Tarifvariante.t(), [number]) :: Aufbereitung.Model.Tarifvariante.t()
  def fuege_tarifbereiche_hinzu(tarifvariante, tarifbereiche) do
    %Tarifvariante{tarifvariante | tarifbereiche: Enum.uniq(tarifvariante.tarifbereiche ++ tarifbereiche)}
  end
end
