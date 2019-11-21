defmodule Aufbereitung.Model.Praemie do
  alias Aufbereitung.Model.Praemie, as: Praemie

  defstruct versicherungssteuer: nil,
            formeln: nil

  def new(versicherungssteuer, grundpraemie_formel) when is_number(versicherungssteuer) and is_binary(grundpraemie_formel), do:
    %Praemie{versicherungssteuer: versicherungssteuer, formeln: [grundpraemie_formel]}

  def formel_hinzufuegen(praemie, formel) when is_binary(formel), do:
    %Praemie{praemie | formeln: [formel | praemie.formeln]}
end
