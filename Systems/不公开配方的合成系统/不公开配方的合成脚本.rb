=begin
===============================================================================
  不公开配方的合成脚本 By喵呜喵5
===============================================================================

  【说明】

  在个人游戏《尸体未命名》中使用的线索整合系统的原型

  需要搭配《Scene Interpreter》脚本以及一个公共事件来共同使用

  在脚本开头设定完毕后，请去数据库中对应的公共事件里设定合成的配方

=end
$m5script ||= {}; $m5script[:M5Combin20141204] = 20150811
module M5Combin20141204
#==============================================================================
#  设定部分
#==============================================================================

  VAR = 2

  # 脚本需要一个变量来临时储存合成的数据，请填写一个没用的并且不会随便被修改的变量ID

  HINT =<<HINT
\\i[4]请选择需要合成的物品，上下键切换，Z键确定，
X键取消，A键用当前素材开始合成
HINT

  # 在两个HINT之间设置合成界面的操作提示文字

  COMMEN = 1

  # 脚本需要一个公共事件来记录合成的配方，请填写一个公共事件的ID

  NOT = false

  # 填写true的时候，只有备注栏标了<COMBIN>的物品才会出现在合成列表

  DUP = false

  # 填写true的时候，可以使用相同的物品进行合成

#==============================================================================
#  设定结束，接下去请去对应的公共事件中设定合成配方
#==============================================================================
class Window_Help < Window_Base
  def initialize
    super(0, 0, Graphics.width, fitting_height(1))
    set_text(M5Combin20141204::HINT)
  end
  def update
    super
    return if @text.empty?
    return unless Graphics.frame_count % 3 == 0
    process_character(@text.slice!(0, 1), @text, @pos)
  end
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  def clear
    set_text("")
  end
  def refresh
    contents.clear
    @text = convert_escape_characters(@text)
    @pos = {:x => 0, :y => 0, :new_x => 0, :height => calc_line_height(@text)}
  end
end
class Window_List < Window_Selectable
  def initialize(material,x,y,w,h)
    super(x,y,w,h)
    @material = material
    refresh
  end
  def item_max
    @data ? @data.size : 1
  end
  def item
    @data && @index >= 0 ? @data[@index] : nil
  end
  def make_item_list
    @data = []
    @data = $game_party.all_items.select {|item| include?(item)}
  end
  def include?(item)
    v = $game_variables;v[VAR] = [] if !v[VAR].is_a?(Array)
    return false unless item.is_a?(RPG::Item)
    return false if has_choice?(item)
    return has_note?(item)
  end
  def has_choice?(item)
    v = $game_variables
    if DUP
      value1 = v[VAR].clone
      value1.delete(item.id)
      value2 = $game_party.item_number(item)
      return v[VAR].size - value1.size >= value2
    else
      return v[VAR].include?(item.id)
    end
  end
  def has_note?(item)
    return true unless NOT
    item.note.include?("<COMBIN>")
  end
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y, true)
    end
  end
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  def clear
    contents.clear
    self
  end
  def current_item_enabled?
    item
  end
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?        && Input.trigger?(:C)
    return process_cancel   if cancel_enabled?    && Input.trigger?(:B)
    return process_skip     if check_skip
  end
  def check_skip
    return Input.trigger?(:X)
  end
  def process_skip
    deactivate
    call_handler(:skip)
    Input.update
  end
  def activate
    self.arrows_visible = true
    super
  end
  def deactivate
    self.arrows_visible = false
    super
  end
end
end # module M5Combin20141204
class Scene_Combin < Scene_MenuBase
  include M5Combin20141204
  def start
    super
    create_material_window
    create_help_window
    $game_variables[VAR] = []
    update_choice
  end
  def material_ok
    v = $game_variables[VAR]
    v << @material_windows[v.size].item.id
    if v.size == material_max
      $game_temp.reserve_common_event(COMMEN)
      return
    else
      update_choice
    end
    if v.size >= material_min && !@material_windows[v.size].item
      @material_windows[v.size].unselect
      $game_temp.reserve_common_event(COMMEN)
    end
  end
  def material_cancel
    if $game_variables[VAR].size == 0
      return return_scene
    else
      $game_variables[VAR].pop
    end
    update_choice
  end
  def material_skip
    v = $game_variables[VAR]
    if v.size >= material_min - 1
      if @material_windows[v.size].item
        v.push @material_windows[v.size].item.id
      end
      $game_temp.reserve_common_event(COMMEN)
      Sound.play_ok
    else
      Sound.play_buzzer
      update_choice
    end
  end
  def create_help_window
    @help_window = Window_Help.new
  end
  def update_choice
    @material_windows.each(&:deactivate)
    pos = $game_variables[VAR].size
    @material_windows[pos, material_max].each(&:clear)
    @material_windows[pos, material_max].each(&:unselect)
    @material_windows[pos].refresh
    @material_windows[pos].activate.select(0)
  end
  def create_material_window
    @material_windows = Array.new(material_max) do |i|
      Window_List.new(i, m_win_x[i], m_win_y[i],
        m_win_width[i], m_win_height[i])
    end
    @material_windows.each_with_index do |window,i|
      if m_win_skin[i] && m_win_skin[i] != ""
        window.windowskin = Cache.system(m_win_skin[i])
      end
      window.opacity = 0 if m_win_back[i]
      window.set_handler(:ok,     method(:material_ok))
      window.set_handler(:cancel, method(:material_cancel))
      window.set_handler(:skip,   method(:material_skip))
    end
  end
  def material_max; 2; end
  def material_min; material_max; end
  def m_win_x; [0, Graphics.width/2]; end
  def m_win_y; [Graphics.height/2 - 24, Graphics.height/2 - 24]; end
  def m_win_width; [Graphics.width/2, Graphics.width/2]; end
  def m_win_height; [48, 48]; end
  def m_win_skin; ["",""]; end
  def m_win_back; [false,false]; end
  def update_all_windows
    super
    @material_windows.each(&:update)
  end
  def dispose_all_windows
    super
    @material_windows.each(&:dispose)
  end
end
class Game_Interpreter
  def combin(*material)
    v = $game_variables[M5Combin20141204::VAR]
    result = v.sort == material.sort
    if result
      m5_20141204_combin_success
    else
      m5_20141204_combin_fail
    end
    result
  end
  def m5_20141204_combin_success
  end
  def m5_20141204_combin_fail
  end
  def m5_20141204_combin_over
    SceneManager.goto(Scene_Combin)
  end
end