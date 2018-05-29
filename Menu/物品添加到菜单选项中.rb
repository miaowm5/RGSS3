=begin
===============================================================================
  物品添加到菜单选项中 By喵呜喵5
===============================================================================

【说明】

  在菜单选项中添加指定选项，选择该选项即可使用特定的物品

  配合物品使用效果中的“公共事件”以及其他脚本，
  可以很简单的实现添加可执行公共事件的菜单选项的效果

=end
$m5script ||= {};$m5script[:M5IM20150215] = 20180529
module M5IM20150215; LIST = [
#==============================================================================
# 设定部分
#==============================================================================

    ["恢复剂", 1, true],

    ["强恢复剂", 2, false],

    # 设置添加的选项，设置的格式为：

    #   [选项的名称, 选择该选项后使用的物品ID, 未持有该物品时的选项状态],

    # 选项的名称前后要加上英文引号
    # 未持有物品时选项状态设置为 true 时，即使未持有特定物品也显示该物品的选项
    # 未持有物品时选项状态设置为 false 时，不显示未持有物品对应的选项
    # 各个设置之间以及每条设置内容之间需要加上英文逗号分隔

#==============================================================================
# 设定结束
#==============================================================================
  ]
  class Scene_ItemTarget < Scene_ItemBase
    attr_reader :actor_window
    attr_writer :item_id
    def initialize(scene)
      super
      @viewport = Viewport.new
      @item_window = scene.instance_variable_get(:@command_window)
      @status_window = scene.instance_variable_get(:@status_window)
      start
      post_start
      @actor_window.hide.deactivate
    end
    def item; $data_items[@item_id]; end
    def cursor_left?; true; end
    def play_se_for_item; Sound.play_use_item; end
    def show_sub_window(window)
      super(window)
      @status_window.hide if @status_window
    end
    def hide_sub_window(window)
      super(window)
      @item_window.height = @item_window.window_height
      @item_window.create_contents
      @item_window.refresh
      @status_window.show.refresh if @status_window
    end
    def use_item
      super
      on_actor_cancel
    end
    def terminate
      pre_terminate
      @item_window = nil
      @status_window = nil
      super
    end
    def create_background; end
    def dispose_background; end
  end
end
class Window_MenuCommand
  alias m5_20150215_add_original_commands add_original_commands
  def add_original_commands
    m5_20150215_add_original_commands
    M5IM20150215::LIST.each do |item|
      name = "m520150215im#{item[1]}".to_sym
      if $game_party.has_item?($data_items[item[1]])
        add_command(item[0], name)
      elsif item[2] then add_command(item[0], name, false)
      end
    end
  end
end
class Scene_Menu
  alias m5_20150215_start start
  def start
    m5_20150215_start
    @m520150215SA = M5IM20150215::Scene_ItemTarget.new(self)
    M5IM20150215::LIST.each do |item|
      name = "m520150215im#{item[1]}".to_sym
      proc = Proc.new {
        @m520150215SA.item_id = item[1]
        @m520150215SA.determine_item
      }
      @command_window.set_handler(name, proc)
    end
  end
  alias m5_20150215_update update
  def update
    m5_20150215_update
    @m520150215SA.actor_window.update
  end
  alias m5_20150215_terminate terminate
  def terminate
    @m520150215SA.terminate
    m5_20150215_terminate
  end
end
