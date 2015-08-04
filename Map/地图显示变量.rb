=begin
===============================================================================
  地图显示变量 By 喵呜喵5
===============================================================================

【说明】

  在地图上显示变量，支持许多的自定义操作

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5Var20140815] = 20150803;M5script.version(20150706)
module M5Var20140815;VAR_CONFIG =[
=begin
#==============================================================================
#  设定部分
#==============================================================================

  下面的每一对大括号对应地图上的一个窗口，中间的内容就是窗口的属性
  具体的格式请参考下面给出的范例（※注意每大括号最后的逗号）

  添加内容的格式为：

    需要设置的属性: 属性的值 ,

  （※ 冒号和属性的值之间请加上空格，不要忘记每条设置最后的逗号）

  可以设置的属性如下：

  VAR      要显示的变量的ID
  X        窗口左上角的X坐标
  Y        窗口左上角的Y坐标
  X2       窗口右下角的X坐标
  Y2       窗口右下角的Y坐标
  Z        窗口的Z高度，可以为负数
           高度比较大的窗口将遮住高度比较低的窗口
  HINT1    在变量的数值前面显示的提示文字（前后要加英文引号）
  HINT2    在变量的数值后面显示的提示文字（前后要加英文引号）
  POSX     窗口文字的起始X坐标
  POSY     窗口文字的起始Y坐标
  BACK     窗口的背景图片，文件放在Graphics/System/下（前后要加英文引号）
           文件不存在时，窗口背景透明
  SX       背景图片的X坐标
  SY       背景图片的Y坐标
  SWI      窗口的开关ID，当对应ID的开关打开时不显示这个窗口
  INV_SWI  窗口的开关ID，当对应ID的开关【关闭】时不显示这个窗口
  EVAL     窗口显示的内容变为代码的返回值，VAR属性将被忽略（需要双引号）
           如果不懂意思的话请不要设置这个属性
  SCENE    窗口只在特定的 Scene 才显示，如果不懂意思的话请不要设置这个属性

=end

  {
  VAR:   1,
  X:     0,
  X2:    544,
  Y2:    416,
  HINT1: "\\i[10]1号变量的值是",
  HINT2: "的说（打开2号开关试试？）",
  SWI:   2,
  POSX: 50,
  },

  {
  VAR: 2,
  X2: 544,
  HINT1: "2号变量的\n值是：",
  BACK: "",
  },

  {
  X:       0,
  HINT1:   "这个是不显示变量数值的窗口\n",
  HINT2:   "仅当2号开关打开时才显示",
  INV_SWI:  2,
  },

  {
  EVAL:  "$game_player.x",
  HINT1: "玩家的地图X坐标为：",
  SCENE: Scene_Menu,
  },


  ] # 请不要删除这行

  Z = 200   # 如果窗口遮住其他不希望遮住的内容了，请调小这个数值

  SWI = 1   # 对应ID的开关打开时，关闭本脚本的功能，不在地图上显示变量，
            # 这个全局开关优先于各个窗口单独设置的开关
            # 我的其他需要本脚本支持的脚本也会受到这个开关的影响而失效
            # 如果不需要这个开关的话，这里请填 nil

  INV_SWI = nil  # 对应ID的开关【关闭】时，关闭本脚本的功能，不在地图上显示变量，
                 # 这个全局开关优先于各个窗口单独设置的开关以及上面设置的开关
                 # 我的其他需要本脚本支持的脚本也会受到这个开关的影响而失效
                 # 如果不需要这个开关的话，这里请填 nil

