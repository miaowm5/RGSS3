=begin
===============================================================================
  头像批量修改 By喵呜喵5
===============================================================================

【说明】

  指定的开关打开或者队伍的队长为特定ID的角色时，
  对话中显示头像功能显示的指定头像将批量替换成其他头像

  修改的只是头像素材的文件名而已，头像的位置（这个素材中的第几个头像）并不会改变
  如果连位置都要修改的话……自己给我用PS去调整啦！

=end
$m5script ||= {};$m5script[:M5MF20140805] = 20151021
module M5MF20140805
#==============================================================================
# 设定部分
#==============================================================================

  SWI = [

    [1,"Actor1","Spiritual"],
    [2,"Actor2","Spiritual"],

  ]
  # 设置特定开关打开时需要进行替换的头像，设置格式：
  #  [开关的编号, 需要替换的头像文件名, 用于替换的头像文件名],
  # (文件名的前后需要加上英文的双引号，请不要忘记每条设置最后的逗号)

  LEADER = [

    [1,"Actor1","Spiritual"],
    [2,"Actor2","Spiritual"],

  ]
  # 设置队伍第一名成员为指定角色时需要进行替换的头像，设置格式：
  #  [第一名成员的角色ID, 需要替换的头像文件名, 用于替换的头像文件名],

  STRICT = true
  # 设置为 false 时，脚本将关闭严厉模式
  # 在严厉模式下，【只有】通过显示对话指令显示的脸图将被修改
  # 不使用严厉模式时，其他地方显示的脸图也可能会发生改变（例如菜单中）

#==============================================================================
# 设定结束
#==============================================================================
  def self.check(filename)
    begin
      proc = Proc.new do |list, condition|
        list.each do |data|
          next if filename != data[1]
          next unless condition.call(data[0])
          return data[2]
        end
      end
      proc.call SWI, -> id { $game_switches[id] }
      actor_id = $game_party.members[0].id
      proc.call LEADER, -> id { actor_id == id }
    rescue
      p "头像批量修改脚本出现未知异常"
    end
    filename
  end
end
if M5MF20140805::STRICT
class Game_Interpreter
  alias m5_20140805_command_101 command_101
  def command_101
    @params = @params.clone
    @params[0] = M5MF20140805.check(@params[0])
    m5_20140805_command_101
  end
end
else
class << Cache
  alias m5_20151020_face face
  def face(filename)
    m5_20151020_face M5MF20140805.check(filename)
  end
end
end