defmodule Tarif do
  defstruct id: nil,
            name: nil,
            zuschlaege: []

  def new(id, name) do
    %Tarif{id: id, name: name}
  end

  def add_zuschlag(tarif, zuschlag) do
    %Tarif{tarif | zuschlaege: Zuschlag.add_zuschlag(tarif.zuschlaege, zuschlag)}
  end
end
