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

  def splitte(left, right) do
    cond do
      left == right -> [left]
      left.ist_erfuellt == nil -> beide_logische_auspraegungen(left.id)
      right.ist_erfuellt == nil -> beide_logische_auspraegungen(right.id)
      left.ist_erfuellt -> [left]
    end
  end

  defp beide_logische_auspraegungen(id),
    do: [%MerkmalLogisch{id: id, ist_erfuellt: true}, %MerkmalLogisch{id: id, ist_erfuellt: false}]
end
