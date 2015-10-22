=begin
===============================================================================
  高价回收物品的商店 By喵呜喵5
===============================================================================

【说明】

  指定的开关打开时，事件指令中的商店处理会进入特定的物品回收商店

  在物品回收商店中无法购买物品，只能贩卖物品

  物品的售价则为商店处理中设置的物品价格（而非数据库中设置的价格）

=end
$m5script ||= {}
$m5script[:M5SS20151022] = 20151022
module M5SS20151022
#==============================================================================
# 设定部分
#==============================================================================

  SWI = 1

  #这里设置一个开关ID，当开关打开时使用商店处理将进入物品回收商店

  SHOW1 = true    # true / false

  #设置为true时，在物品回收商店也能以正常价格（原价除2）贩卖没有设置价格的物品

  SHOW2 = false    # true / false

  #设置为true时，在物品回收商店中也会显示玩家不拥有但有设置价格的物品

#==============================================================================
# 设定结束
#==============================================================================
class Sell < Window_ShopSell
  attr_writer :shop_goods
  def initialize *args
    super *args
    @shop_goods = []
  end
  def make_item_list
    @data = []
    @price = {}
    @shop_goods.each do |goods|
      item = ( case goods[0]
               when 0 then $data_items
               when 1 then $data_weapons
               when 2 then $data_armors
               end )[ goods[1] ]
      if item
        next unless include?(item)
        @data << item
        @price[item] = goods[2] == 0 ? item.price : goods[3]
      end
    end
    if SHOW1
      @data += $game_party.all_items.select {|item| include?(item)}
      @data.uniq!
    end
    @data = @data.select{|item| $game_party.has_item?(item)} unless SHOW2
    @data.push(nil) if include?(nil)
  end
  def enable?(item)
    item && (@price[item] ? @price[item] > 0 : item.price > 0) && $game_party.has_item?(item)
  end
end
class Command < Window_ShopCommand
  def col_max; @list.size; end
  def make_command_list
    super
    @list.delete_if { |command| command[:symbol] == :buy }
  end
end
Scene_Clone = Scene_Shop.clone
class Scene_Clone
  Window_ShopCommand = M5SS20151022::Command
  Window_ShopSell = M5SS20151022::Sell
end
class Scene < Scene_Clone
  def create_sell_window
    super
    @sell_window.shop_goods = @goods
  end
  def selling_price; buying_price || super; end
end

end # module M5SS20151022

class Game_Interpreter
  alias m5_20140320_command_302 command_302
  def command_302
    temp_scene = Scene_Shop
    if $game_switches[M5SS20151022::SWI]
      Object.const_set(:Scene_Shop, M5SS20151022::Scene)
      ( @params = @params.clone )[4] = false
    end
    m5_20140320_command_302
    Object.const_set(:Scene_Shop, temp_scene)
  end
end
