=begin
===============================================================================
  物品菜单简化 By喵呜喵5
===============================================================================

【说明】

  按照RMVX的方式修改了默认的物品菜单，删除了分类框，默认显示持有的物品

  针对懂得脚本的人，使用

    M5SI20150321.call( 物品分类符号 )

  来调出包含只拥有对应分类物品的界面

  例如：M5SI20150321.call( :weapon ) 可以打开武器物品界面

=end
$m5script ||= {}; $m5script[:M5SI20150321] = 20150321
module M5SI20150321
#==============================================================================
#  设定部分
#==============================================================================

  INCLUDE = true

  # 物品菜单中是否包含重要物品
  # 如果希望普通物品和重要物品不区分对待的话，这里设置成 true

  ALL = false

  # 物品菜单中是否包含所有物品（装备、护甲）
  # 如果希望所有物品都显示在物品界面的话，这里设置成 true

  MENU = false

  # 如果希望在菜单中显示打开其他物品分类的指令的话，这里设置成 true

#==============================================================================
#  设定结束
#==============================================================================
class Scene_M5Item < Scene_Item; def m5_20150321_set; end; end
  def self.call(category)
    SceneManager.call(Scene_M5Item)
    SceneManager.scene.m5_20150321_prepare(category)
  end
end
class Window_ItemList
  alias m5_20131108_include? include?
  def include?(item)
    if @category == :item
      return true if ( item && M5SI20150321::ALL )
      return true if ( item.is_a?(RPG::Item) && M5SI20150321::INCLUDE )
    end
    m5_20131108_include?(item)
  end
end
class Scene_Item
  def m5_20150321_prepare(category = :item)
    @m5_20150321_category = category
  end
  def m5_20150321_set
    m5_20150321_prepare
  end
  alias m5_20150321_start start
  def start
    m5_20150321_start
    m5_20150321_set
    @category_window.select_symbol(@m5_20150321_category)
    @category_window.update
    @category_window.deactivate
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.activate
    @item_window.select_last
  end
  alias m5_20150321_create_category_window create_category_window
  def create_category_window
    m5_20150321_create_category_window
    @category_window.height = 0
  end
end
class Window_MenuCommand
  alias m5_20150321_add_main_commands add_main_commands
  def add_main_commands
    m5_20150321_add_main_commands
    return unless M5SI20150321::MENU
    category_window = Window_ItemCategory.new
    list = category_window.instance_variable_get(:@list)
    list.each do |command|
      next if command[:symbol] == :item
      name = "m5_20150321_#{command[:symbol]}".to_sym
      add_command(command[:name], name ,main_commands_enabled)
      @handler ||= {}
      set_handler(name, Proc.new{ M5SI20150321.call(command[:symbol])})
    end
    category_window.dispose
  end
end