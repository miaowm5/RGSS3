#==============================================================================
# ■ 基础脚本
#------------------------------------------------------------------------------
#   请将基础脚本放在我的所有脚本之上。
#
#   Tips: 什么是基础脚本？
#
#     这个基础脚本包含我自己的脚本中经常使用的一些【完全相同】的代码
#     虽然不能保证百分百兼容，但是基础脚本中所有的代码都能与大部分脚本和谐共处
#     相应的，如果基础脚本中的某些代码与其他脚本发生了冲突
#     只能证明，我脚本的【思路】和那个脚本【必定会发生冲突】
#     这种情况下，即使我将脚本改写成一个不需要基础脚本的版本，冲突仍然会发生
#
#==============================================================================

$m5script ||= {}
$m5script["M5Base"] = $m5script[:M5Base] = 20150704
#--------------------------------------------------------------------------
# ● 版本检查
#
#     M5script.version(ver) 检查脚本版本是否高于指定版本
#--------------------------------------------------------------------------
module M5script
  def self.version(ver,hint = "喵呜喵5基础脚本版本过低！",key = :M5Base, h2="")
    version = $m5script[key.to_sym] || $m5script[key.to_s] || raise(h2)
    raise(hint) if (ver > version)
  end
  def self.show_error_message(pos="")
    msgbox "当你看到这行信息时，说明您使用的某个喵呜喵5的#{pos}脚本版本太久了"
    msgbox "请检查会导致这个错误的脚本，并及时更新脚本"
    msgbox "如果问题仍然存在，请在对应脚本的下方留言回复"
    exit
  end
end
#--------------------------------------------------------------------------
# ● 匹配文本内容
#
#     M5script.match_text(text, note, default, value, list)
#
#     text     : 文本内容(string)
#     note     : 需要匹配的文字(string)
#     default  : 缺省值(nil)
#     value    : 匹配文字是否需要包含结果(true/false)
#     list     : 是否返回全部匹配结果的数组(false/true)
#--------------------------------------------------------------------------
module M5script
  def self.match_text(text, note, default, value, list, &block)
    return list ? [default] : default if text.empty?
    all_result = []
    text.each_line do |line|
      line.chomp!
      if value
        result = /^\s*<\s*#{note}\s+(\S+)\s*>\s*$/ =~ line ? $1 : nil
        next unless result
        yield(result) if block_given?
        return result unless list
        all_result.push result
      else
        return true if /^\s*<\s*#{note}\s*>\s*$/ =~ line
      end
    end
    all_result.push default if all_result.empty?
    return list ? ( value ? all_result : false ) : default
  end
end
#--------------------------------------------------------------------------
# ● 读取备注
#
#     m5note(note, default, value, list)
#--------------------------------------------------------------------------
class RPG::BaseItem
  def m5note(note, default = nil, value = true, list = false, &block)
    M5script.match_text(@note, note, default, value, list, &block)
  end
end
#--------------------------------------------------------------------------
# ● 读取活动事件页的第一条指令，如果为注释则进行匹配
#
#     M5script.read_event_note(map, id, note, default, value, list)
#--------------------------------------------------------------------------
module M5script
  def self.read_event_note(map, id, note, default = nil, value = true,
      list = false, &block)
    begin
      if map == $game_map.map_id then page = $game_map.events[id]
      else
        ev = load_data(sprintf("Data/Map%03d.rvdata2", map)).events[id]
        page = Game_Event.new(map,ev)
        page.refresh
      end
      return list ? [default] : default if page.empty?
      ev_list = page.list
    rescue
      return list ? [default] : default
    end
    text = ""
    ev_list.each do |command|
      break if command.code != 108 && command.code != 408
      text += command.parameters[0] + "\n"
    end
    M5script.match_text(text, note, default, value, list, &block)
  end
end
#--------------------------------------------------------------------------
# ● 读取地图备注
#
#     M5script.read_map_note(map, note, default, value, list)
#--------------------------------------------------------------------------
module M5script
  def self.read_map_note(map, note, default = nil, value = true,
      list = false, &block)
    text = load_data(sprintf("Data/Map%03d.rvdata2", map)).note
    M5script.match_text(text, note, default, value, list, &block)
  end
