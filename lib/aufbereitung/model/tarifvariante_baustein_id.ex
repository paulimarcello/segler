defmodule Aufbereitung.Model.TarifvarianteBausteinId do
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId

  defstruct tarif_id: nil,
            grundpraemie_id: nil,
            zuschlaege_ids: []

  def new(tarif_id, grundpraemie_id), do:
    %TarifvarianteBausteinId{tarif_id: tarif_id, grundpraemie_id: grundpraemie_id}

  def zuschlag_id_hinzufuegen(baustein_id, zuschlag_id) when is_number(zuschlag_id), do:
    %TarifvarianteBausteinId{baustein_id | zuschlaege_ids: [zuschlag_id|baustein_id.zuschlaege_ids]}
end
