defmodule MerkmalId do
  defstruct id: nil

  def new(id) when is_number(id) do
    %MerkmalId{id: id}
  end
end

defimpl String.Chars, for: MerkmalId do
  def to_string(thing) do
    Integer.to_string(thing.id)
  end
end
