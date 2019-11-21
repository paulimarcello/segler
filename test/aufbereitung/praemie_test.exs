defmodule PraemieTest do
  alias Aufbereitung.Model.Praemie, as: Praemie

  use ExUnit.Case

  @versicherungssteuer 1.19
  @grundpraemie "100.50"
  @zuschlags_formel "praemie*1,10"

  test "new" do
    result = Praemie.new(@versicherungssteuer, @grundpraemie)

    assert result ===
      %Praemie{
        versicherungssteuer: @versicherungssteuer,
        formeln: [@grundpraemie]
      }
  end

  test "formel_hinzufuegen" do
    result =
      Praemie.new(@versicherungssteuer, @grundpraemie)
      |> Praemie.formel_hinzufuegen(@zuschlags_formel)

    assert result ===
      %Praemie{
        versicherungssteuer: @versicherungssteuer,
        formeln: [@zuschlags_formel, @grundpraemie]
      }
  end
end
