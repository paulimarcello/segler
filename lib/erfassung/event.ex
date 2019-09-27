defmodule Event do
  defstruct aggregate_id: nil,
            occured_on: nil,
            payload: nil

  def new(aggregate_id, payload) do
    %Event{aggregate_id: aggregate_id, occured_on: DateTime.utc_now(), payload: payload}
  end
end
