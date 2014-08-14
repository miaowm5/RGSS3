=begin
===============================================================================
  地图显示变量 By 喵呜喵5
===============================================================================

【说明】

  在地图上显示变量
  支持许多的自定义操作，
  前提是：
  你要看的懂语死早的我写的使用说明……

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script["M5Base"]
$m5script["M5VAR20140815"] = 20140815;M5script.version(20140815)
module M5VAR20140815
  VAR_CONFIG =[
#==============================================================================
#  设定部分
#==============================================================================
=begin

  每一对大括号对应地图上的一个窗口，中间的内容就是窗口的属性
  具体的格式请参考下面给出的两个范例（※注意每个设置最后的逗号）

  添加内容的格式为：

  需要设置的属性 => 属性的值 ,

  （※注意最后的逗号）

  可以设置的属性如下：

  :VAR      显示的变量的ID（必须填写）
  :X        窗口的X坐标（一个数字）
  :Y        窗口的Y坐标（一个数字）
  :HINT1    在变量的数值前面显示的提示文字（一串文字，前后要加双引号）
  :HINT2    在变量的数值后面显示的提示文字（一串文字，前后要加双引号）
  :BACK     变量窗口的背景图片，文件放在Graphics/System/下
            （文件不存在时窗口只会透明不会报错）（一串文字，前后要加双引号）
  :SWI      窗口的开关，当开关打开时不显示这个窗口（一个数字）
  :ONLY     当设置为 true 时，窗口将不显示变量的ID，只显示提示文字
            （不过变量的ID还是需要设置的）
  :EVAL     窗口显示的内容变为代码的返回值，VAR属性将被忽略（需要双引号）
            （※不建议新手使用）
  :SCENE    窗口只在特定的场景才显示，如果不懂意思的话请不要设置这个属性

  HINT1、HINT2的内容支持转义字符，常用的有以下几个：
  \n        换行
  \\i[n]    显示第n号图标
  \\c[n]    后面的文字颜色变成第n种颜色
  \\{       字体放大
  \\}       字体缩小
  \\v[n]    显示第n号变量的数值
  \\n[n]    显示第n名角色的姓名
  \\p[n]    显示第n名队员的姓名
  \\g       显示货币的单位
=end

  {
  :VAR => 1 ,
  :Y => 280 ,
  :HINT1 => "1号变量的值是" ,
  :HINT2 => "的说" ,
  :SWI => 1,
  },

  {
  :VAR => 2 ,
  :X => 90 ,
  :Y => 120 ,
  :HINT1 => "\\{\\i[10]2号变量的值是：\n" ,
  :BACK => "var",
  },
  
  {
  :EVAL => "$game_player.x" ,
  :HINT1 => "玩家的地图X坐标为：" ,
  :SCENE => Scene_Menu
  },
  

  ] # 请不要删除这行

  Z = 200

  # 如果显示变量的窗口遮住其他不希望遮住的内容了，请调小上面这个数值

  SWI = 1

  # 当下面的开关打开的时候将不在地图上显示变量
  
  SCENE = [Scene_Map]
  
  # 需要显示变量窗口的场景，如果不知道是什么意思的话请不要修改这个设置

#==============================================================================
#  设定结束
#==============================================================================
end
#--------------------------------------------------------------------------
# ● 显示变量的窗口
#--------------------------------------------------------------------------
class Window_M5Var< Window_Base
  include M5VAR20140815
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def initialize(config,cal)
    x,y = get_config(config)
    @cal_size_window = cal
    super(x,y,Graphics.width,Graphics.height)
    self.arrows_visible = false
    self.z = Z
    self.openness = 0
    refresh
    self.height = calheight
    create_back_sprite
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的设置
  #--------------------------------------------------------------------------
  def get_config(config)
    @var = config[:VAR]
    @eval = config[:EVAL]
    x,y = config[:X],config[:Y]
    @hint1,@hint2 = config[:HINT1],config[:HINT2]
    @back = config[:BACK]
    @swi = config[:SWI]
    @only = config[:ONLY]
    @hint1 ||= ""
    @hint2 ||= ""
    @swi ||= 0
    x ||= 0
    y ||= 0
    return x,y
  end
  #--------------------------------------------------------------------------
  # ● 显示窗口的背景
  #--------------------------------------------------------------------------
  def create_back_sprite
    return unless @back
    self.opacity = 0
    return if Dir.glob("Graphics/System/" + @back + ".*").empty?
    @background_sprite = Sprite.new
    @background_sprite.z = self.z - 1
    @background_sprite.bitmap = Cache.system(@back)
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    if $game_switches[SWI] or $game_switches[@swi]
      @background_sprite.opacity = 0 if @background_sprite and \
      @background_sprite.opacity != 0
      close if open?
      return
    end
    @background_sprite.opacity = 255 if @background_sprite and \
    @background_sprite.opacity != 255
    open if close?
    update_content
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口内容
  #--------------------------------------------------------------------------
  def update_content
    if @eval      
      refresh if eval(@eval) != @cont
    else
      refresh if $game_variables[@var] != @cont
    end
  end
  #--------------------------------------------------------------------------
  # ● 描绘文字
  #--------------------------------------------------------------------------
  def refresh
    if @eval
      @cont = eval(@eval)
    else
      @cont = $game_variables[@var]
    end
    @word = "#{@hint1}#{@only ? "" : @cont}#{@hint2}"    
    self.width  = calwidth
    self.height = calheight
    contents.clear
    draw_text_ex(0,-2, @word)
  end
  #--------------------------------------------------------------------------
  # ● 计算窗口的高度
  #--------------------------------------------------------------------------
  def calheight
    @cal_size_window.cal_all_text_height(@word) + standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # ● 计算窗口的宽度
  #--------------------------------------------------------------------------
  def calwidth
    @cal_size_window.cal_all_text_width(@word) + standard_padding * 2    
  end
  #--------------------------------------------------------------------------
  # ● 释放窗口
  #--------------------------------------------------------------------------
  def dispose
    super    
    if @background_sprite
      @background_sprite.bitmap.dispose if @background_sprite.bitmap
      @background_sprite.dispose
    end
  end
end
#--------------------------------------------------------------------------
# ● Scene_Base
#--------------------------------------------------------------------------
class Scene_Base
  alias m5_20131103_start start
  def start
    m5_20131103_start
    @m5_cal_size_window = Window_M5CalText.new
    @m5_var_window = Array.new(M5VAR20140815::VAR_CONFIG.size) do |i|
      next unless M5VAR20140815::VAR_CONFIG[i]
      next unless M5VAR20140815::VAR_CONFIG[i][:VAR] || \
        M5VAR20140815::VAR_CONFIG[i][:EVAL]
      next unless m5_scene_need_show(M5VAR20140815::VAR_CONFIG[i][:SCENE])
      Window_M5Var.new(M5VAR20140815::VAR_CONFIG[i],@m5_cal_size_window)
    end
  end
  def m5_scene_need_show(need = nil)
    return false if need && !SceneManager.scene_is?(need)
    M5VAR20140815::SCENE.each do |scene|
      return true if SceneManager.scene_is?(scene)
    end
    false
  end
  alias m5_20131103_update update
  def update
    m5_20131103_update
    @m5_var_window.each {|window| window.update if window} if @m5_var_window
  end
  alias m5_20131103_terminate terminate
  def terminate
    m5_20131103_terminate
    @m5_var_window.each {|window| window.dispose if window} if @m5_var_window
  end
end
