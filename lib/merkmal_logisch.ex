defmodule MerkmalLogisch do
  defstruct id: nil, ist_erfuellt: nil

  @spec new(MerkmalId.t(), boolean) :: MerkmalLogisch.t()
  def new(id, ist_erfuellt) when is_boolean(ist_erfuellt) do
    %MerkmalLogisch{id: id, ist_erfuellt: ist_erfuellt}
  end

  @spec new(MerkmalId.t()) :: MerkmalLogisch.t()
  def new(id) do
    %MerkmalLogisch{id: id, ist_erfuellt: nil}
  end
end
