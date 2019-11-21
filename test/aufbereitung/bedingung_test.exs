defmodule BedigungTest do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  use ExUnit.Case

  @merkmal_logisch_1 Merkmal.new_logisch(1, :erfuellt)
  @merkmal_logisch_2 Merkmal.new_logisch(2, :erfuellt)

  # --------------------------------------------------------------------------------------------------
  # new
  # --------------------------------------------------------------------------------------------------
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

  # --------------------------------------------------------------------------------------------------
  # verknuepfe
  # --------------------------------------------------------------------------------------------------
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

  # --------------------------------------------------------------------------------------------------
  # erfuellt_durch
  # --------------------------------------------------------------------------------------------------
  test "einzelbedingung wird durch leeren Leistungsumfang nicht erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)

    result = Bedingung.erfuellt_durch?(bedingung_1, [])

    assert result === false
  end

  test "einzelbedingung wird durch fehlendes merkmal nicht erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)

    result = Bedingung.erfuellt_durch?(bedingung_1, [@merkmal_logisch_2])

    assert result === false
  end

  test "einzelbedingung wird durch merkmal nicht erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)

    result = Bedingung.erfuellt_durch?(bedingung_1, [@merkmal_logisch_2])

    assert result === false
  end

  test "einzelbedingung wird durch merkmal erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)

    result = Bedingung.erfuellt_durch?(bedingung_1, [@merkmal_logisch_1])

    assert result === true
  end

  test "und-bedingung wird durch merkmale erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    und = Bedingung.verknuepfe_und([bedingung_1, bedingung_2])

    result = Bedingung.erfuellt_durch?(und, [@merkmal_logisch_1, @merkmal_logisch_2])

    assert result === true
  end

  test "und-bedingung wird durch merkmale nicht erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    und = Bedingung.verknuepfe_und([bedingung_1, bedingung_2])

    result = Bedingung.erfuellt_durch?(und, [@merkmal_logisch_1, Merkmal.new_bereich(3, 18, 55)])

    assert result === false
  end

  test "oder-bedingung wird durch keine merkmale erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    und = Bedingung.verknuepfe_oder([bedingung_1, bedingung_2])

    result = Bedingung.erfuellt_durch?(und, [Merkmal.new_bereich(3, 18, 55), Merkmal.new_bereich(4, 18, 55)])

    assert result === false
  end

  test "oder-bedingung wird durch ein merkmal erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    und = Bedingung.verknuepfe_oder([bedingung_1, bedingung_2])

    result = Bedingung.erfuellt_durch?(und, [Merkmal.new_bereich(3, 18, 55), @merkmal_logisch_1])

    assert result === true
  end

  test "oder-bedingung wird durch alle merkmale erfuellt" do
    bedingung_1 = Bedingung.new(@merkmal_logisch_1)
    bedingung_2 = Bedingung.new(@merkmal_logisch_2)

    und = Bedingung.verknuepfe_oder([bedingung_1, bedingung_2])

    result = Bedingung.erfuellt_durch?(und, [@merkmal_logisch_1, @merkmal_logisch_2])

    assert result === true
  end

  #
  #          And
  #         /   \
  # EA >= 40     Or
  #             /  \
  #  halb. Rechn    halb. LSV
  test "komplexe bedingung 1 wird durch leistungsumfang erfuellt" do
    merkmal_1 = Merkmal.new_bereich(1, 40, 150)
    bedingung_1 = Bedingung.new(merkmal_1)

    merkmal_2 = Merkmal.new_auswahl(2, [100])
    bedingung_2 = Bedingung.new(merkmal_2)

    merkmal_3 = Merkmal.new_auswahl(2, [200])
    bedingung_3 = Bedingung.new(merkmal_3)

    oder = Bedingung.verknuepfe_oder([bedingung_2, bedingung_3])
    und = Bedingung.verknuepfe_und([bedingung_1, oder])

    leistungsumfang = [
      Merkmal.new_bereich(1, 40, 150),
      Merkmal.new_auswahl(2, [200])
    ]

    result = Bedingung.erfuellt_durch?(und, leistungsumfang)

    assert result === true
  end

  #
  #          And
  #         /   \
  # EA >= 40     Or
  #             /  \
  #  halb. Rechn    halb. LSV
  test "komplexe bedingung 1 wird durch leistungsumfang nicht erfuellt" do
    merkmal_1 = Merkmal.new_bereich(1, 40, 150)
    bedingung_1 = Bedingung.new(merkmal_1)

    merkmal_2 = Merkmal.new_auswahl(2, [100])
    bedingung_2 = Bedingung.new(merkmal_2)

    merkmal_3 = Merkmal.new_auswahl(2, [200])
    bedingung_3 = Bedingung.new(merkmal_3)

    oder = Bedingung.verknuepfe_oder([bedingung_2, bedingung_3])
    und = Bedingung.verknuepfe_und([bedingung_1, oder])

    leistungsumfang = [
      Merkmal.new_bereich(1, 40, 150),
      Merkmal.new_auswahl(2, [300])
    ]

    result = Bedingung.erfuellt_durch?(und, leistungsumfang)

    assert result === false
  end
end
