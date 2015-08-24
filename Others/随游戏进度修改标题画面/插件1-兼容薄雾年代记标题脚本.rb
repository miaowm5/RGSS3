=begin
===============================================================================
  随游戏进度修改标题画面 插件1-兼容薄雾年代记标题脚本 By喵呜喵5
===============================================================================

【说明】

  令 随游戏进度修改标题画面 By 喵呜喵5 能够与 薄雾年代记标题脚本
   （http://rm.66rpg.com/thread-304811-1-1.html）兼容
  除了 RESOLUTION 和 FOLDER 这两个设定外，其他设定都能通过该插件修改

  该插件的使用和脚本本体相同，在游戏进行中，在事件指令的脚本里输入

    m5t20150320(某个设置的名称)

  标题画面的设置便将转变为该名称所对应的设置

  设置的名称可以与脚本本体相同的情况下，插件与脚本本体的设置同时生效

=end
raise "未检测到随游戏进度修改标题画面脚本" unless $m5script[:M5TC20150320]
raise "随游戏进度修改标题画面脚本版本过低" unless
  $m5script[:M5TC20150320] >= 20150824
LBQ ||= false; raise "未检测到薄雾年代记标题脚本" unless LBQ
raise "未检测到薄雾年代记标题脚本" unless LBQ.const_defined?(:MC_Title)
module M5TC20150320; module Tool1
  SETTING = {
#==============================================================================
#  设定部分
#==============================================================================

  "第一章" =>
  {
    :GRAPHICS => ['Choice','spark','logo','logo'],
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
  # 可以设置的属性如下（设置的格式和用途都与薄雾年代记标题脚本的设置部分相同）：
  #
  # :FADE_SPEED  logo还有选项的淡入速度
  # :MASK_FADE   黑暗层的淡入淡出速度
  # :SHIFT_SPEED 背景滑动速度
  # :GRAPHICS    图像设置
  # :TIME_SPARK  生成一个新的闪光点的间隔时间
  # :BGM_FADE    离开界面的时候的BGM淡出速度
  # :Z_SETTINGS  3个层的Z坐标设定
  # :LIFE_CYCLE  闪光的生命周期

#==============================================================================
#  设定结束
#==============================================================================
  }
  def self.update_title
    lbq = LBQ::MC_Title
    return unless ( set = M5GV20140811.get_ext[:M5TC20150320][:setting_name] )
    return unless ( set = SETTING[set] )
    list = [:FADE_SPEED, :MASK_FADE, :SHIFT_SPEED, :GRAPHICS, :TIME_SPARK,
      :BGM_FADE, :Z_SETTINGS, :LIFE_CYCLE]
    list.each do |name|
      next unless ( value = set[name] )
      lbq.const_set(name, value)
    end
  end
end; end
M5TC20150320::Tool1.update_title