#==============================================================================
#  设定结束
#==============================================================================
class Window_Var < M5script::Window_Var
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def initialize(config,cal)
    super(config,cal)
    update
    refresh if @config[:ONLY]
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的设置
  #--------------------------------------------------------------------------
  def get_config(config)
    super(config)
    @config[:Z] += Z
    @config[:HINT1] ||= ""
    @config[:HINT2] ||= ""
    @config[:POSX] ||= 0
    @config[:POSY] ||= 0
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    return if update_close_judge
    @background_sprite.opacity = 255 if @background_sprite and \
    @background_sprite.opacity != 255
    open if close?
    update_content unless @config[:ONLY]
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的关闭判断
  #--------------------------------------------------------------------------
  def update_close_judge
    if close_judge
      @background_sprite.opacity = 0 if @background_sprite and \
      @background_sprite.opacity != 0
      close if open?
      return true
    end
    false
  end
  #--------------------------------------------------------------------------
  # ● 窗口是否应该关闭? (true:关闭)
  #--------------------------------------------------------------------------
  def close_judge
    return true if INV_SWI && !$game_switches[INV_SWI]
    return true if SWI && $game_switches[SWI]
    return true if @config[:INV_SWI] && !$game_switches[@config[:INV_SWI]]
    return true if @config[:SWI] && $game_switches[@config[:SWI]]
    false
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口内容
  #--------------------------------------------------------------------------
  def update_content
    if @config[:EVAL] then refresh if eval(@config[:EVAL]) != @cont
    else refresh if $game_variables[@config[:VAR]] != @cont
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘文字
  #--------------------------------------------------------------------------
  def refresh
    if @config[:EVAL] then @cont = eval(@config[:EVAL])
    else @cont = $game_variables[@config[:VAR]] rescue 0
    end
    if @config[:ONLY] then @word = "#{@config[:HINT1]}#{@config[:HINT2]}"
    else @word = "#{@config[:HINT1]}#{@cont}#{@config[:HINT2]}"
    end
    update_placement
    update_position
    draw_text_ex(@config[:POSX], @config[:POSY], @word)
  end
end
end # M5Var20140815
#--------------------------------------------------------------------------
# ● Scene_Base
#--------------------------------------------------------------------------
class Scene_Base
  #--------------------------------------------------------------------------
  # ● 生成窗口
  #--------------------------------------------------------------------------
  alias m5_20131103_start start
  def start
    m5_20131103_start
    @m5_20140815_cal_size_window = M5script::Window_Cal.new
    @m5_20140815_var_windows = []
    (M5Var20140815::VAR_CONFIG + self.class.m5_20150517_window).each do |config|
      next unless config
      next unless self.class == (config[:SCENE] ? config[:SCENE] : Scene_Map)
      if !(config[:VAR] || config[:EVAL])
        next unless (config[:HINT1] || config[:HINT2])
        config[:ONLY] = true
      end
      @m5_20140815_var_windows.push(
        M5Var20140815::Window_Var.new(config,@m5_20140815_cal_size_window) )
    end
    @m5_20140815_var_windows.compact!
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口
  #--------------------------------------------------------------------------
  alias m5_20131103_update update
  def update
    m5_20131103_update
    return if scene_changing?
    return unless @m5_20140815_var_windows
    @m5_20140815_var_windows.each {|window| window.update if window}
  end
  #--------------------------------------------------------------------------
  # ● 释放窗口
  #--------------------------------------------------------------------------
  alias m5_20131103_terminate terminate
  def terminate
    m5_20131103_terminate
    return unless @m5_20140815_var_windows
    @m5_20140815_var_windows.each {|window| window.dispose if window}
  end
  #--------------------------------------------------------------------------
  # ● 为其他脚本提供的接口
  #--------------------------------------------------------------------------
  def self.m5_20150517_window(config = nil)
    @m5_20150517_add_window ||= []
    return @m5_20150517_add_window unless config
    hash = { EVAL: "#{config}.text", SCENE: self }
    [:X, :Y, :X2, :Y2, :Z, :BACK, :SX, :SY, :POSX, :POSY, :SWI,
      :INV_SWI].each do |key|
      hash[key] = config.const_get(key) rescue nil
    end
    @m5_20150517_add_window.push hash
  end
end