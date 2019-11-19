defmodule Aufbereitung.Model.Grundpraemie do
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie
  alias Aufbereitung.Model.Bedingung, as: Bedingung

  defstruct id: nil,
            formel: nil,
            bedingung: nil

  def new(id, formel, bedingung \\ nil) do
    %Grundpraemie{id: id, formel: formel, bedingung: bedingung}
  end

  def get_leistungsumfang_aus_bedingung(%Grundpraemie{bedingung: bedingung}) do
    bedingung
    |> Bedingung.leistungsbestandteile()
  end
end
