=begin
===============================================================================
  物品添加到菜单选项中 By喵呜喵5
===============================================================================

【说明】

  在菜单选项中添加指定选项，选择该选项即可使用特定的物品


  配合物品使用效果中的“公共事件”以及我的隐藏物品脚本，

  （http://rm.66rpg.com/home.php?mod=space&uid=291206&do=blog&id=11860）

  可以很简单的实现各种各样的效果（例如：通过菜单与队友进行对话）

=end
$m5script ||= {};$m5script[:M5IM20150215] = 20150215
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
    end
    def item; $data_items[@item_id]; end
    def cursor_left?; true; end
    def play_se_for_item; Sound.play_use_item; end
    def show_sub_window(window)
      super(window)
      @status_window.hide
    end
    def hide_sub_window(window)
      super(window)
      @item_window.height = @item_window.window_height
      @item_window.create_contents
      @item_window.refresh
      @status_window.show.refresh
    end
    def use_item
      super
      $game_party.last_item.object = item
      on_actor_cancel
    end
  end
end
class Window_MenuCommand
  alias m5_20150215_add_original_commands add_original_commands
  def add_original_commands
    m5_20150215_add_original_commands
    M5IM20150215::LIST.each do |item|
      name = "m520150215im#{item[1]}".to_sym
      has = $game_party.has_item?($data_items[item[1]])
      if item[2] then add_command(item[0], name, has)
      else add_command(item[0], name) if has
      end
    end
  end
end
class Scene_Menu
  alias m5_20150215_start start
  def start
    m5_20150215_start
    @m520150215SA = M5IM20150215::Scene_ItemTarget.new(self)
    @m520150215SA.create_actor_window
    @m520150215SA.actor_window.hide.deactivate
    M5IM20150215::LIST.each do |item|
      name = "m520150215im#{item[1]}".to_sym
      if !respond_to?(name)
        self.class.class_eval("
        define_method name do
          @m520150215SA.item_id = #{item[1]}
          @m520150215SA.determine_item
        end")
      end
      @command_window.set_handler(name, method(name))
    end
  end
  alias m5_20150215_update update
  def update
    m5_20150215_update
    @m520150215SA.actor_window.update
  end
  alias m5_20150215_terminate terminate
  def terminate
    m5_20150215_terminate
    @m520150215SA.actor_window.dispose
    @m520150215SA.dispose_main_viewport
  end
end