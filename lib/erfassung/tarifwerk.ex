defmodule Tarifwerk do
  defstruct id: nil,
            history_stream: [],
            new_events: [],
            name: nil,
            tarife: [],
            zuschlaege: []

  defp new() do
    %Tarifwerk{}
  end

  defp new(id, name) do
    %Tarifwerk{id: id, name: name}
  end

  def from_history(events) do
    tarifwerk = Enum.reduce(events, new(), &apply_event({&2, &1}, false))
    %Tarifwerk{tarifwerk | history_stream: events}
  end

  def get_new_events(tarifwerk) do
    tarifwerk.new_events
  end

  defp apply_event({tarifwerk, event}, is_new? \\ true) do
    tarifwerk =
      case is_new? do
        true -> %Tarifwerk{tarifwerk | new_events: [event | tarifwerk.new_events]}
        false -> tarifwerk
      end

    case event.type do
      :tarifwerk_angelegt ->
        %Tarifwerk{tarifwerk | id: event.payload.tarifwerk_id, name: event.payload.name}

      :tarif_angelegt ->
        neuer_tarif = Tarif.new(event.payload.tarif_id, event.payload.tarif_name)
        %Tarifwerk{tarifwerk | tarife: [neuer_tarif | tarifwerk.tarife]}

      :tarifwerkszuschlag_angelegt ->
        neuer_zuschlag = Zuschlag.new(event.payload.zuschlag_id, event.payload.formel, event.payload.reihenfolge)
        %Tarifwerk{tarifwerk | zuschlaege: Zuschlag.add_zuschlag(tarifwerk.zuschlaege, neuer_zuschlag)}

      :tarifzuschlag_angelegt ->
        neuer_zuschlag = Zuschlag.new(event.payload.zuschlag_id, event.payload.formel, event.payload.reihenfolge)
        {[tarif | _], rest} = Enum.split_with(tarifwerk.tarife, fn t -> t.id === event.payload.tarif_id end)
        updated_tarif = Tarif.add_zuschlag(tarif, neuer_zuschlag)
        %Tarifwerk{tarifwerk | tarife: [updated_tarif | rest]}

      _ ->
        tarifwerk
    end
  end

  def lege_neues_tarifwerk_an(%{tarifwerk_id: id, name: name}) do
    new(id, name)
    |> create_event(:tarifwerk_angelegt, %{tarifwerk_id: id, name: name})
    |> apply_event
  end

  def lege_neuen_tarif_an(tarifwerk, %{tarif_id: tarif_id, name: tarif_name}) do
    tarifwerk
    |> create_event(:tarif_angelegt, %{tarif_id: tarif_id, tarif_name: tarif_name})
    |> apply_event
  end

  def lege_neuen_tarifwerkszuschlag_an(tarifwerk, %{zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}) do
    tarifwerk
    |> create_event(:tarifwerkszuschlag_angelegt, %{zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge})
    |> apply_event
  end

  def lege_neuen_tarifzuschlag_an(tarifwerk, %{tarif_id: tarif_id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}) do
    tarifwerk
    |> create_event(:tarifzuschlag_angelegt, %{tarif_id: tarif_id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge})
    |> apply_event
  end

  defp create_event(tarifwerk, type, payload) do
    { tarifwerk, Event.new(type, payload) }
  end
end
