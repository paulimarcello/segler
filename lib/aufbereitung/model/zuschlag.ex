defmodule Aufbereitung.Model.Zuschlag do
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag

  defstruct id: nil,
            typ: nil,
            formel: nil,
            reihenfolge: nil,
            bedingungen: []

  def new(id, typ, formel, reihenfolge, bedingungen)
      when is_number(id) and
             (typ === :tarif or typ === :tarifwerk) and
             is_binary(formel) and
             is_number(reihenfolge) and reihenfolge > 0 do
    %Zuschlag{id: id, typ: typ, formel: formel, reihenfolge: reihenfolge, bedingungen: bedingungen}
  end

  def anwenden(_zuschlag, tarifvariante) do
    tarifvariante
  end
end
