defmodule Aufbereitung.Model.Zuschlag do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag

  defstruct id: nil,
            typ: nil,
            formel: nil,
            reihenfolge: nil,
            bedingungen: []

  @spec new(integer, :tarif | :tarifwerk, String.t(), integer, [Aufbereitung.Model.Bedingung.t()]) :: Aufbereitung.Model.Zuschlag.t()
  def new(id, typ, formel, reihenfolge, bedingungen) when is_number(id)
                                                    and (typ === :tarif or typ === :tarifwerk)
                                                    and is_binary(formel)
                                                    and is_number(reihenfolge)
                                                    and reihenfolge > 0 do
    %Zuschlag{id: id, typ: typ, formel: formel, reihenfolge: reihenfolge, bedingungen: bedingungen}
  end

  @doc """
  Anhand der ggf. vorhandenen Zuschlagsbedingungen wird die Tarifvariante in mehere weitere Tarifvarianten gesplittet.
  Die Tarifvarianten, die dann die Zuschlagsbedigungen erfüllen, erhalten den Zuschlag.
  """
  @spec anwenden(Aufbereitung.Model.Zuschlag.t(), Aufbereitung.Model.Tarifvariante.t()) :: [Aufbereitung.Model.Tarifvariante.t()]
  def anwenden(zuschlag, tarifvariante) do
    Tarifvariante.splitte(tarifvariante, Bedingung.get_merkmale(zuschlag.bedingungen))
    |> Enum.map(fn variante ->
                  merkmale = Tarifvariante.get_leistungsumfang(tarifvariante)
                  case Bedingung.erfuellt_durch?(zuschlag.bedingungen, merkmale) do
                    false -> variante
                    true -> Tarifvariante.tarif_zuschlag_anwenden(variante, %{id: zuschlag.id, formel: zuschlag.formel})
                  end
                end)
  end
end
