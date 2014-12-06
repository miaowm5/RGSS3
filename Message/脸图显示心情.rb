=begin
===============================================================================
  脸图显示心情 By喵呜喵5
===============================================================================

【说明】

  在对话中使用转义字符：\mood[心情的名字] 即可在脸图上显示指定的心情图标

  关于心情图标的设置请参考设定部分的说明

  心情的图片素材放在 Graphics\System 目录下

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5FM20141206] = 20141206;M5script.version(20141205)
module M5FM20141206
#==============================================================================
# 设定部分
#==============================================================================

  Z = 201

  # 心情的Z坐标，当心情遮住某些窗口时请尝试修改这里

  LIST = {

  # 按照下面的格式设置对话中显示在脸图上的心情：

  # "心情的名字（不允许重复）" =>  ["心情图标的文件名",
  # [心情图标的动画数目,每张动画显示的时间],
  # [对话框居下时的X坐标,对话框居下时的Y坐标],
  # [对话框居中时的X坐标,对话框居中时的Y坐标],
  # [对话框居上时的X坐标,对话框居上时的Y坐标]],（注意最后的逗号）
  #
  # 例如：
  #
  # "hello" =>  ["Mood",[7,10],[90,300],[90,153],[90,6]] ,
  #
  # 表示名字叫hello的心情素材文件名为Mood，包含7张动画图片，每张图片显示10帧，
  # 对话框居下、中、上时心情的显示位置分别为(90,300)(90,153)(90,6)
  # 之后在对话中输入\mood[hello]就会在对应位置播放设置好的这个心情

  "hello" =>  ["Mood",[7,10],[90,300],[90,153],[90,6]] ,


#==============================================================================
# 设定结束
#==============================================================================
  }
class Sprite_Mood < Sprite
  def initialize
    super(nil)
    self.z = Z
    clear_instance_variables
  end
  def clear_instance_variables
    @duration = @wait = @max_frame = @width = 0
    @frame = 0
    self.bitmap = nil
    self.src_rect.set(Rect.new)
  end
  def set_mood(setting,pos)
    update_placement(setting,pos)
    self.bitmap = Cache.system(setting[0])
    @max_frame , @duration = setting[1]
    @wait = @frame = 0
    @width = self.bitmap.width / @max_frame
  end
  def update_placement(setting,pos)
    self.x,self.y = case pos
                    when 1 then setting[3]
                    when 2 then setting[2]
                    else setting[4]
                    end
  end
  def update
    super
    clear_instance_variables if @frame == @max_frame + 1 and self.bitmap
    return unless self.bitmap
    return (@wait -= 1) if @wait > 0
    self.src_rect.set(@frame * @width, 0, @width, self.bitmap.height)
    @wait = @duration
    @frame += 1
  end
end
end # module M5FM20141206
class Window_Message
  alias m5_20140308_initialize initialize
  def initialize
    m5_20140308_initialize
    @face_mood = M5FM20141206::Sprite_Mood.new
  end
  alias m5_20140308_dispose dispose
  def dispose
    m5_20140308_dispose
    @face_mood.dispose
  end
  alias m5_20140308_update update
  def update
    m5_20140308_update
    @face_mood.update if @face_mood.bitmap
  end
  alias m5_20140308_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'MOOD'
      mood = M5FM20141206::LIST[m5_obtain_escape_param(text)]
      if mood
        @face_mood.set_mood(mood, @position)
        wait(1) until !@face_mood.bitmap
      else
        msgbox "指定的心情不存在！" if $TEST
      end
    else
      m5_20140308_process_escape_character(code, text, pos)
    end
  end
end