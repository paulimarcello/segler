defmodule Aufbereitung.Model.Tarifwerk do
  defstruct tarife: nil

  def new(tarife) do
    %Tarifwerk{tarife: tarife}
  end
end
