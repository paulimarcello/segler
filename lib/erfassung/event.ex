defmodule Event do
  defstruct occured_on: nil,
            type: nil,
            payload: nil

  def new(type, payload) do
    %Event{type: type, occured_on: DateTime.utc_now(), payload: payload}
  end
end
