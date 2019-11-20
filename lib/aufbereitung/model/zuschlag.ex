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
    split_merkmale = Bedingung.get_merkmale(zuschlag)

    neue_tarifvarianten = Tarifvariante.splitte(tarifvariante, split_merkmale)

    nil
  end
end
