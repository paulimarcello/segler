defmodule Aufbereitung.Model.Grundpraemie do
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie

  defstruct id: nil,
            formel: nil,
            bedingung: nil

  def new(id, formel, bedingung \\ nil) do
    %Grundpraemie{id: id, formel: formel, bedingung: bedingung}
  end

end
