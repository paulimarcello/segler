defmodule Zuschlag do
  defstruct id: nil,
            formel: nil,
            reihenfolge: nil

  def new(id, formel, reihenfolge) do
    %Zuschlag{id: id, formel: formel, reihenfolge: reihenfolge}
  end

  def add_zuschlag(zuschlaege, zuschlag) do
    Enum.sort([zuschlag | zuschlaege], &(&1.reihenfolge < &2.reihenfolge))
  end
end