end
#--------------------------------------------------------------------------
# ● 精灵 Sprite_M5
#--------------------------------------------------------------------------
class Sprite_M5 < Sprite
  def dispose
    dispose_bitmap
    super
  end
  def dispose_bitmap
  end
end
#--------------------------------------------------------------------------
# ● 显示端口 Viewport_M5
#--------------------------------------------------------------------------
class Viewport_M5 < Viewport
end
#--------------------------------------------------------------------------
# ● 精灵组 Spriteset_M5
#--------------------------------------------------------------------------
class Spriteset_M5
  def update;end;def dispose;end
end
#--------------------------------------------------------------------------
# ● 自动更新释放精灵以及显示端口
#--------------------------------------------------------------------------
class Scene_Base
  alias m5_20141113_update_basic update_basic
  def update_basic
    m5_20141113_update_basic
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.update if ivar.is_a?(Sprite_M5) && !ivar.disposed?
      ivar.update if ivar.is_a?(Spriteset_M5)
    end
  end
  alias m5_20141113_terminate terminate
  def terminate
    m5_20141113_terminate
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.dispose if ivar.is_a?(Sprite_M5)
      ivar.dispose if ivar.is_a?(Spriteset_M5)
      ivar.dispose if ivar.is_a?(Viewport_M5)
    end
  end
end
#--------------------------------------------------------------------------
# ● 获取控制符的参数（这个方法会破坏原始数据）
#
#     m5_obtain_escape_param(text)
#--------------------------------------------------------------------------
class Window_Base
  def m5_obtain_escape_param(text)
    text.slice!(/^\[.*?\]/)[1..-2] rescue ""
  end
end
#--------------------------------------------------------------------------
# ● 绘制值槽
#
#     include M5script::M5_Window_Gauge
#
#     m5_draw_gauge(now, max, vocab, color, x, y, width)
#     color[0]  槽值渐变色
#     color[1]  槽值渐变色
#     color[2]  槽值名称颜色
#     color[3]  槽值当前值颜色
#     color[4]  槽值最大值颜色
#--------------------------------------------------------------------------
module M5script;module M5_Window_Gauge
  def m5_draw_gauge(now, max, vocab, color, x, y, width = 124)
    draw_gauge(x, y, width, [now.to_f/max,1].min, color[0], color[1])
    change_color(color[2])
    draw_text(x, y, 30, line_height, vocab)
    draw_current_and_max_values(x, y, width, now, max, color[3], color[4])
  end
end;end
#--------------------------------------------------------------------------
# ● 绘制图标
#
#     include M5script::M5_Window_Icons
#
#     m5_draw_icons(icons, x, y, width, col, enabled) 多行描绘图标
#--------------------------------------------------------------------------
module M5script;module M5_Window_Icons
  def m5_draw_icons(icons, x, y, width = 96, col = 1, enabled = [])
    col.times do |line|
      temp_icons = icons[width * line / 24, width / 24]
      return unless temp_icons
      temp_icons.each_with_index do |icon_index, pos|
        alpha = enabled[pos + width * line / 24]
        draw_icon(icon_index, x + 24 * pos, y + 24 * line, !alpha)
      end
    end
  end
end;end
#--------------------------------------------------------------------------
# ● 字体大小调整
#
#     include M5script::M5_Window_FontSize
#
#     m5_font_width       默认文字宽度
#     m5_font_height      默认文字高度
#     m5_font_size_change 调整文字大小
#--------------------------------------------------------------------------
module M5script;module M5_Window_FontSize
  def m5_font_size_change(width = m5_font_width, height = m5_font_height)
    contents.font.size = 40
    contents.font.size -= 1 while text_size("口").width > width if width
    contents.font.size -= 1 while text_size("口").height > height if height
  end
  def m5_font_width;  return nil; end
  def m5_font_height; return nil; end
end;end
class Window_Base
  alias m5_20140728_reset_font_settings reset_font_settings
  def reset_font_settings
    m5_20140728_reset_font_settings
    m5_font_size_change if respond_to?(:m5_font_size_change)
  end
  alias m5_20140728_create_contents create_contents
  def create_contents
    m5_20140728_create_contents
    m5_font_size_change if respond_to?(:m5_font_size_change)
  end
