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

$m5script ||= {}; $m5script[:ScriptData] ||= {}
$m5script[:M5Base] = 20170304
#--------------------------------------------------------------------------
# ● 版本检查
#
#     M5script.version(ver) 检查脚本版本是否高于指定版本
#--------------------------------------------------------------------------
module M5script
  def self.version(ver,name="基础",key=:M5Base)
    version = $m5script[key.to_sym] || $m5script[key.to_s] ||
      fail("需要喵呜喵5#{name}脚本的支持")
    fail("喵呜喵5#{name}脚本版本过低") if (ver > version)
  end
end
#--------------------------------------------------------------------------
# ● 读取备注、匹配文本
#
#     M5script::M5note.match_text(text, note[, option, &block])
#     匹配文本的基本指令
#
#     text   : 文本内容(String)
#     note   : 需要匹配的文字(String)
#     option : 匹配文本的设置的哈希表
#       :default 缺省值(nil)
#       :value   待匹配文字是否包含内容(true)
#       :list    是否返回全部匹配结果的数组(nil)
#     &block : 成功匹配时执行的回调
#
#     M5script::M5note.map_note(map, note[, option, &block])
#     读取地图备注
#
#     M5script::M5note.event_note(map, id, note[, option, &block])
#     读取活动事件页的第一条指令，如果为注释则进行匹配
#
#--------------------------------------------------------------------------
module M5script; module M5note; class << self
  def match_text(text, note, *option, &block)
    config = option[0].is_a?(Hash) ?
      [option[0][:default], option[0][:value], option[0][:list]] : option
    default, value, list =  *config
    value = true if value.nil?
    return list ? [] : default if text.empty?
    all_result = []
    text.each_line do |line|
      line.chomp!
      if value
        result = /^\s*<\s*#{note}\s+(\S+)\s*>\s*$/ =~ line ? $1 : nil
        next unless result
        yield(result) if block_given?
        return result unless list
        all_result << result
      else
        return true if /^\s*<\s*#{note}\s*>\s*$/ =~ line
      end
    end
    return false unless value
    list ? all_result : default
  end
  def map_note(map, *args)
    text = load_data(sprintf("Data/Map%03d.rvdata2", map)).note
    match_text(text, *args)
  end
  def event_note(map, id, *args)
    begin
      if map == $game_map.map_id then page = $game_map.events[id]
      else
        ev = load_data(sprintf("Data/Map%03d.rvdata2", map)).events[id]
        (page = Game_Event.new(map,ev)).refresh
      end
      page.empty? ? raise : ev_list = page.list
    rescue then return match_text('', *args)
    end
    text = ''
    ev_list.each do |c|
      c.code == 108 || c.code == 408 || break
      text += c.parameters[0] + "\n"
    end
    match_text(text, *args)
  end
end; end; end
#--------------------------------------------------------------------------
# ● 读取物品备注
#--------------------------------------------------------------------------
class RPG::BaseItem
  def m5note *a,&b; M5script::M5note.match_text(@note,*a,&b); end
end
#--------------------------------------------------------------------------
# ● 与旧版基础脚本的兼容
#--------------------------------------------------------------------------
class << M5script
  def match_text *a,&b;      M5script::M5note.match_text *a,&b; end
  def read_map_note *a,&b;   M5script::M5note.map_note *a,&b;   end
  def read_event_note *a,&b; M5script::M5note.event_note *a,&b; end
end
#--------------------------------------------------------------------------
# ● 精灵 Sprite_M5_Base / Sprite_M5
#--------------------------------------------------------------------------
class Sprite_M5_Base < Sprite
  def dispose
    dispose_bitmap
    super
  end
  def dispose_bitmap; end
