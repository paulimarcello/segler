defmodule Aufbereitung.Model.TarifvarianteBausteinId do
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId

  defstruct tarif_id: nil,
            grundpraemie_id: nil,
            zuschlaege_ids: []

  @spec new(integer, integer) :: Aufbereitung.Model.TarifvarianteBausteinId.t()
  def new(tarif_id, grundpraemie_id) do
    %TarifvarianteBausteinId{tarif_id: tarif_id, grundpraemie_id: grundpraemie_id}
  end

  @spec zuschlag_id_hinzufuegen(Aufbereitung.Model.TarifvarianteBausteinId.t(), integer) :: Aufbereitung.Model.TarifvarianteBausteinId.t()
  def zuschlag_id_hinzufuegen(baustein_id, zuschlag_id) when is_number(zuschlag_id) do
    %TarifvarianteBausteinId{baustein_id | zuschlaege_ids: [zuschlag_id|baustein_id.zuschlaege_ids]}
  end
end
