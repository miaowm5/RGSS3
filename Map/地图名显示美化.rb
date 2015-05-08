=begin
===============================================================================
  地图名显示美化 By喵呜喵5
===============================================================================

【说明】

  修改了默认的地图名显示方式

  地图名的显示支持基本的转义字符，因此可以做出类似：
    地图名：“\i[4]这里是\n[1]的家”
    显示效果：【图标4】这里是艾里克的家
  这样的效果

  使用脚本需要将地图名的背景命名为“mapname”放在 Graphics\System 下

  如果插入了我的基础脚本，可以通过给地图添加备注

    <地图名 地图背景图片的文件名>

  来为某张地图单独设置特定的背景图片（文件同样放在 Graphics\System 下）

=end
$m5script ||= {}; $m5script[:M5MN20150508] = 20150508
module M5MN20150508
#==============================================================================
#  设定部分
#==============================================================================

  DEAFUT = 3
  # 在这里设置地图名的显示模式
  # 1:不显示地图名，2：地图名始终显示，3：一段时间内显示地图名

    TIME = 120
    #这里设置地图名显示模式为3时，地图名停留的时间

  OPTION = 1
  # 在这里设置控制地图名的变量ID
  # 当变量的值分别为1、2、3时地图名显示模式将切换到对应的模式
  # 不需要的话，填写0就好了

  FADE = 40
  # 这里设置地图名进入和离开的时间

  FONT = ["黑体"]
  # 地图名所使用的字体

  SIZE = 20
  # 地图名字体的大小

  COLOR = Color.new(0,0,0, 210)
  # 地图名的颜色，四个数值分别是R、G、B以及透明度

  BOLD = false
  # 地图名是否加粗

  ITALIC = false
  # 地图名是否斜体

  SHADOW = false
  # 地图名是否有阴影

  OUT = true
  # 地图名是否加边框

  OUT_COLOR = Color.new(255, 255, 255, 100)
  # 地图名边框的颜色，四个数值分别是R、G、B以及透明度

  X = 87
  # 这里调整地图名的X坐标

  Y = 12
  # 这里调整地图名的Y坐标

  Z = 200
  # 如果地图名被其他东西遮住或遮住其他东西了，请调整这个数值

