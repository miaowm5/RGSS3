=begin
===============================================================================
  事件指令功能加强 By喵呜喵5
===============================================================================

  【说明】
  
  
  《淡入淡出加强》——可以控制时间的淡入、淡出  
  在事件页的脚本中输入：
    m5_fi(淡入时间)
    m5_fo(淡出时间)
  来进行淡入、淡出
  
  
  《消除图片加强》——可以批量消除图片  
  在事件页的脚本中输入：
    m5_cp
  可以将屏幕上全部已经显示的图片消除
  输入：
    m5_cp(1,2,3)
  可以将除了编号为1、2、3以外的图片全部消除，依此类推
  （请注意，脚本调用的方法相对之前的版本发生了改变）
  
  
  《关闭独立开关》——可以批量关闭某张地图上打开的独立开关  
  在事件页的脚本中输入：
    m5_c_ss(地图ID)
  可以将对应地图上所有打开的独立开关全部关闭
  输入：
    m5_c_ss(1,[1,2,3],["B","C"])
  可以关闭1号地图除了1、2、3号事件以外不包括独立开关B、C的独立开关，依此类推
  
  
  《等待时间加强》——可以突破单次等待的上限或者等待随机时间
  在事件页的脚本中输入：
    m5_wait(时间1,时间2)
  可以在两个时间的范围内随机挑选一个时间执行 等待 指令
  输入：
    m5_wait(等待时间)
  可以等待指定的时间，不受单次等待时间只能为999帧的限制
  
  
=end
#==============================================================================
#  脚本部分
#==============================================================================
$m5script ||= {};$m5script["M5CommandSS20140821"] = 20140821
class Game_SelfSwitches;attr_reader :data;end
class Game_Interpreter
  def m5_fi(time = 250)
    Fiber.yield while $game_message.visible
    screen.start_fadein(time)
    wait(time)
  end
  def m5_fo(time = 250)
    Fiber.yield while $game_message.visible
    screen.start_fadeout(time)
    wait(time)
  end
  def m5_cp(*l)
    return
    screen.pictures.each{|picture| picture.erase if !l.include?(picture.number)}
  end
  def m5_c_ss(map,event=[],swi=[])
    $game_self_switches.data.each_key do |key|
      $game_self_switches[key] = false if key[0] == map && \
        !event.include?(key[1]) and !swi.include?(key[2])
    end
  end
  def m5_wait(*time)    
    time0 = [time.sort![0],0].max
    time1 = time[1] ? [time[1],1].max : time0
    time0 += time[1] ? rand(time1 - time0) : 0    
    wait(time0)
  end
end
