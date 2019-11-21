defmodule TarifvarianteBausteinIdTest do
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId

  use ExUnit.Case

  @tarif_id 1
  @grundpraemie_id 10
  @zuschlag_id_1 100

  test "new" do
    result = TarifvarianteBausteinId.new(@tarif_id, @grundpraemie_id)

    assert result ===
      %TarifvarianteBausteinId{
        tarif_id: @tarif_id,
        grundpraemie_id: @grundpraemie_id,
      }
  end

  test "zuschlag_id_hinzufuegen" do
    id = TarifvarianteBausteinId.new(@tarif_id, @grundpraemie_id)

    result = TarifvarianteBausteinId.zuschlag_id_hinzufuegen(id, @zuschlag_id_1)

    assert result ===
      %TarifvarianteBausteinId{
        tarif_id: @tarif_id,
        grundpraemie_id: @grundpraemie_id,
        zuschlaege_ids: [@zuschlag_id_1]
      }
  end
end
