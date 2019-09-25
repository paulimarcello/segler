defmodule TarifId do
  defstruct id: 0

  def new(id) when is_number(id) do
    %TarifId{id: id}
  end
end
