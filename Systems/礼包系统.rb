=begin
===============================================================================
  礼包系统 By喵呜喵5
===============================================================================

【说明】

  判断时间究竟过了多久的系统
  可以用来制作在线时长礼包或者每日登陆礼包

  使用事件-条件分支中的脚本命令，输入指定脚本即可判断是否经过了设定的时间

  在事件中使用脚本命令：

  m5_save_time(时间的ID)
    保存当前的时间到指定ID的位置

  在变量操作中使用脚本命令：

  ply_time_judge(时间的ID)
    变量赋值为现在的游戏时间相对于之前经过的长短，
    如果没有储存过之前的时间，自动将当前时间储存到该位置（变量值为0）

  sys_time_judge(时间的ID)
    变量赋值为现在的系统时间相对于之前经过的长短，
    如果没有储存过之前的时间，自动将当前时间储存到该位置（变量值为0）

  在条件分歧中使用脚本命令：

  ply_time_judge(时间的ID,时间长短)
    现在的游戏时间相对于之前是否已经超过了时间长短

  sys_time_judge(时间的ID,时间长短)
    现在的系统时间相对于之前是否已经超过了时间长短

=end
$m5script ||= {};$m5script[:M5TP20150211] = 20150904
module M5TP20150211
#==============================================================================
#  设定部分
#==============================================================================

  VAR = 1

  #这里设置一个没有使用的变量ID，之后请不要更改这个变量的值

#==============================================================================
#  设定结束
#==============================================================================
  def self.get
    v = $game_variables
    v[VAR] = v[VAR].is_a?(Array) ? v[VAR] : Array.new
  end
  def self.judge(id,type,pass)
    time = get[id] || save(id)
    reslut = type ? Time.now - time[0] : $game_system.playtime - time[1]
    return pass ? reslut >= pass.abs : reslut
  end
  def self.save(id = 1); get[id] = [Time.now, $game_system.playtime]; end
  def self.sys(id = 1, pass = nil); judge(id, true, pass); end
  def self.ply(id = 1, pass = nil); judge(id, false, pass); end
end
class Game_Interpreter
  def m5_save_time(id = 1); M5TP20150211.save(id); end
  def sys_time_judge(id = 1, pass = nil); M5TP20150211.sys(id,pass); end
  def ply_time_judge(id = 1, pass = nil); M5TP20150211.ply(id,pass); end
end