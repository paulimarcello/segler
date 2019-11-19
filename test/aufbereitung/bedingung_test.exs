defmodule BedigungTest do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  use ExUnit.Case

  test "einfache Bedingung" do
    leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    bedingung = Bedingung.new(leistungsbestandteil)

    assert bedingung === %Bedingung{leistungsbestandteil: leistungsbestandteil}
  end

  test "leistungsbestandteil aus einfacher Bedingung" do
    leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    bedingung = Bedingung.new(leistungsbestandteil)

    result = Bedingung.leistungsbestandteile(bedingung)

    assert result === [leistungsbestandteil]
  end

  # -----------------------------------------------------------

  test "zwei bedingungen und-verknuepft" do
    left_leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    left_bedingung = Bedingung.new(left_leistungsbestandteil)

    right_leistungsbestandteil = %{id: 2, ist_erfuellt: false}
    right_bedingung = Bedingung.new(right_leistungsbestandteil)

    und_verknuepfung = Bedingung.Und.new([left_bedingung, right_bedingung])

    expected = %Bedingung.Und{bedingungen: [left_bedingung, right_bedingung]}

    assert und_verknuepfung === expected
  end

  test "leistungsbestandteile aus und-verknuepfung" do
    left_leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    left_bedingung = Bedingung.new(left_leistungsbestandteil)

    right_leistungsbestandteil = %{id: 2, ist_erfuellt: false}
    right_bedingung = Bedingung.new(right_leistungsbestandteil)

    und_verknuepfung = Bedingung.Und.new([left_bedingung, right_bedingung])

    result = Bedingung.leistungsbestandteile(und_verknuepfung)

    assert result === [left_leistungsbestandteil, right_leistungsbestandteil]
  end

  # -----------------------------------------------------------

  test "zwei bedingungen oder-verknuepft" do
    left_leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    left_bedingung = Bedingung.new(left_leistungsbestandteil)

    right_leistungsbestandteil = %{id: 2, ist_erfuellt: false}
    right_bedingung = Bedingung.new(right_leistungsbestandteil)

    und_verknuepfung = Bedingung.Oder.new([left_bedingung, right_bedingung])

    expected = %Bedingung.Oder{bedingungen: [left_bedingung, right_bedingung]}

    assert und_verknuepfung === expected
  end

  test "leistungsbestandteile aus oder-verknuepfung" do
    left_leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    left_bedingung = Bedingung.new(left_leistungsbestandteil)

    right_leistungsbestandteil = %{id: 2, ist_erfuellt: false}
    right_bedingung = Bedingung.new(right_leistungsbestandteil)

    oder_verknuepfung = Bedingung.Oder.new([left_bedingung, right_bedingung])

    result = Bedingung.leistungsbestandteile(oder_verknuepfung)

    assert result === [left_leistungsbestandteil, right_leistungsbestandteil]
  end
end
