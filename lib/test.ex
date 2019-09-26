defmodule Test do
  @events [
    {:tarifwerk_angelegt, %{tarifwerk_id: 1, name: "Advocard 360 Plus"}},
    {:tarif_angelegt, %{tarifwerk_id: 1, tarif_id: 1, tarif_name: "P"}},
    {:tarif_angelegt, %{tarifwerk_id: 1, tarif_id: 2, tarif_name: "PB"}},
    {:tarif_angelegt, %{tarifwerk_id: 1, tarif_id: 3, tarif_name: "PV"}},
    {:tarifwerkszuschlag_angelegt, %{tarifwerk_id: 1, zuschlag_id: 1, formel: "praemie*1.5", reihenfolge: 1}},
    {:tarifwerkszuschlag_angelegt, %{tarifwerk_id: 1, zuschlag_id: 2, formel: "praemie*1.025", reihenfolge: 2}},
    {:tarifzuschlag_angelegt, %{tarifwerk_id: 1, tarif_id: 1, zuschlag_id: 1, formel: "praemie*1.08", reihenfolge: 1}}
  ]

  @cmds [
    {:lege_neues_tarifwerk_an, %{tarifwerk_id: 1, name: "Advocard 360 Plus"}},
    {:lege_neuen_tarif_an, %{tarif_id: 1, name: "P"}},
    {:lege_neuen_tarif_an, %{tarif_id: 2, name: "PB"}},
    {:lege_neuen_tarif_an, %{tarif_id: 3, name: "PV"}},
    {:lege_neuen_tarifwerkszuschlag_an, %{zuschlag_id: 1, formel: "praemie*1.5", reihenfolge: 1}},
    {:lege_neuen_tarifwerkszuschlag_an, %{zuschlag_id: 2, formel: "praemie*1.025", reihenfolge: 2}},
    {:lege_neuen_tarifzuschlag_an, %{tarif_id: 1, zuschlag_id: 1, formel: "praemie*1.08", reihenfolge: 1}}
  ]

  def commands do
    Enum.reduce(@cmds, nil, &handle(&2, &1))
    |> Tarifwerk.get_new_events
    |> write_events()
  end

  def load, do: load_events() |> Tarifwerk.from_history()

  defp handle(tarifwerk, cmd) do
    case cmd do
      {:lege_neues_tarifwerk_an, payload} ->
        Tarifwerk.lege_neues_tarifwerk_an(payload)

      {:lege_neuen_tarif_an, payload} ->
        Tarifwerk.lege_neuen_tarif_an(tarifwerk, payload)

      {:lege_neuen_tarifwerkszuschlag_an, payload} ->
        Tarifwerk.lege_neuen_tarifwerkszuschlag_an(tarifwerk, payload)

      {:lege_neuen_tarifzuschlag_an, payload} ->
        Tarifwerk.lege_neuen_tarifzuschlag_an(tarifwerk, payload)

      _ ->
        tarifwerk
    end
  end

  def write_events(events), do: File.write("event_stream", :erlang.term_to_binary(events))

  def load_events() do
    {:ok, content} = File.read("event_stream")
    :erlang.binary_to_term(content)
  end
end
