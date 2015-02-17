=begin
===============================================================================
  地图显示变量 By 喵呜喵5
===============================================================================

【说明】

  在地图上显示变量，支持许多的自定义操作

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5Var20140815] = 20150217;M5script.version(20150211)
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

  VAR      显示的变量的ID（必须填写）
  X        窗口左上角的X坐标
  Y        窗口左上角的Y坐标
  X2       窗口右下角的X坐标
  Y2       窗口右下角的Y坐标
  Z        窗口的Z高度，可以为负数
           高度比较大的窗口将遮住高度比较低的窗口
  HINT1    在变量的数值前面显示的提示文字（前后要加双引号）
  HINT2    在变量的数值后面显示的提示文字（前后要加双引号）
  POSX     窗口文字的起始X坐标
  POSY     窗口文字的起始Y坐标
  BACK     变量窗口的背景图片，文件放在Graphics/System/下（前后要加双引号）
  SX       变量窗口的背景图片X坐标
  SY       变量窗口的背景图片Y坐标
  SWI      窗口的开关ID，当对应ID的开关打开时不显示这个窗口
  INVERSE  当设置为 true 时，对应ID的开关打开时才显示这个窗口
  ONLY     当设置为 true 时，窗口将不显示变量的ID，只显示提示文字
            （不过变量的ID还是需要设置的）
  EVAL     窗口显示的内容变为代码的返回值，VAR属性将被忽略（需要双引号）
            （※ 如果不懂意思的话请不要设置这个属性）
  SCENE    窗口只在特定的场景才显示，如果不懂意思的话请不要设置这个属性

=end

  {
  VAR:   1,
  X:     0,
  X2:    544,
  Y2:    416,
  HINT1: "\\i[10]1号变量的值是",
  HINT2: "的说",
  SWI:   2,
  POSX: 100,
  },

  {
  VAR: 2,
  X2: 544,
  HINT1: "2号变量的\n值是：",
  BACK: "var",
  },

  {
  VAR:     1,
  X:       0,
  HINT1:   "这个是不显示变量数值的窗口\n",
  HINT2:   "仅当2号开关打开时才显示",
  ONLY:    true,
  SWI:     2,
  INVERSE: true,
  },

  {
  EVAL:  "$game_player.x",
  HINT1: "玩家的地图X坐标为：",
  SCENE: Scene_Menu,
  },


  ] # 请不要删除这行

  Z = 200             # 如果窗口遮住其他不希望遮住的内容了，请调小这个数值

  SWI = 1             # 对应ID的开关打开时不显示变量，这个设置优先于各个窗口的设置

    SWI_INVERSE = false  # 设置为 true 时，上方对应ID的开关打开时才显示变量

  SCENE = [Scene_Map] # 需要显示变量窗口的场景，不知道是什么意思的话请不要修改

#==============================================================================
#  设定结束
#==============================================================================
class Window_Var < Window_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def initialize(config,cal)
    get_config(config)
    @size_window = cal
    super(0,0,0,0)
    self.arrows_visible = false
    self.z = Z + @config[:Z]
    self.openness = 0
    create_back_sprite
    update
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的设置
  #--------------------------------------------------------------------------
  def get_config(config)
    @config = config.clone
    @config[:SX] ||= 0
    @config[:SY] ||= 0
    @config[:HINT1] ||= ""
    @config[:HINT2] ||= ""
    @config[:POSX] ||= 0
    @config[:POSY] ||= 0
    @config[:Z] ||= 0
  end
  #--------------------------------------------------------------------------
  # ● 显示窗口的背景
  #--------------------------------------------------------------------------
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
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    return if update_close_judge
    @background_sprite.opacity = 255 if @background_sprite and \
    @background_sprite.opacity != 255
    open if close?
    update_content
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
  # ● 窗口是否应该关闭?
  #--------------------------------------------------------------------------
  def close_judge
    return true if $game_switches[SWI]  && !SWI_INVERSE
    return true if !$game_switches[SWI] &&  SWI_INVERSE
    if @config[:SWI]
      if @config[:INVERSE] then return true if !$game_switches[@config[:SWI]]
      else return true if $game_switches[@config[:SWI]]
      end
    end
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
  # ● 设置计算文字大小的窗口
  #--------------------------------------------------------------------------
  def set_size_window
    size = text_size("口")
    @size_window.font_width = size.width
    @size_window.font_height = size.height
    @size_window.line_height = [line_height, contents.font.size].max
  end
  #--------------------------------------------------------------------------
  # ● 描绘文字
  #--------------------------------------------------------------------------
  def refresh
    if @config[:EVAL] then @cont = eval(@config[:EVAL])
    else @cont = $game_variables[@config[:VAR]]
    end
    @word = "#{@config[:HINT1]}#{@config[:ONLY] ? "" : @cont}#{@config[:HINT2]}"
    set_size_window
    update_placement
    update_position
    contents.clear
    draw_text_ex(@config[:POSX], @config[:POSY], @word)
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口大小
  #--------------------------------------------------------------------------
  def update_placement
    if @config[:X] && @config[:X2]
      self.width = (@config[:X2] - @config[:X]).abs
    else
      self.width  = @size_window.cal_all_text_width(@word)
      self.width += standard_padding * 2
    end
    if @config[:Y] && @config[:Y2]
      self.height = (@config[:Y2] - @config[:Y]).abs
    else
      self.height = @size_window.cal_all_text_height(@word)
      self.height += standard_padding * 2
    end
    create_contents
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口位置
  #--------------------------------------------------------------------------
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
  #--------------------------------------------------------------------------
  # ● 释放窗口
  #--------------------------------------------------------------------------
  def dispose
    super
    @background_sprite.dispose if @background_sprite
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
    return unless m5_20140815_check_scene
    @m5_20140815_cal_size_window = Window_M5CalText.new
    @m5_20140815_var_windows = Array.new(M5Var20140815::VAR_CONFIG.size) do |i|
      config = M5Var20140815::VAR_CONFIG[i]
      next unless config
      next unless config[:VAR] || config[:EVAL]
      next unless m5_20140815_scene_need_show(config[:SCENE])
      M5Var20140815::Window_Var.new(config,@m5_20140815_cal_size_window)
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查是否是指定场景
  #--------------------------------------------------------------------------
  def m5_20140815_check_scene
    M5Var20140815::SCENE.each do |scene|
      return true if SceneManager.scene_is?(scene)
    end
    false
  end
  #--------------------------------------------------------------------------
  # ● 检查场景
  #--------------------------------------------------------------------------
  def m5_20140815_scene_need_show(need = nil)
    return false if need && !SceneManager.scene_is?(need)
    true
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口
  #--------------------------------------------------------------------------
  alias m5_20131103_update update
  def update
    m5_20131103_update
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
end