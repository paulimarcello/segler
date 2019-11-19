defmodule GrundpraemieTest do
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie
  alias Aufbereitung.Model.Bedingung, as: Bedingung

  use ExUnit.Case

  test "neue Grundpraemie ohne Bedingung" do
    grundpraemie = Grundpraemie.new(1, "50")

    assert grundpraemie === %Grundpraemie{id: 1, formel: "50", bedingung: nil}
  end

  test "neue Grundpraemie mit komplexer Bedingung" do
    left_leistungsbestandteil = %{id: 1, ist_erfuellt: true}
    left_bedingung = Bedingung.new(left_leistungsbestandteil)

    right_leistungsbestandteil = %{id: 2, ist_erfuellt: false}
    right_bedingung = Bedingung.new(right_leistungsbestandteil)

    und_bedingung = Bedingung.Und.new([left_bedingung, right_bedingung])

    grundpraemie = Grundpraemie.new(1, "50", und_bedingung)

    assert grundpraemie ===
             %Grundpraemie{
               id: 1,
               formel: "50",
               bedingung: %Bedingung.Und{
                 bedingungen: [
                   %Bedingung{leistungsbestandteil: left_leistungsbestandteil},
                   %Bedingung{leistungsbestandteil: right_leistungsbestandteil}
                 ]
               }
             }
  end
end
