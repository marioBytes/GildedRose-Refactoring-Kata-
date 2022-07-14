defmodule GildedRoseTest do
  use ExUnit.Case

  # - Once the sell by date has passed, Quality degrades twice as fast
	# - The Quality of an item is never negative
	# - "Aged Brie" actually increases in Quality the older it gets
	# - The Quality of an item is never more than 50
	# - "Sulfuras", being a legendary item, never has to be sold or decreases in Quality
	# - "Backstage passes", like aged brie, increases in Quality as its SellIn value approaches;
	# Quality increases by 2 when there are 10 days or less and by 3 when there are 5 days or less but
	# Quality drops to 0 after the concert

  @sulfura_item %Item{
    name: "Sulfuras, Hand of Ragnaros",
    sell_in: 25,
    quality: 25
  }
  @aged_brie_item %Item{
    name: "Aged Brie",
    sell_in: 15,
    quality: 30
  }
  @backstage_passes_item %Item{
    name: "Backstage passes to a TAFKAL80ETC concert",
    sell_in: 15,
    quality: 30
  }
  @non_special_item %Item{
    name: "Random Item",
    sell_in: 30,
    quality: 0
  }

  describe "Sulfuras items" do
    test "it never has to be sold" do
      %{sell_in: item_sell_in} = GildedRose.update_item(@sulfura_item)
      assert item_sell_in == 25
    end

    test "it does not degrade nor increase" do
      %{quality: item_quality} = GildedRose.update_item(@sulfura_item)
      assert item_quality == 25
    end
  end

  describe "Aged Brie items" do
    test "it increases in quality the older it gets" do
      %{quality: item_quality} = GildedRose.update_item(@aged_brie_item)
      assert item_quality == 31
    end
  end

  describe "Backstage Passes Item" do
    test "it increases in quality as sell in value approaches" do
      %{quality: item_quality} = GildedRose.update_item(@backstage_passes_item)
      assert item_quality == 31
    end

    test "it increases in quality by two when 10 days or less" do
      item = %{@backstage_passes_item | sell_in: 11}
      %{quality: item_quality} = GildedRose.update_item(item)
      assert item_quality == 32
    end

    test "it increases in quality by three when 5 days or less" do
      item = %{@backstage_passes_item | sell_in: 6}
      %{quality: item_quality} = GildedRose.update_item(item)
      assert item_quality == 33
    end

    test "it drop to 0 quality after concert" do
      item = %{@backstage_passes_item | sell_in: 0}
      %{quality: item_quality} = GildedRose.update_item(item)
      assert item_quality == 0
    end
  end

  describe "Non special items" do
    test "it never has a negative quality" do
      %{quality: item_quality} = GildedRose.update_item(@non_special_item)
      assert item_quality == 0
    end

    test "it never exceeds 50 quality" do
      item = %{@aged_brie_item | quality: 50}
      %{quality: item_quality} = GildedRose.update_item(item)
      assert item_quality == 50
    end

    test "it degrades twice as fast after sell_in" do
      item = %{@non_special_item | sell_in: 0, quality: 10}
      %{quality: item_quality} = GildedRose.update_item(item)
      assert item_quality == 8
    end
  end
end
