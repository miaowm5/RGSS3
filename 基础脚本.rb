#==============================================================================
# ■ 基础脚本
#------------------------------------------------------------------------------
# 　基础部分的脚本，包含一些简单的方法。部分脚本要求这个基础脚本。
#   请将基础脚本放在我的所有脚本之上。
#==============================================================================

$m5script ||= {}
$m5script["M5Base"] = 20140808
#--------------------------------------------------------------------------
# ● 版本检查
#
#     M5script.version(ver) 检查脚本版本是否高于指定版本
#--------------------------------------------------------------------------
module M5script
  def self.version(ver,hint = "喵呜喵5基础脚本版本过低！",key = "M5Base",h2="")
    raise(h2) unless $m5script[key]
    raise(hint) if (ver > $m5script[key])
  end
end
#--------------------------------------------------------------------------
# ● 读取备注的基本方法
#     note     : 备注文字
#     default  : 缺省值
#--------------------------------------------------------------------------
class RPG::BaseItem
  def m5note(note,default = nil)
    result = /<#{note}\s+(\S+)\s*>/ =~ @note ? $1.to_s : default
    result
  end
end
#--------------------------------------------------------------------------
# ● 自动更新释放的精灵类以及显示端口
#
#     Sprite_M5、Viewport_M5
#--------------------------------------------------------------------------
class Sprite_M5 < Sprite
  def initialize(viewport=nil);super(viewport);end
  def dispose
    bitmap.dispose if bitmap
    super
  end
end
class Viewport_M5 < Viewport
end
class Scene_Base
  alias m5_20140703_update_all_windows update_all_windows
  def update_all_windows
    m5_20140703_update_all_windows
    update_all_m5_sprite
  end
  def update_all_m5_sprite
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.update if ivar.is_a?(Sprite_M5)
    end
  end
  alias m5_20140703_dispose_all_windows dispose_all_windows
  def dispose_all_windows
    m5_20140703_dispose_all_windows
    dispose_all_m5_sprite
  end
  def dispose_all_m5_sprite
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.dispose if ivar.is_a?(Sprite_M5)
      ivar.dispose if ivar.is_a?(Viewport_M5)
    end
  end
end
#--------------------------------------------------------------------------
# ● 绘制EXP槽
#
#     m5_draw_exp_gauge
#--------------------------------------------------------------------------
class Window_Base
  def m5_draw_exp_gauge(actor, x, y, width = 124, vocab = "Exp")
    now_exp = actor.exp - actor.current_level_exp
    next_exp = actor.next_level_exp - actor.current_level_exp    
    draw_gauge(x, y, width, now_exp.to_f/next_exp, m5_exp_gauge_color1, 
      m5_exp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, vocab)
    draw_current_and_max_values(x, y, width, now_exp, next_exp,
      m5_exp_color(actor), normal_color)
  end
  def m5_exp_gauge_color1;tp_gauge_color1;end
  def m5_exp_gauge_color2;tp_gauge_color2;end
  def m5_exp_color(actor);tp_color(actor);end
end
#--------------------------------------------------------------------------
# ● 字体大小调整
#
#     window_font_size 设置默认大小
#     font_size_change 调整文字大小
#--------------------------------------------------------------------------
class Window_Base
  alias m5_20140728_reset_font_settings reset_font_settings
  def reset_font_settings
    m5_20140728_reset_font_settings
    font_size_change
  end
  alias m5_20140728_create_contents create_contents
  def create_contents
    m5_20140728_create_contents
    font_size_change
  end
  def font_size_change(size = window_font_size)
    return unless size
    while text_size("口").width > size
      contents.font.size -= 1
    end
  end
  def window_font_size
    return nil
  end
end
#--------------------------------------------------------------------------
# ● Window_M5CalText
#
#     计算一段文字大小时使用的临时窗口
#     cal_all_text_height(text) 计算总高度
#     cal_all_text_width(text)  计算最大宽度
#     calc_line_width(text)     计算单行宽度
#     font_width                字体的宽度
#     font_height               字体的高度
#--------------------------------------------------------------------------
class Window_M5CalText < Window_Base
  attr_writer :font_width
  attr_writer :font_height
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.visible = false
    @text = ""
    @font_width = nil
    @font_height = nil
  end
  def window_font_size;@font_width;end
  def line_height
    @font_height ? @font_height : super
  end
  def cal_all_text_height(text)
    contents.clear
    reset_font_settings
    @text = text
    all_text_height = 1
    convert_escape_characters(@text).each_line do |line|
      all_text_height += calc_line_height(line, false)
    end
    return all_text_height
  end
  def cal_all_text_width(text)
    contents.clear
    reset_font_settings
    @text = text
    all_text_width = 1
    convert_escape_characters(@text).each_line do |line|
      all_text_width = [all_text_width,calc_line_width(line)].max
    end
    return all_text_width
  end
  def calc_line_width(text)
    contents.clear
    reset_font_settings
    pos = {:x => 0, :y => 0, :new_x => 0, :height => Graphics.height}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
    return pos[:x]
  end
  def process_new_line(text, pos);end
  def draw_text(*args);end
end
#--------------------------------------------------------------------------
# ● 可以设置位置、大小的类原生帮助窗口
#
#     Window_M5Help
#--------------------------------------------------------------------------
class Window_M5Help < Window_Base
  def initialize(line_number = 2, x = 0, y = 0, width = Graphics.width, 
      height = fitting_height(line_number))
    super(x,y,width,height)
  end
  def set_text(text)
    if text != @text
      @text = text
      refresh
    end
  end
  def clear;set_text("");end
  def set_item(item);set_text(item ? item.description : "");end
  def refresh
    contents.clear
    draw_text_ex(4, 0, @text)
  end
end
#--------------------------------------------------------------------------
# ● 获取指定地图特定事件名的事件ID数组
#
#     M5script.match_ev_name(name,id)
#--------------------------------------------------------------------------
module M5script
  def self.match_ev_name(match = "m5",map_id = $game_map.map_id)
    array = []
    map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
    map.events.each_pair {|id,ev| array.push(id) if ev.name == match}
    array
  end
end