end
#--------------------------------------------------------------------------
# ● Window_M5CalText
#
#     计算一段文字大小时使用的临时窗口
#
#     cal_all_text_height(text) 计算总高度
#     cal_all_text_width(text)  计算最大宽度
#     calc_line_width(text)     计算单行宽度
#     m5_contents               要描绘目标文字的contents
#     line_height               设置每行文字的高度
#--------------------------------------------------------------------------
class Window_M5CalText < Window_Base
  attr_writer :line_height, :m5_contents
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.visible = false
    @text = ""
    @line_height = nil
    @m5_contents = nil
  end
  def line_height
    return @line_height if @line_height
    super
  end
  def initialize_contents
    if @m5_contents
      self.contents.dispose
      self.contents = @m5_contents.clone
    end
  end
  def cal_all_text_height(text)
    initialize_contents
    reset_font_settings
    @text = text.clone
    all_text_height = 1
    convert_escape_characters(@text).each_line do |line|
      all_text_height += calc_line_height(line, false)
    end
    @m5_contents = nil
    return all_text_height
  end
  def cal_all_text_width(text)
    initialize_contents
    reset_font_settings
    @text = text.clone
    all_text_width = 1
    convert_escape_characters(@text).each_line do |line|
      all_text_width = [all_text_width,calc_line_width(line,false)].max
    end
    @m5_contents = nil
    return all_text_width
  end
  def calc_line_width(target, need_refresh = true)
    initialize_contents if need_refresh
    reset_font_settings
    text = target.clone
    pos = {:x => 0, :y => 0, :new_x => 0, :height => Graphics.height}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
    @m5_contents = nil if need_refresh
    return pos[:x]
  end
  def process_new_line(text, pos);end
  def draw_text(*args);end
end
#--------------------------------------------------------------------------
# ● 可以设置位置、大小的帮助窗口
#
#     Window_M5Help
#--------------------------------------------------------------------------
class Window_M5Help < Window_Help
  def initialize(line_number = 2, x = 0, y = 0, width = Graphics.width,
      height = fitting_height(line_number))
    super(line_number)
    self.x, self.y ,self.width, self.height = x, y, width, height
    create_contents
  end
end
#--------------------------------------------------------------------------
# ● 生成TXT
#
#     M5script.creat_text(name,word,type)
#--------------------------------------------------------------------------
module M5script
  def self.creat_text(name,word,type = 'w')
    content = File.open("#{name}",type)
    content.puts word
    content.close
  end
end
#--------------------------------------------------------------------------
# ● 打开地址
#
#     M5script.open_url(addr)
#--------------------------------------------------------------------------
module M5script
  def self.open_url(addr)
    api = Win32API.new('shell32.dll','ShellExecuteA','pppppi','i')
    api.call(0,'open',addr,0, 0, 1)
  end
end
#--------------------------------------------------------------------------
# ● 获取未模糊的场景截图
#
#     SceneManager.m5_snapshot_for_background
#     SceneManager.m5_background_bitmap
#--------------------------------------------------------------------------
module SceneManager
  @m5_background_bitmap = nil
  class << self
    attr_reader :m5_background_bitmap
    alias m5_20150211_snapshot_for_background snapshot_for_background
    def snapshot_for_background
      m5_20150211_snapshot_for_background
      m5_snapshot_for_background
    end
    def m5_snapshot_for_background
      @m5_background_bitmap.dispose if @m5_background_bitmap
      @m5_background_bitmap = Graphics.snap_to_bitmap
    end
  end
end
#--------------------------------------------------------------------------
# ● 被删除的旧版方法
#--------------------------------------------------------------------------
class Font
  def m5_return_all_setting; M5script.show_error_message("文字/字体"); end
  def m5_set_all_setting(set); M5script.show_error_message("文字/字体"); end
end
class Window_M5CalText
  def font_width; M5script.show_error_message("对话/信息显示"); end
  def font_height; M5script.show_error_message("对话/信息显示"); end
end