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

  def from_history(events) do
    tarifwerk = Enum.reduce(events, new(), &apply_event(&2, &1, false))
    %Tarifwerk{tarifwerk | history_stream: events}
  end

  def get_new_events(tarifwerk) do
    tarifwerk.new_events
  end

  defp apply_event(tarifwerk, event, is_new? \\ true) do
    tarifwerk_id = tarifwerk.id

    tarifwerk =
      case is_new? do
        true -> %Tarifwerk{tarifwerk | new_events: [event | tarifwerk.new_events]}
        false -> tarifwerk
      end

    case event do
      {:tarifwerk_angelegt, %{tarifwerk_id: id, name: name}} ->
        %Tarifwerk{tarifwerk | id: id, name: name}

      {:tarif_angelegt, %{tarifwerk_id: ^tarifwerk_id, tarif_id: tarif_id, tarif_name: tarif_name}} ->
        %Tarifwerk{tarifwerk | tarife: [Tarif.new(tarif_id, tarif_name) | tarifwerk.tarife]}

      {:tarifwerkszuschlag_angelegt, %{tarifwerk_id: ^tarifwerk_id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}} ->
        %Tarifwerk{tarifwerk | zuschlaege: Zuschlag.add_zuschlag(tarifwerk.zuschlaege, Zuschlag.new(zuschlag_id, formel, reihenfolge))}

      {:tarifzuschlag_angelegt, %{tarifwerk_id: ^tarifwerk_id, tarif_id: tarif_id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}} ->
        neuer_zuschlag = Zuschlag.new(zuschlag_id, formel, reihenfolge)
        {[tarif | _], rest} = Enum.split_with(tarifwerk.tarife, fn t -> t.id === tarif_id end)
        updated_tarif = Tarif.add_zuschlag(tarif, neuer_zuschlag)
        %Tarifwerk{tarifwerk | tarife: [updated_tarif | rest]}

      _ ->
        tarifwerk
    end
  end

  def lege_neues_tarifwerk_an(%{tarifwerk_id: id, name: name}) do
    apply_event(
      new(),
      {:tarifwerk_angelegt, %{tarifwerk_id: id, name: name}}
    )
  end

  def lege_neuen_tarif_an(tarifwerk, %{tarif_id: tarif_id, name: tarif_name}) do
    apply_event(
      tarifwerk,
      {:tarif_angelegt, %{tarifwerk_id: tarifwerk.id, tarif_id: tarif_id, tarif_name: tarif_name}}
    )
  end

  def lege_neuen_tarifwerkszuschlag_an(tarifwerk, %{zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}) do
    apply_event(
      tarifwerk,
      {:tarifwerkszuschlag_angelegt, %{tarifwerk_id: tarifwerk.id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}}
    )
  end

  def lege_neuen_tarifzuschlag_an(tarifwerk, %{tarif_id: tarif_id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}) do
    apply_event(
      tarifwerk,
      {:tarifzuschlag_angelegt,
       %{tarifwerk_id: tarifwerk.id, tarif_id: tarif_id, zuschlag_id: zuschlag_id, formel: formel, reihenfolge: reihenfolge}}
    )
  end
end
