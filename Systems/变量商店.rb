=begin
===============================================================================
  变量商店 By喵呜喵5
===============================================================================

【说明】

  可以使用变量在商店进行购物

  首先先在事件中使用脚本命令输入

    m5_20160528_shop(变量的ID,"变量的名称")

  例如：m5_20160528_shop(1,"节操")

  若事件指令中下一条指令为商店处理，则进入商店时购买物品消耗的是对应的变量

=end
$m5script ||= {}; $m5script[:M5VS20160528] = 20160528
module M5VS20160528
#==============================================================================
#  设定部分
#==============================================================================

  EQUAL = false

  # 设置为 true 时，变量商店物品的出售价格为【数据库中】物品售价的一半
  # 设置为 false 时，变量商店物品的出售价格为【该商店】物品售价的一半
  # (一般来说，个人建议将变量商店请设置为只允许购买)

#==============================================================================
#  设定结束
#==============================================================================
  def self.init; set(0, nil); end
  def self.gold; @data[0]; end
  def self.unit; @data[1]; end
  def self.set(gold, unit); @data = [gold, unit]; end
  def self.work(&block)
    origin_gold = $game_party.gold
    $game_party.m5_20160528_set_gold($game_variables[gold]) if unit
    block.call
    return unless unit
    $game_variables[gold] = $game_party.gold
    $game_party.m5_20160528_set_gold(origin_gold)
  end
end
M5VS20160528.init
class Game_Interpreter
  def m5_20160528_shop(gold, unit)
    return unless next_event_code == 302
    M5VS20160528.set(gold, unit)
    @index += 1
    execute_command
    M5VS20160528.init
  end
end
class Window_Gold
  alias m5_20160528_value value
  def value
    M5VS20160528.unit ? $game_variables[M5VS20160528.gold] : m5_20160528_value
  end
  alias m5_20160528_unit currency_unit
  def currency_unit; M5VS20160528.unit || m5_20160528_unit; end
end
class Game_Party; def m5_20160528_set_gold(gold); @gold = gold; end; end
class Scene_Shop
  alias m5_20140318_do_buy do_buy
  def do_buy(number); M5VS20160528.work{ m5_20140318_do_buy(number) }; end
  alias m5_20140318_do_sell do_sell
  def do_sell(number); M5VS20160528.work{ m5_20140318_do_sell(number) }; end
  alias m5_20140318_selling_price selling_price
  def selling_price
    return m5_20140318_selling_price unless M5VS20160528.unit
    return m5_20140318_selling_price if M5VS20160528::EQUAL
    p = buying_price || 0
    p / 2
  end
end