end
class Sprite_M5 < Sprite_M5_Base; end
#--------------------------------------------------------------------------
# ● 显示端口 Viewport_M5
#--------------------------------------------------------------------------
class Viewport_M5 < Viewport; end
#--------------------------------------------------------------------------
# ● 精灵组 Spriteset_M5
#--------------------------------------------------------------------------
class Spriteset_M5
  def update; end
  def dispose; end
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
      ivar.dispose if ivar.is_a?(Sprite_M5_Base)
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
# ● 字体大小调整
#
#     include M5script::M5_Window_FontSize
#
#     m5_font_width       默认文字宽度
#     m5_font_height      默认文字高度
#     m5_font_size_change 调整文字大小
#--------------------------------------------------------------------------
module M5script; module M5_Window_FontSize
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
# ● M5script::Window_Cal
#
#     计算一段文字大小时使用的临时窗口
#
#     cal_all_text_height(text) 计算总高度
#     cal_all_text_width(text)  计算最大宽度
#     calc_line_width(text)     计算单行宽度
#     m5_contents               要描绘目标文字的contents
#     line_height               设置每行文字的高度
#--------------------------------------------------------------------------
module M5script; class Window_Cal < Window_Base
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
end; end
#--------------------------------------------------------------------------
# ● 自动计算大小和位置并包含背景的信息显示窗口
#
#     M5script::Window_Var
#
#     cal    计算窗口大小使用的临时窗口，M5script::Window_Cal 的实例
#     config 窗口设置的哈希表，使用了以下键值：
#            :X :X2 :Y :Y2 :Z :BACK :SX :SY
#--------------------------------------------------------------------------
module M5script; class Window_Var < Window_Base
  def initialize(config, cal = nil)
    get_config(config)
    @dispose_flag = true unless cal
    @size_window = cal || M5script::Window_Cal.new
    super(0,0,0,0)
    self.arrows_visible = false
    self.z = @config[:Z]
    self.openness = 0
    create_back_sprite
  end
  def get_config(config)
    @config = config.clone
    @config[:SX] ||= 0
    @config[:SY] ||= 0
    @config[:Z] ||= 0
  end
  def create_back_sprite
    return unless @config[:BACK]
    self.opacity = 0
    bitmap = Cache.system(@config[:BACK]) rescue nil
    return unless bitmap
    @background_sprite = Sprite.new
    @background_sprite.x, @background_sprite.y = @config[:SX], @config[:SY]
    @background_sprite.z = self.z - 1
    @background_sprite.bitmap = bitmap
  end
  def update_placement
    if @config[:X] && @config[:X2]
      self.width = (@config[:X2] - @config[:X]).abs
    else
      @size_window.m5_contents = self.contents
      self.width  = @size_window.cal_all_text_width(@word)
      self.width += standard_padding * 2
    end
    if @config[:Y] && @config[:Y2]
      self.height = (@config[:Y2] - @config[:Y]).abs
    else
      @size_window.m5_contents = self.contents
      self.height = @size_window.cal_all_text_height(@word)
      self.height += standard_padding * 2
    end
    create_contents
  end
  def update_position
    if    @config[:X]  then self.x = @config[:X]
    elsif @config[:X2] then self.x = @config[:X2] - self.width
    else                    self.x = 0
    end
    if    @config[:Y]  then self.y = @config[:Y]
    elsif @config[:Y2] then self.y = @config[:Y2] - self.height
    else                    self.y = 0
    end
  end
  def dispose
    super
    @size_window.dispose if @dispose_flag
    @background_sprite.dispose if @background_sprite
  end
end; end
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
# ● 读取、写入Game.ini
#
#     M5script::M5ini.get(key, default_value[, section])
#     M5script::M5ini.write(key, value[, section])
#--------------------------------------------------------------------------
module M5script; module M5ini; class << self
  def filename; './Game.ini'; end
  def default_section; 'M5script'; end
  def get(key, default_value, section = default_section)
    buffer = [].pack('x256')
    api = Win32API.new('kernel32','GetPrivateProfileString','ppppip', 'i')
    l = api.call(section, key, default_value, buffer, buffer.size, filename)
    return buffer[0, l]
  end
  def write(key, value, section = default_section)
    api = Win32API.new('kernel32','WritePrivateProfileString','pppp', 'i')
    api.call(section, key, value.to_s, filename)
  end
end; end; end