defmodule Aufbereitung.Model.Zuschlag do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag

  defstruct id: nil,
            typ: nil,
            formel: nil,
            reihenfolge: nil,
            bedingung: []

  def new(id, typ, formel, reihenfolge, bedingung) when is_number(id)
                                                    and (typ === :tarif or typ === :tarifwerk)
                                                    and is_binary(formel)
                                                    and is_number(reihenfolge)
                                                    and reihenfolge > 0 do
    %Zuschlag{id: id, typ: typ, formel: formel, reihenfolge: reihenfolge, bedingung: bedingung}
  end

  def anwenden(zuschlag, tarifvariante) do
    Tarifvariante.splitte(tarifvariante, Bedingung.get_merkmale(zuschlag))
    |> Enum.map(fn variante ->
                  lu = Tarifvariante.get_leistungsumfang(tarifvariante)
                  case Bedingung.erfuellt_durch(zuschlag.bedingung, lu) do
                    false -> variante
                    true -> Tarifvariante.zuschlag_anwenden(variante, {zuschlag.id})
                  end
                end)
  end
end
