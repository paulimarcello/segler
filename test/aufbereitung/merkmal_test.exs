defmodule MerkmalTest do
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  use ExUnit.Case
  use ExUnit.Parameterized

  # --------------------------------------------------------------------------------------------------
  # Split-Logik Logisch
  # --------------------------------------------------------------------------------------------------
  test_with_params "splitte logisch 1 - identisches Merkmal - kein split",
                   fn l, r, _ ->
                     left = Merkmal.new_logisch(1, l)
                     right = Merkmal.new_logisch(1, r)
                     result = Merkmal.splitte(left, right)
                     assert result == [left] and result == [right]
                   end do
    [
      {:erfuellt, :erfuellt, nil},
      {:nicht_erfuellt, :nicht_erfuellt, nil}
    ]
  end

  test "splitte logisch 2 - left egal - 2 auspraegungen" do
    left = Merkmal.new_logisch(1, :egal)
    right = Merkmal.new_logisch(1, :erfuellt)

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_logisch(1, :erfuellt),
             Merkmal.new_logisch(1, :nicht_erfuellt)
           ]
  end

  test "splitte logisch 3 - right egal - 2 auspraegungen" do
    left = Merkmal.new_logisch(1, :erfuellt)
    right = Merkmal.new_logisch(1, :egal)

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_logisch(1, :erfuellt),
             Merkmal.new_logisch(1, :nicht_erfuellt)
           ]
  end

  test_with_params "splitte logisch 4 - egal - immer 2 auspraegungen",
                   fn l, r, _ ->
                     left = Merkmal.new_logisch(1, l)
                     right = Merkmal.new_logisch(1, r)

                     result = Merkmal.splitte(left, right)

                     assert result === [
                              Merkmal.new_logisch(1, :erfuellt),
                              Merkmal.new_logisch(1, :nicht_erfuellt)
                            ]
                   end do
    [
      {:egal, :erfuellt, nil},
      {:egal, :nicht_erfuellt, nil},
      {:erfuellt, :egal, nil},
      {:nicht_erfuellt, :egal, nil},
      {:egal, :egal, nil}
    ]
  end

  test_with_params "splitte logisch 4 - left !== right - left",
                   fn l, r, _ ->
                     left = Merkmal.new_logisch(1, l)
                     right = Merkmal.new_logisch(1, r)

                     result = Merkmal.splitte(left, right)

                     assert result === [left]
                   end do
    [
      {:nicht_erfuellt, :erfuellt, nil},
      {:erfuellt, :nicht_erfuellt, nil}
    ]
  end

  # --------------------------------------------------------------------------------------------------
  # Split-Logik Bereich
  # --------------------------------------------------------------------------------------------------
  @split_merkmal_bereich Merkmal.new_bereich(1, 30, 50)

  test "splitte bereich 1" do
    left = Merkmal.new_bereich(1, 0, 20)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end

  test "splitte bereich 2" do
    left = Merkmal.new_bereich(1, 0, 30)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 0, 29),
             Merkmal.new_bereich(1, 30, 30)
           ]
  end

  test "splitte bereich 3" do
    left = Merkmal.new_bereich(1, 0, 40)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 0, 29),
             Merkmal.new_bereich(1, 30, 40)
           ]
  end

  test "splitte bereich 4" do
    left = Merkmal.new_bereich(1, 0, 50)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 0, 29),
             Merkmal.new_bereich(1, 30, 50)
           ]
  end

  test "splitte bereich 5" do
    left = Merkmal.new_bereich(1, 0, 51)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 0, 29),
             Merkmal.new_bereich(1, 30, 50),
             Merkmal.new_bereich(1, 51, 51)
           ]
  end

  test "splitte bereich 6" do
    left = Merkmal.new_bereich(1, 30, 30)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 30, 30)
           ]
  end

  test "splitte bereich 7" do
    left = Merkmal.new_bereich(1, 30, 40)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 30, 40)
           ]
  end

  test "splitte bereich 8" do
    left = Merkmal.new_bereich(1, 30, 50)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 30, 50)
           ]
  end

  test "splitte bereich 9" do
    left = Merkmal.new_bereich(1, 30, 51)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 30, 50),
             Merkmal.new_bereich(1, 51, 51)
           ]
  end

  test "splitte bereich 10" do
    left = Merkmal.new_bereich(1, 35, 40)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 35, 40)
           ]
  end

  test "splitte bereich 11" do
    left = Merkmal.new_bereich(1, 35, 50)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 35, 50)
           ]
  end

  test "splitte bereich 12" do
    left = Merkmal.new_bereich(1, 35, 51)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 35, 50),
             Merkmal.new_bereich(1, 51, 51)
           ]
  end

  test "splitte bereich 13" do
    left = Merkmal.new_bereich(1, 50, 50)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 50, 50)
           ]
  end

  test "splitte bereich 14" do
    left = Merkmal.new_bereich(1, 50, 51)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [
             Merkmal.new_bereich(1, 50, 50),
             Merkmal.new_bereich(1, 51, 51)
           ]
  end

  test "splitte bereich 15" do
    left = Merkmal.new_bereich(1, 51, 60)
    right = @split_merkmal_bereich

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end

  # --------------------------------------------------------------------------------------------------
  # Split-Logik Auswahl und Selbstbeteiligung
  # --------------------------------------------------------------------------------------------------
  test "splitte auswahl 1" do
    left = Merkmal.new_auswahl(1, [1, 2, 3, 4, 5])
    right = Merkmal.new_auswahl(1, [6])

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end

  test "splitte auswahl 2" do
    left = Merkmal.new_auswahl(1, [1, 2, 3, 4, 5])
    right = Merkmal.new_auswahl(1, [4, 5, 6])

    result = Merkmal.splitte(left, right)

    assert result === [
      Merkmal.new_auswahl(1, [4, 5]),
      Merkmal.new_auswahl(1, [1, 2, 3])
    ]
  end

  test "splitte auswahl 3" do
    left = Merkmal.new_auswahl(1, [])
    right = Merkmal.new_auswahl(1, [6])

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end

  test "splitte auswahl 4" do
    left = Merkmal.new_selbstbeteiligung(1, [1, 2, 3, 4, 5])
    right = Merkmal.new_selbstbeteiligung(1, [])

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end



  test "splitte selbstbeteiligung 1" do
    left = Merkmal.new_selbstbeteiligung(1, [1, 2, 3, 4, 5])
    right = Merkmal.new_selbstbeteiligung(1, [6])

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end

  test "splitte selbstbeteiligung 2" do
    left = Merkmal.new_selbstbeteiligung(1, [1, 2, 3, 4, 5])
    right = Merkmal.new_selbstbeteiligung(1, [4, 5, 6])

    result = Merkmal.splitte(left, right)

    assert result === [
      Merkmal.new_selbstbeteiligung(1, [4, 5]),
      Merkmal.new_selbstbeteiligung(1, [1, 2, 3])
    ]
  end

  test "splitte selbstbeteiligung 3" do
    left = Merkmal.new_selbstbeteiligung(1, [])
    right = Merkmal.new_selbstbeteiligung(1, [6])

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end

  test "splitte selbstbeteiligung 4" do
    left = Merkmal.new_selbstbeteiligung(1, [1, 2, 3, 4, 5])
    right = Merkmal.new_selbstbeteiligung(1, [])

    result = Merkmal.splitte(left, right)

    assert result === [left]
  end
end
