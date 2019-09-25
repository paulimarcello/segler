defmodule TarifTest do
  use ExUnit.Case
  doctest(Tarif)

  test "new" do
    tarif = Tarif.new(1)

    assert tarif === %Tarif{id: 1}
  end

  test "apply NeuerTarifZuschlag" do
    tarif = Tarif.new(1)

    cmd = Zuschlag.neuer_tarif_zuschlag(1, "150", 1)

    result = Tarif.apply(tarif, cmd)

    assert result == %Tarif{id: 1, zuschlaege: [%Zuschlag{id: 1, formel: "150", reihenfolge: 1}]}
  end
end
