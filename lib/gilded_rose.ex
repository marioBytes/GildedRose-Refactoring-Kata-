defmodule GildedRose do
  # Example
  # update_quality([%Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 9, quality: 1}])
  # => [%Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 8, quality: 3}]

  # create constants to avoid any misspellings and help with ease of updating code
  @aged_brie "Aged Brie"
  @backstage_passes "Backstage passes to a TAFKAL80ETC concert"
  @sulfuras "Sulfuras, Hand of Ragnaros"
  @special_items [@aged_brie, @backstage_passes, @sulfuras]
  @highest_quality 50

  def update_quality(items) do
    Enum.map(items, &update_item/1)
  end

  # use reducer functions to make it easier to track bugs down
  def update_item(%Item{} = item) do
    # use 'maybe' function prefix as sell_in or quantity item values
    # are not guaranteed to change
    item
    |> maybe_reduce_sell_in()
    |> maybe_increase_or_degrade_quality()
  end

  # reduce sell_in when item is not sulfuras
  defp maybe_reduce_sell_in(%Item{name: name, sell_in: sell_in} = item) when name != @sulfuras do
    %{item | sell_in: sell_in - 1}
  end

  # sell_in doesn't change for sulfuras
  defp maybe_reduce_sell_in(item) do
    item
  end

  # sulfuras doesn't degrade nor increase
  def maybe_increase_or_degrade_quality(%Item{name: @sulfuras} = item) do
    item
  end

  # aged brie ALMOST always increases in quality
  def maybe_increase_or_degrade_quality(%{name: @aged_brie, quality: quality} = item)
      when quality < @highest_quality do
    increase_item_quality(item, 1)
  end

  # backstage passes quality increases by 1 when there are more than 10 days left
  # or when quantity cannot increase by 2 or 3
  def maybe_increase_or_degrade_quality(
        %{name: @backstage_passes, quality: quality, sell_in: sell_in} = item
      )
      when quality < @highest_quality and sell_in > 10 do
    increase_item_quality(item, 1)
  end

  # backstage passes quality increase by two, have between 11 and 6 days left,
  # and they do not have a quality that would exceed 50
  def maybe_increase_or_degrade_quality(
        %{name: @backstage_passes, quality: quality, sell_in: sell_in} = item
      )
      when quality <= 48 and (sell_in < 11 and sell_in > 5) do
    increase_item_quality(item, 2)
  end

  # backstage passes quality increase by 2 when there are between 11 and 6 days left and cannot exceed 50
  def maybe_increase_or_degrade_quality(
        %{name: @backstage_passes, quality: quality, sell_in: sell_in} = item
      )
      when quality > 48 and (sell_in < 11 and sell_in > 5) do
    manually_set_quality(item, @highest_quality)
  end

  # backstage passes quality increase by 3, have 5 days or less left,
  # and they do not have a quality that would exceed 50
  def maybe_increase_or_degrade_quality(
        %{name: @backstage_passes, quality: quality, sell_in: sell_in} = item
      )
      when quality <= 47 and (sell_in < 6 and sell_in >= 0) do
    increase_item_quality(item, 3)
  end

  # backstage passes quality increase by 3 when there are 5 days or less left and cannot exceed 50
  def maybe_increase_or_degrade_quality(
        %{name: @backstage_passes, quality: quality, sell_in: sell_in} = item
      )
      when quality >= 47 and (sell_in < 6 and sell_in >= 0) do
    manually_set_quality(item, @highest_quality)
  end

  # backstage passes quality degrade to zero after concert
  def maybe_increase_or_degrade_quality(%{name: @backstage_passes, sell_in: sell_in} = item)
      when sell_in < 0 do
    manually_set_quality(item, 0)
  end

  # all other items decrease in quality
  def maybe_increase_or_degrade_quality(
        %Item{name: name, quality: quality, sell_in: sell_in} = item
      )
      when quality > 0 and sell_in >= 0 and name not in @special_items do
    decrease_item_quality(item, 1)
  end

  # all other items decrease by 2 if past sell_in
  def maybe_increase_or_degrade_quality(%Item{name: name, quality: quality} = item)
      when quality > 0 and name not in @special_items do
    decrease_item_quality(item, 2)
  end

  # item quality cannot be negative
  def maybe_increase_or_degrade_quality(%Item{} = item) do
    item
  end

  defp increase_item_quality(%Item{quality: quality} = item, number) when is_integer(number) do
    %{item | quality: quality + number}
  end

  defp decrease_item_quality(%Item{quality: quality} = item, number) when is_integer(number) do
    %{item | quality: quality - number}
  end

  defp manually_set_quality(%Item{} = item, number) do
    %{item | quality: number}
  end
end
