defmodule MerkmalId do
  defstruct id: nil

  def new(id) when is_number(id) do
    %MerkmalId{id: id}
  end
end
