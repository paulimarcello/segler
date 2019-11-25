defmodule Aufbereitung.Model.Praemie do
  alias Aufbereitung.Model.Praemie, as: Praemie

  defstruct versicherungssteuer: nil,
            formeln: nil

  @spec new(number, String.t()) :: Aufbereitung.Model.Praemie.t()
  def new(versicherungssteuer, grundpraemie_formel) when is_number(versicherungssteuer) and is_binary(grundpraemie_formel) do
    %Praemie{versicherungssteuer: versicherungssteuer, formeln: [grundpraemie_formel]}
  end

  @spec formel_hinzufuegen(Aufbereitung.Model.Praemie.t(), String.t()) :: Aufbereitung.Model.Praemie.t()
  def formel_hinzufuegen(praemie, formel) when is_binary(formel) do
    %Praemie{praemie | formeln: [formel | praemie.formeln]}
  end
end
