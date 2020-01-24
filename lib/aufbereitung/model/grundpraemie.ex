defmodule Aufbereitung.Model.Grundpraemie do
  alias Aufbereitung.Model.{Bedingung, Grundpraemie, Tarifvariante}

  defstruct id: nil,
            formel: nil,
            bedingungen: nil

  @spec new(integer, String.t(), [Aufbereitung.Model.Bedingung.t()] | nil) :: Aufbereitung.Model.Grundpraemie.t()
  def new(id, formel, bedingungen \\ nil) do
    %Grundpraemie{id: id, formel: formel, bedingungen: bedingungen}
  end

  @spec erzeuge_grundtarifvariante(Aufbereitung.Model.Grundpraemie.t(), integer, number) :: Aufbereitung.Model.Tarifvariante.t()
  def erzeuge_grundtarifvariante(grundpraemie, tarif_id, versicherungssteuer) do
    Tarifvariante.new(
      tarif_id,
      %{id: grundpraemie.id, formel: grundpraemie.formel},
      Bedingung.get_merkmale(grundpraemie.bedingungen),
      versicherungssteuer
    )
  end
end
