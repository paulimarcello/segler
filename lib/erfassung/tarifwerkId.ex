defmodule TarifwerkId do
  defstruct id: nil

  def new(id) when is_number(id) do
    %TarifwerkId{id: id}
  end
end
