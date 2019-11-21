defmodule Aufbereitung.Model.Grundpraemie do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie

  defstruct id: nil,
            formel: nil,
            bedingungen: nil

  def new(id, formel, bedingungen \\ nil) do
    %Grundpraemie{id: id, formel: formel, bedingungen: bedingungen}
  end

  def get_leistungsumfang_aus_bedingung(grundpraemie) do
    Bedingung.get_merkmale(grundpraemie.bedingungen)
  end
end
