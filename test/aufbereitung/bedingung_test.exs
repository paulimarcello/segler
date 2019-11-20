defmodule BedigungTest do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  use ExUnit.Case

  @merkmal_logisch_1 Merkmal.new_logisch(1, :erfuellt)
  @merkmal_logisch_2 Merkmal.new_logisch(2, :erfuellt)

  test "new" do
    bedingung = Bedingung.new(@merkmal_logisch_1)

    assert bedingung === %Bedingung{merkmal: @merkmal_logisch_1}
  end

  test "verknupfe_und 2 merkmale" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    result = Bedingung.verknuepfe_und([bedingung_1, bedingung_2])

    assert result ===
             %Bedingung.Und{
               bedingungen: [
                 %Bedingung{merkmal: @merkmal_logisch_1},
                 %Bedingung{merkmal: @merkmal_logisch_2}
               ]
             }
  end

  test "verknupfe_oder 2 merkmale" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    result = Bedingung.verknuepfe_oder([bedingung_1, bedingung_2])

    assert result ===
             %Bedingung.Oder{
               bedingungen: [
                 %Bedingung{merkmal: @merkmal_logisch_1},
                 %Bedingung{merkmal: @merkmal_logisch_2}
               ]
             }
  end

  test "get_merkmale von und-verknuepfung" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)
    verknuepfung = Bedingung.verknuepfe_und([bedingung_1, bedingung_2])

    result = Bedingung.get_merkmale(verknuepfung)

    assert result ===
             [
              @merkmal_logisch_1,
              @merkmal_logisch_2
             ]
  end

  test "get_merkmale von oder-verknuepfung" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)
    verknuepfung = Bedingung.verknuepfe_oder([bedingung_1, bedingung_2])

    result = Bedingung.get_merkmale(verknuepfung)

    assert result ===
             [
              @merkmal_logisch_1,
              @merkmal_logisch_2
             ]
  end

  #
  #          And
  #         /   \
  # EA >= 40     Or
  #             /  \
  #  halb. Rechn    halb. LSV
  test "get_merkmale aus verschachtelungstiefe 3" do
    merkmal_1 = Merkmal.new_bereich(1, 40, 150)
    bedingung_1 = Bedingung.new(merkmal_1)

    merkmal_2 = Merkmal.new_auswahl(2, [100])
    bedingung_2 = Bedingung.new(merkmal_2)

    merkmal_3 = Merkmal.new_auswahl(2, [200])
    bedingung_3 = Bedingung.new(merkmal_3)

    oder = Bedingung.verknuepfe_oder([bedingung_2, bedingung_3])
    und = Bedingung.verknuepfe_und([bedingung_1, oder])

    result = Bedingung.get_merkmale(und)

    assert result ===
             [
               merkmal_1,
               merkmal_2,
               merkmal_3
             ]
  end
end
