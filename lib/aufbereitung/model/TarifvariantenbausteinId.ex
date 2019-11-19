defmodule Aufbereitung.Model.TarifvariantenbausteinId do
  alias Aufbereitung.Model.TarifvariantenbausteinId, as: TarifvariantenbausteinId

  defstruct tarif_id: nil,
            grundpraemie_id: nil

  def new(tarif_id, grundpraemie_id) do
    %TarifvariantenbausteinId{tarif_id: tarif_id, grundpraemie_id: grundpraemie_id}
  end
end
