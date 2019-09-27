defmodule Test do
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
    Enum.reduce(@cmds, nil, &CommandHandler.handle(&2, &1))
    |> Tarifwerk.get_new_events()
    |> write_events()
  end

  def load do
    load_events()
    |> Enum.sort(&(&1 < &2))
    |> Tarifwerk.from_history()
  end

  def write_events(events), do: File.write("event_stream", :erlang.term_to_binary(events))

  def load_events() do
    {:ok, content} = File.read("event_stream")
    :erlang.binary_to_term(content)
  end
end
