defmodule Test do
  def go do
    cmds = [
      {:lege_neues_tarifwerk_an, {1, "Advocard 360 Plus"}},
      {:lege_neuen_tarif_an, {1, "P"}},
      {:lege_neuen_tarif_an, {2, "PB"}},
      {:lege_neuen_tarif_an, {3, "PV"}},
      {:lege_neuen_tarifwerkszuschlag_an, {1, "praemie*1.5", 1}},
      {:lege_neuen_tarifwerkszuschlag_an, {2, "praemie*1.025", 2}},
      {:lege_neuen_tarifzuschlag_an, {1, 1, "praemie*1.08", 1}}
    ]

    Enum.reduce(cmds, Tarifwerk.new(), &Tarifwerk.handle(&2, &1))
  end
end
