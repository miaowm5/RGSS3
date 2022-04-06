=begin
===============================================================================
  LOGO By喵呜喵5
===============================================================================

【说明】

  游戏开始时显示 LOGO

  LOGO 的数量、淡入淡出时间、等待时间、显示 LOGO 时播放的SE都可以自由的设置

=end
$m5script ||= {};$m5script[:M5Logo20141006] = 20220407
module M5Logo20141006
  LIST = [
=begin
#==============================================================================
# 设定部分
#==============================================================================

  下面的每一对大括号对应游戏中的一个 logo，中间的内容就是 logo 的属性
  具体的格式请参考下面给出的范例（※注意每大括号最后的逗号）

  添加内容的格式为：

    需要设置的属性: 属性的值 ,

  （※ 冒号和属性的值之间请加上空格，不要忘记每条设置最后的逗号）

  可以设置的属性如下：

  FILE    logo 的文件名，必须设置
          对应的图片文件放在 Graphics\System 目录下
  SE      出现此 logo 时播放的音效，填写文件名
  FADEIN  淡入动画的播放速度，默认为 10
  FADEOUT 淡出动画的播放速度，默认为 10
  WAIT    logo 从完全出现到开始消失间隔的等待时间
          填写零或负数表示此 logo 不会自动消失，需要玩家按确定键才可以继续
          默认为 120
  NOSKIP  logo 等待消失时，玩家按确定键是否可以跳过等待立刻使 logo 消失
          填写格式为 NOSKIP: true
          不设置表示玩家可以使用确定键跳过此 logo 的等待
          当 WAIT 为负数时，此配置不会生效

=end

    {
      FILE: "LOGO1", # 显示 logo1
      FADEIN: 20,    # 淡入速度为 20
      WAIT: -1,      # 出现后不会自动消失
      FADEOUT: 5,    # 淡出速度为 5
      SE: "Cat",     # logo 出现时播放音效 Cat
    },

    {
      FILE: "LOGO2", # 显示 logo2
      FADEIN: 20,    # 淡入速度为 20
      WAIT: 160,     # 出现后的等待时间为 160
      NOSKIP: true,  # 等待消失时无法通过确定键跳过
    }

  ] # 请不要删除这行

  SKIP = false  # false / true

  # 这里设置为true时，在测试模式下开始游戏不会显示LOGO

#==============================================================================
# 设定结束
#==============================================================================
#--------------------------------------------------------------------------
# ● LOGO精灵的类
#--------------------------------------------------------------------------
class Sprite_Logo < ::Sprite
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize
    super
    @config = nil
  end
  #--------------------------------------------------------------------------
  # ● 显示新的LOGO
  #--------------------------------------------------------------------------
  def new_logo(config)
    return unless config[:FILE]
    @config = config
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    self.bitmap = Cache.system(config[:FILE])
    self.opacity = 0
    @status = [:open]
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    return unless @config
    update_open if @status[0] == :open
    update_wait if @status[0] == :wait
    update_close if @status[0] == :close
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap && !self.bitmap.disposed?
    super
  end
  #--------------------------------------------------------------------------
  # ● 等待LOGO显示结束
  #--------------------------------------------------------------------------
  def update_wait
    if @status[1] <= 0 || !@config[:NOSKIP]
      return @status = [:close] if Input.trigger?(:C)
    end
    if @status[1] > 0
      @status[1] -= 1
      @status = [:close] if @status[1] == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● LOGO 淡入
  #--------------------------------------------------------------------------
  def update_open
    self.opacity += (@config[:FADEIN] || 10).to_i.abs
    if self.opacity == 255
      Audio.se_play("Audio/SE/#{@config[:SE]}",80,100) if @config[:SE]
      @status = [:wait, @config[:WAIT] || 120]
    end
  end
  #--------------------------------------------------------------------------
  # ● LOGO 淡出
  #--------------------------------------------------------------------------
  def update_close
    self.opacity -= (@config[:FADEOUT] || 10).to_i.abs
    @config = nil if self.opacity == 0
  end
  #--------------------------------------------------------------------------
  # ● 判断 LOGO 是否显示完成
  #--------------------------------------------------------------------------
  def finish
    @config == nil
  end
end
#--------------------------------------------------------------------------
# ● 管理 LOGO 状态的类
#--------------------------------------------------------------------------
class Manager
  #--------------------------------------------------------------------------
  # ● 初始化数据
  #--------------------------------------------------------------------------
  def initialize
    @index = 0               # 当前显示的 LOGO 索引
    @current = nil           # 当前显示的 LOGO 数据
    @logo = Sprite_Logo.new  # 显示 LOGO 的精灵
    show_next
  end
  #--------------------------------------------------------------------------
  # ● 更新 logo 状态
  #--------------------------------------------------------------------------
  def update
    exit_logo unless @current
    @logo.update
    show_next if @logo.finish
  end
  #--------------------------------------------------------------------------
  # ● 显示下一个 logo
  #--------------------------------------------------------------------------
  def show_next
    @current = LIST[@index]
    @logo.new_logo(@current) if @current
    @index += 1
  end
  #--------------------------------------------------------------------------
  # ● logo 全部显示完毕，退出界面
  #--------------------------------------------------------------------------
  def exit_logo
    SceneManager.call(SceneManager.m5_20140622_first_scene_class)
  end
  #--------------------------------------------------------------------------
  # ● 释放 logo 精灵
  #--------------------------------------------------------------------------
  def dispose
    @logo.dispose
  end
end
#--------------------------------------------------------------------------
# ● LOGO的场景
#--------------------------------------------------------------------------
class Scene_Logo < ::Scene_Base
  #--------------------------------------------------------------------------
  # ● 载入LOGO管理模块
  #--------------------------------------------------------------------------
  def start
    super
    @m5_20220407_manager = Manager.new
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    @m5_20220407_manager.update
  end
  #--------------------------------------------------------------------------
  # ● 结束处理
  #--------------------------------------------------------------------------
  def terminate
    super
    @m5_20220407_manager.dispose
  end
end

end # module M5Logo20141006

#--------------------------------------------------------------------------
# ● SceneManager - first_scene_class重定义
#--------------------------------------------------------------------------
class << SceneManager
  alias m5_20140622_first_scene_class first_scene_class
  def first_scene_class
    return m5_20140622_first_scene_class if $BTEST
    return m5_20140622_first_scene_class if $TEST && M5Logo20141006::SKIP
    M5Logo20141006::Scene_Logo
  end
end
