defmodule CommandHandler do
  def handle(tarifwerk, cmd) do
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
end
