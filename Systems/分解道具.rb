=begin
===============================================================================
  分解道具 By喵呜喵5
===============================================================================

【说明】

  将主角背包里面的武器，防具，道具分解成其他若干道具。
  分解之后，原物品消失，分解后的物品会放入主角的背包中。

  在对应物品的备注栏输入：

    <分解所得 [1,3]>

  则分解该物品可以随机获得 1~3 个的 1 号道具

  在备注栏输入：

    <分解所得 [1,3]>
    <分解所得 [2,4]>

  则分解该物品可以随机获得 1~3 个的 1 号道具 和 1~4 个的 2 号道具

  在事件指令的脚本中输入

    M5DI20160122.call

  来打开分解界面

=end
$m5script ||= {}; raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5DI20160122] = 20160122; M5script.version(20151221)
module M5DI20160122
#==============================================================================
# 设定部分
#==============================================================================

  GOLD = 500

  # 单次分解所需的金钱

  RATE = 0.1

  # 分解获得更多数量道具的几率 + 10%

  SE = 'Bell2'

  # 分解成功时播放的音效，不需要的话填写 nil

  VOCAB = {

    ITEM:   "分解道具",
    WEAPON: "分解武器",
    ARMOR:  "分解防具",

    HINT_HEAD:  "分解成功后将获得",
    HINT_FOOT:  "确定分解吗？",
    HINT_ERROR: "金钱不足",
    HINT_SEP:   "-",
    HINT_UNIT:  "个",

    OK:     "分解",
    CNACEL: "放弃"

  }

  # 用语设定

#==============================================================================
# 设定结束
#==============================================================================

class << self
  def enough_money?; $game_party.gold >= GOLD; end
  def call; SceneManager.call(Scene); end
end

Gold = Class.new(Window_Gold)

class Category < Window_ItemCategory
  def initialize(width)
    @gold_width = width
    super()
  end
  def window_width; Graphics.width - @gold_width; end
  def col_max; return 3; end
  def make_command_list
    add_command(VOCAB[:ITEM], :item)
    add_command(VOCAB[:WEAPON], :weapon)
    add_command(VOCAB[:ARMOR], :armor)
  end
end

class Confirm < Window_HorzCommand
  def initialize(x,y)
    super
    self.openness = 0
    self.z = 300
    self.back_opacity = 230
  end
  def window_width; Graphics.width; end
  def col_max; 2; end
  def make_command_list
    add_command(VOCAB[:OK], :ok, M5DI20160122.enough_money?)
    add_command(VOCAB[:CNACEL], :cancel)
  end
end

class Result < Window_Base
  def initialize(height)
    super(0, 0, Graphics.width, height)
    self.openness = 0
    self.z = 300
    self.back_opacity = 230
  end
  def line_height; super; end
  def draw_line(line, type, data)
    y = line * line_height
    case type
    when 0 then draw_text_ex(0, y, data)
    when 1
      padding = 15
      width = contents.width - padding * 2
      draw_item_name(data[0], padding, y, true, width)
      num = (data[1] == 1 ? "1 " : "1 #{VOCAB[:HINT_SEP]} #{data[1]} ")
      draw_text(padding, y, width, line_height, num + VOCAB[:HINT_UNIT], 2)
    end
    line += 1
  end
  def refresh(data)
    contents.clear
    line = 0
    line = draw_line(line, 0, VOCAB[:HINT_HEAD])
    line = draw_line(line, 0, "")
    data.each {|item| line = draw_line(line, 1, item) }
    line = draw_line(line, 0, "")
    line = draw_line(line, 0,
      M5DI20160122.enough_money? ? VOCAB[:HINT_FOOT] : VOCAB[:HINT_ERROR])
  end
end

class List < Window_ItemList
  def include?(item)
    return item.is_a?(RPG::Item) if @category == :item
    super(item)
  end
  def enable?(item); item; end
  def category=(category)
    return if @category == category
    @m5_data = nil
    super(category)
  end
  def make_item_list
    super
    @m5_data = {} unless @m5_data
    @data.reject! do |item|
      next false if @m5_data[item.id]
      result = item.m5_20160122_decompose_result
      next true unless result
      @m5_data[item.id] = result
      false
    end
    @index = [@index, @data.size - 1].min
  end
  def item_decompose_data
    return [] unless item
    @m5_data[item.id].collect{|id, num| [$data_items[id], num] }
  end
end

class Scene < Scene_MenuBase
  def start
    super
    create_help_window
    create_gold_window
    create_category_window
    create_list_window
    create_confirm_window
    create_result_window
  end
  def create_category_window
    @category_window = Category.new(@gold_window.width)
    @category_window.help_window = @help_window
    @category_window.y = @help_window.height
    @category_window.set_handler(:ok, method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
  end
  def create_gold_window
    @gold_window = Gold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  def create_list_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @item_window = List.new(0, wy, Graphics.width, wh)
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
  end
  def create_confirm_window
    @confirm_window = Confirm.new(0, 0)
    @confirm_window.y = Graphics.height - @confirm_window.height
    @confirm_window.set_handler(:ok,     method(:on_confirm_ok))
    @confirm_window.set_handler(:cancel, method(:on_confirm_cancel))
  end
  def create_result_window
    @result_window = Result.new(Graphics.height - @confirm_window.height)
  end
  def on_category_ok
    @item_window.activate.select(0)
  end
  def on_item_ok
    @result_window.refresh(@item_window.item_decompose_data)
    @result_window.open
    @confirm_window.open.activate.select(0)
  end
  def on_item_cancel
    @item_window.unselect
    @category_window.activate
  end
  def on_confirm_ok
    $game_party.lose_item(@item_window.item, 1)
    @item_window.item_decompose_data.each do |i, n|
      num = n * (rand + RATE)
      num = [[num.round, 1].max, n].min
      $game_party.gain_item(i, num)
    end
    $game_party.lose_gold(GOLD)
    Audio.se_play("Audio/SE/#{SE}") if SE
    @gold_window.refresh
    @item_window.refresh
    on_confirm_cancel
  end
  def on_confirm_cancel
    @result_window.close
    @confirm_window.close
    @item_window.activate
  end
end

end # module M5DI20160122

class RPG::BaseItem
  def m5_20160122_decompose_result
    value = []
    m5note("分解所得",nil,true,true) do |result|
      value << eval(result.gsub(/，/){','})
    end
    value.empty? ? nil : value
  end
end
