defmodule Tarifwerk do
  defstruct id: nil,
            name: nil,
            tarife: [],
            zuschlaege: []

  def new() do
    %Tarifwerk{}
  end

  def new(id, name) do
    %Tarifwerk{id: id, name: name}
  end

  def handle(tarifwerk, command) do
    case command do
      {:lege_neues_tarifwerk_an, payload} ->
        lege_neues_tarifwerk_an(tarifwerk, payload)

      {:lege_neuen_tarif_an, payload} ->
        lege_neuen_tarif_an(tarifwerk, payload)

      {:lege_neuen_tarifwerkszuschlag_an, payload} ->
        lege_neuen_tarifwerkszuschlag_an(tarifwerk, payload)

      {:lege_neuen_tarifzuschlag_an, payload} ->
        lege_neuen_tarifzuschlag_an(tarifwerk, payload)
    end
  end

  defp lege_neues_tarifwerk_an(tarifwerk, {id, name}) do
    %Tarifwerk{tarifwerk | id: id, name: name}
  end

  defp lege_neuen_tarifwerkszuschlag_an(tarifwerk, {id, formel, reihenfolge}) do
    neuer_zuschlag = Zuschlag.new(id, formel, reihenfolge)
    %Tarifwerk{tarifwerk | zuschlaege: Zuschlag.add_zuschlag(tarifwerk.zuschlaege, neuer_zuschlag)}
  end

  defp lege_neuen_tarif_an(tarifwerk, {id, name}) do
    %Tarifwerk{tarifwerk | tarife: [Tarif.new(id, name) | tarifwerk.tarife]}
  end

  defp lege_neuen_tarifzuschlag_an(tarifwerk, {tarif_id, zuschlag_id, formel, reihenfolge}) do
    neuer_zuschlag = Zuschlag.new(zuschlag_id, formel, reihenfolge)
    {[tarif | _], rest} = Enum.split_with(tarifwerk.tarife, fn t -> t.id === tarif_id end)
    updated_tarif = Tarif.add_zuschlag(tarif, neuer_zuschlag)
    %Tarifwerk{tarifwerk | tarife: [updated_tarif | rest]}
  end
end