#==============================================================================
#  设定结束
#==============================================================================
#--------------------------------------------------------------------------
# ● 新的显示地图窗口类
#--------------------------------------------------------------------------
class Window_MapName < Window_Base
  #--------------------------------------------------------------------------
  # ● 类实例变量
  #--------------------------------------------------------------------------
  class << self; attr_accessor :show_end; end
  #--------------------------------------------------------------------------
  # ● 载入
  #--------------------------------------------------------------------------
  def initialize
    super(Graphics.width, Y, Graphics.width, Graphics.height)
    self.z = Z
    self.opacity = 0
    creat_background_sprite
    update_mode_setting
    clear_all_flag
    if self.class.show_end
      show_final
    else
      open unless @mode == 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 生成背景
  #--------------------------------------------------------------------------
  def creat_background_sprite
    file = get_background_bitmap
    if @background_file != file
      @background_file = file
      @background.dispose if @background
      @background = Sprite.new
      @background.bitmap = Cache.system(file)
      @background.opacity = 0
      @background.z = self.z - 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取背景图片文件名
  #--------------------------------------------------------------------------
  def get_background_bitmap
    if $m5script[:M5Base] && $m5script[:M5Base] >= 20150224
      file = M5script.read_map_note($game_map.map_id, "地图名", nil)
    end
    file ||= "Mapname"
    return file
  end
  #--------------------------------------------------------------------------
  # ● 显示效果遭到意外中断时，直接显示最终画面
  #--------------------------------------------------------------------------
  def show_final
    if @mode == 2
      refresh
      @background.opacity = self.contents_opacity = 255
      self.x = X
      @state = :showing
    else
      close
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    return if $game_map.display_name == ""
    update_mode_setting
    return update_disappear if @state == :disappear
    update_coming if @state == :coming
    @next_time -= 1 if @next_time > 0
    return if @next_time > 0
    update_leaving if @state == :showing
  end
  #--------------------------------------------------------------------------
  # ● 更新显示模式
  #--------------------------------------------------------------------------
  def update_mode_setting
    if OPTION != 0
      mode = $game_variables[OPTION]
      mode = nil unless mode.between?(1,3)
    end
    mode ||= DEAFUT
    if @mode != mode
      @state = :disappear if mode == 1
      refresh if @state == :ready
      @state = :coming if mode != 1
      @mode = mode
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的消失效果
  #--------------------------------------------------------------------------
  def update_disappear
    @background.opacity -= (255 / FADE) * 2
    self.contents_opacity = @background.opacity
    close if @background.opacity == 0
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的进入效果
  #--------------------------------------------------------------------------
  def update_coming
    @background.opacity += 255/FADE
    return unless @background.opacity > 170
    @background.opacity += 255/FADE
    self.contents_opacity += 255/FADE
    self.x = [self.x - Graphics.width/FADE, X].max
    return unless self.x == X && @background.opacity ==255 &&
      self.contents_opacity == 255
    @next_time = TIME
    @state = :showing
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口的离开效果
  #--------------------------------------------------------------------------
  def update_leaving
    return unless @mode == 3
    @background.opacity -= ( 255 / FADE )/2
    self.contents_opacity -= 255 / FADE
    self.x = [self.x + Graphics.width/FADE , Graphics.width].min
    @state = :ready if @background.opacity <= 0
  end
  #--------------------------------------------------------------------------
  # ● 描绘窗口内容
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return if $game_map.display_name == ""
    creat_background_sprite
    contents.font.name = FONT
    contents.font.size = SIZE
    contents.font.bold = BOLD
    contents.font.italic = ITALIC
    contents.font.outline = OUT
    contents.font.shadow = SHADOW
    contents.font.color = COLOR
    contents.font.out_color = OUT_COLOR
    draw_text_ex(0,0, $game_map.display_name)
  end
  #--------------------------------------------------------------------------
  # ● 打开窗口
  #--------------------------------------------------------------------------
  def open
    refresh
    @state = :coming
    self.x = Graphics.width
    self.class.show_end = false
    self
  end
  #--------------------------------------------------------------------------
  # ● 关闭窗口
  #--------------------------------------------------------------------------
  def close
    clear_all_flag
    self
  end
  #--------------------------------------------------------------------------
  # ● 清除窗口的设置
  #--------------------------------------------------------------------------
  def clear_all_flag
    self.x = Graphics.width
    @state = :ready
    @next_time = 0
    self.contents_opacity = @background.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    @background.dispose
  end
end
end # M5MN20150508
class Scene_Map
  #--------------------------------------------------------------------------
  # ● 生成地图窗口（※覆盖了原生窗口）
  #--------------------------------------------------------------------------
  alias m5_20150508_create_location_window create_location_window
  def create_location_window
    m5_20150508_create_location_window
    @map_name_window.dispose
    @map_name_window = M5MN20150508::Window_MapName.new
  end
  #--------------------------------------------------------------------------
  # ● 窗口意外中断时的处理
  #--------------------------------------------------------------------------
  alias m5_20131130_terminate terminate
  def terminate
    m5_20131130_terminate
    M5MN20150508::Window_MapName.show_end = true
  end
end
class << DataManager
  #--------------------------------------------------------------------------
  # ● 关闭窗口意外中断的标志
  #--------------------------------------------------------------------------
  alias m5_20131130_setup_new_game setup_new_game
  def setup_new_game
    m5_20131130_setup_new_game
    M5MN20150508::Window_MapName.show_end = false
  end
  alias m5_20131130_load_game load_game
  def load_game(index)
    result = m5_20131130_load_game(index)
    M5MN20150508::Window_MapName.show_end = false
    return result
  end
end