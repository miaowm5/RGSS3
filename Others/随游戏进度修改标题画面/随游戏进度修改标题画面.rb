=begin
===============================================================================
  随游戏进度修改标题画面 By喵呜喵5
===============================================================================

  【说明】

  随着游戏的进行，实时修改标题画面的音乐、选项框的位置等内容
  需要搭配我的全局变量脚本共同使用

  在游戏进行中，在事件指令的脚本里输入

    m5t20150320(某个设置的名称)

  标题画面的设置便将转变为该名称所对应的设置

  (在脚本中更改某个设置后需要再次执行该指令更改的设置才会生效)

=end
$m5script ||= {};$m5script[:M5TC20150320] = 20151106
raise "需要喵呜喵5全局变量脚本的支持" unless $m5script[:M5GV20140811]
raise "喵呜喵5全局变量脚本版本过低" unless $m5script[:M5GV20140811] >= 20151106
module M5TC20150320
  SETTING = {
#==============================================================================
#  设定部分
#==============================================================================

  "DEA" =>
  {
    :x => 0,
    :y => 240,
    :opa => 0,
    :opt_draw_title => false,
  },

  "第一章" =>
  {
    :opa => 255,
    :game_title => "饭粒工程 - 第一章",
    :opt_draw_title => true,
    :title_bgm => 'Theme2',
    :title1_name => '',
    :title2_name => 'Mist',
    :y => 128,
  },

  "第二章" =>
  {
    :game_title => "饭粒工程 - 第二章",
    :opt_draw_title => true,
    :title_bgm => 'Theme3',
    :title_pitch => 120,
    :title1_name => 'Book',
    :title2_name => 'Fire',
    :x => 120,
  },

  # 在这里添加标题画面的设置，设置的格式如下：
  #
  #  "该设置的名称" =>
  #     {
  #       要设置的属性1 => 设置的内容,
  #       要设置的属性2 => 设置的内容,
  #       ...
  #     },
  #
  #（不要忘记前后的中括号以及中间和结尾的英文冒号、英文逗号、英文引号）
  #
  # 可以设置的属性如下（未设置的属性将使用默认的内容）：
  #
  # :game_title       设置标题画面的游戏标题
  # :opt_draw_title   设置是否要绘制游戏标题，true 为绘制，false 为不绘制
  #
  # :title1_name 设置标题画面背景图片的文件名
  # :title2_name 设置标题画面前景图片的文件名
  #
  # :title_bgm    设置标题画面的音乐
  # :title_volume 设置标题画面音乐的音量
  # :title_pitch  设置标题画面音乐的音量
  #
  # :x    设置标题画面选择窗口的 X 坐标
  # :y    设置标题画面选择窗口的 Y 坐标
  # :opa  设置标题画面选择窗口背景的透明度
  #
  #
  # 例如，在上方增加这样一个设置
  #
  #   "miaowm5" =>
  #     {
  #       :x => 233,
  #     }
  #
  # 之后，在游戏的事件指令中执行命令：m5t20150320("miaowm5")
  # 标题画面中选择窗口的 X 坐标便会移动到 233 这个位置
  #
  # 另外，名为 "DEA" 的设置为标题画面的默认设置，
  # 修改 DEA 中的内容可以设置默认情况下标题画面选择框的位置等属性
  # 当某个名称对应的设置不存在时也将优先使用 DEA 中的设置

#==============================================================================
#  设定结束
#==============================================================================
  }
end
class Window_TitleCommand
  alias m5_20140118_initialize initialize
  def initialize
    m5_20140118_initialize
    data = M5GV20140811.get_ext[:M5TC20150320]
    self.opacity = data[:opa] if data[:opa]
    self.x = data[:x] if data[:x]
    self.y = data[:y] if data[:y]
  end
end
class RPG::System
  m5_20150320_method_name = [
    :game_title, :title1_name, :title2_name, :opt_draw_title,:title_bgm
  ]
  m5_20150320_method_name.each do |name|
    alias_name = "m5_20150320_#{name}"
    alias_method alias_name,name
    define_method name do
      value = M5GV20140811.get_ext[:M5TC20150320][name]
      if name == :title_bgm && value && value.is_a?(String)
        set = M5GV20140811.get_ext[:M5TC20150320]
        return RPG::BGM.new(value, set[:title_volume], set[:title_pitch])
      else
        return value ? value : send(alias_name)
      end
    end
  end
end
class Game_Interpreter
  def m5t20150320(name)
    setting = {
      :setting_name => name,
      :game_title => $data_system.m5_20150320_game_title,
      :opt_draw_title => $data_system.m5_20150320_opt_draw_title,
      :title1_name => $data_system.m5_20150320_title1_name,
      :title2_name => $data_system.m5_20150320_title2_name,
      :title_bgm => $data_system.m5_20150320_title_bgm,
      :title_volume => 100,
      :title_pitch => 100,
      :x => nil,
      :y => nil,
      :opa => nil,
    }
    set = M5TC20150320::SETTING["DEA"] || {}
    setting.merge!(set)
    set = M5TC20150320::SETTING[name] || {}
    setting.merge!(set)
    M5GV20140811.set_ext(:M5TC20150320, setting)
  end
end
M5GV20140811.get_ext[:M5TC20150320] ||= M5TC20150320::SETTING["DEA"] || {}