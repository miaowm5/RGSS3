=begin
===============================================================================
  对话框光标 By喵呜喵5
===============================================================================

【说明】

  允许使用任意图片作为对话框下一句提示的光标

=end
$m5script ||= {};$m5script[:M5MC20140305] = 20140305
module M5MC20140305
#==============================================================================
# 设定部分
#==============================================================================

  FILENAME = "Cursor"

  # 光标图片的文件名，放到Graphics\System文件夹下

  FRAME = 4

  # 光标图片的帧数，只有一张图片并且不需要动画效果这里填写1就好了

  DURA = 10

  # 光标播放动画效果时每张图片的持续时间

  MODE = 2

  # 光标显示模式，1表示固定位置，2表示跟随文字移动

  #当光标显示模式为[固定位置]时：

    POS1 = [491,387]

    # 对话框居下时光标的[X,Y]坐标

    POS2 = [491,239]

    # 对话框居中时光标的[X,Y]坐标

    POS3 = [491,91]

    # 对话框居上时光标的[X,Y]坐标

  #当光标显示模式为[随文字移动]时：

    POSX = 12

    # 光标在左右方向的偏移

    POSY = 12

    # 光标在上下方向的偏移


  Z = 201

  # 光标的Z坐标，当光标遮住某些窗口时请尝试修改这里

  SWI = 1

  # 对应ID的开关打开的时候，不显示光标

#==============================================================================
# 设定结束
#==============================================================================
class Sprite_MessageCursor < Sprite
  def initialize
    super(nil)
    self.z = Z
    self.bitmap = Cache.system(FILENAME)
    self.visible = false
    @duration = @frame = 0
    @width = self.bitmap.width / FRAME
    self.src_rect.set(@frame * @width, 0, @width, self.bitmap.height)
  end
  def update_placement(pos = 2)
    self.x,self.y = pos == 2 ? POS1 : (pos == 1 ? POS2 : POS3)
  end
  def update_placement_plus(orig,pos)
    self.x,self.y = orig
    self.x += pos[:x] + POSX
    self.y += pos[:y] + POSY
  end
  def update
    super
    return unless self.visible
    return @duration -= 1 if @duration > 0
    self.src_rect.set(@frame * @width, 0, @width, self.bitmap.height)
    @duration = DURA
    @frame = (@frame == FRAME - 1) ? 0 : @frame + 1
  end
end
end # M5MC20140305
class Window_Message
  alias m5_20140305_initialize initialize
  def initialize
    m5_20140305_initialize
    @m5_20140305_cursor = M5MC20140305::Sprite_MessageCursor.new
  end
  alias m5_20140305_dispose dispose
  def dispose
    m5_20140305_dispose
    @m5_20140305_cursor.dispose
  end
  alias m5_20140305_update update
  def update
    m5_20140305_update
    @m5_20140305_cursor.update
    return @m5_20140305_cursor.visible = false unless self.open?
    @m5_20140305_cursor.visible = self.pause
    @m5_20140305_cursor.visible = false if $game_switches[M5MC20140305::SWI]
  end
  if M5MC20140305::MODE == 1
    alias m5_20140305_update_placement update_placement
    def update_placement
      m5_20140305_update_placement
      @m5_20140305_cursor.update_placement(@position)
    end
  else # M5MC20140305::MODE != 1
    alias m5_20140416_new_page new_page
    def new_page(text, pos)
      m5_20140416_new_page(text, pos)
      @m5_20140305_cursor.update_placement_plus([self.x,self.y],pos)
    end
    alias m5_20140416_process_normal_character process_normal_character
    def process_normal_character(c, pos)
      m5_20140416_process_normal_character(c, pos)
      @m5_20140305_cursor.update_placement_plus([self.x,self.y],pos)
    end
    alias m5_20140416_process_draw_icon process_draw_icon
    def process_draw_icon(icon_index, pos)
      m5_20140416_process_draw_icon(icon_index, pos)
      @m5_20140305_cursor.update_placement_plus([self.x,self.y],pos)
    end
  end
end