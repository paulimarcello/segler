defmodule Aufbereitung.Model.Zuschlag do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag

  defstruct id: nil,
            typ: nil,
            formel: nil,
            reihenfolge: nil,
            bedingungen: []

  def new(id, typ, formel, reihenfolge, bedingungen) when is_number(id)
                                                    and (typ === :tarif or typ === :tarifwerk)
                                                    and is_binary(formel)
                                                    and is_number(reihenfolge)
                                                    and reihenfolge > 0 do
    %Zuschlag{id: id, typ: typ, formel: formel, reihenfolge: reihenfolge, bedingungen: bedingungen}
  end

  def anwenden(zuschlag, tarifvariante) do
    Tarifvariante.splitte(tarifvariante, Bedingung.get_merkmale(zuschlag.bedingungen))
    |> Enum.map(fn variante ->
                  lu = Tarifvariante.get_leistungsumfang(tarifvariante)
                  case Bedingung.erfuellt_durch?(zuschlag.bedingungen, lu) do
                    false -> variante
                    true -> Tarifvariante.tarif_zuschlag_anwenden(variante, zuschlag)
                  end
                end)
  end
end
