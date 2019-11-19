defmodule Aufbereitung.Model.Bedingung do
  alias Aufbereitung.Model.Bedingung, as: Bedingung

  defstruct leistungsbestandteil: nil

  def new(leistungsbestandteil) do
    %Bedingung{leistungsbestandteil: leistungsbestandteil}
  end

  def leistungsbestandteile(%Bedingung{leistungsbestandteil: l}) do
    [l]
  end

  def leistungsbestandteile(%{bedingungen: bedingungen}) do
    bedingungen
    |> Enum.flat_map(&leistungsbestandteile/1)
  end

  def leistungsbestandteile([]) do
    []
  end

  def verknuepfe_und(bedingungen) do
    bedingungen
    |> Bedingung.Und.new()
  end

  def verknuepfe_oder(bedingungen) do
    bedingungen
    |> Bedingung.Oder.new()
  end

  # -----------------------------------------------------------

  defmodule Und do
    defstruct bedingungen: nil

    def new(bedingungen) do
      %Und{bedingungen: bedingungen}
    end
  end

  defmodule Oder do
    defstruct bedingungen: nil

    def new(bedingungen) do
      %Oder{bedingungen: bedingungen}
    end
  end
end
