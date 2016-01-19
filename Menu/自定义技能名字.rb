=begin
===============================================================================
  自定义技能名字 By喵呜喵5
===============================================================================

【说明】

  自定义某个技能的名称

  在事件指令的脚本中输入

    M5SN20160119[技能的ID] = "技能的名称"

  可以自定义指定 ID 的技能

  （技能名称前后的英文引号不可省略）

  在事件指令的脚本中输入

    M5SN20160119.set(技能的ID)

  可以调出名称输入界面来让玩家修改对应技能的名字

    M5SN20160119.set(技能的ID, 技能名字的最大长度)

  可以同时设置修改名称输入界面允许输入的技能名字的最大长度

  ※ RM 默认的名字输入窗口在名字长度的处理上存在BUG，因此请尽量不要设置太长的长度

=end
$m5script ||= {}; $m5script[:M5SN20160119] = 20160119
module M5SN20160119
#==============================================================================
# 设定部分
#==============================================================================

  SWI = 0

  # 控制是否显示自定义名称的开关ID，不需要的话这里填0就可以了

  CHAR = 6

  # 名称输入界面技能名的默认最大长度

  FACE_NAME = 'Spiritual'

  # 显示在名称输入界面的脸图的文件名，不需要的话，请填写 ''

  FACE_INDEX = 4

  # 显示在名称输入界面的脸图的位置编号

#==============================================================================
# 脚本部分
#==============================================================================
  class Scene < Scene_Name
    def prepare(skill_id, max_char)
      @skill_id = skill_id
      (actor = RPG::Actor.new).name = $data_skills[@skill_id].name
      actor.face_name, actor.face_index = FACE_NAME, FACE_INDEX
      super($data_actors.size, max_char)
      $data_actors << actor
    end
    def start
      super
      @edit_window.instance_variable_set(:@default_name,
        $data_skills[@skill_id].m5_20160119_name)
    end
    def on_input_ok
      M5SN20160119[@skill_id] = @edit_window.name
      super
      $data_actors.pop
    end
  end
  class << self
    def []=(id,value); $game_system.m5_20160119_skill_name[id] = value; end
    def [](id);        $game_system.m5_20160119_skill_name[id]; end
    def set(id, max = CHAR)
      SceneManager.call(Scene)
      SceneManager.scene.prepare(id, max)
      Fiber.yield
    end
  end
end
class RPG::Skill
  instance_methods(false).include?(:name) || (def name; super; end)
  alias m5_20160119_name name
  def name
    return m5_20160119_name if $game_switches[M5SN20160119::SWI]
    M5SN20160119[id] || m5_20160119_name
  end
end
class Game_System
  attr_reader :m5_20160119_skill_name
  alias m5_20160119_initialize initialize
  def initialize
    m5_20160119_initialize
    @m5_20160119_skill_name = {}
  end
end