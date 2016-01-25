=begin
===============================================================================
  事件指令功能加强 By喵呜喵5
===============================================================================

  【说明】

  1.淡入淡出加强——可以控制时间的淡入、淡出
    在事件页的脚本中输入：
      m5_fi(淡入时间)
      m5_fo(淡出时间)
    来进行淡入、淡出


  2.消除图片加强——可以批量消除图片
    在事件页的脚本中输入：
      m5_cp
    可以将屏幕上全部已经显示的图片消除
    输入：
      m5_cp(1,2,3)
    可以将除了编号为1、2、3以外的图片全部消除，依此类推


  3.关闭独立开关——可以批量关闭某张地图上打开的独立开关
    在事件页的脚本中输入：
      m5_c_ss(地图ID)
    可以将对应地图上所有打开的独立开关全部关闭
    输入：
      m5_c_ss(1,[1,2,3],["B","C"])
    可以关闭1号地图除了1、2、3号事件以外不包括独立开关B、C的独立开关，依此类推


  4.等待时间加强——可以突破单次等待的上限或者等待随机时间
    在事件页的脚本中输入：
      m5_wait(时间1,时间2)
    可以在两个时间的范围内随机挑选一个时间执行 等待 指令
    输入：
      m5_wait(等待时间)
    可以等待指定的时间，不受单次等待时间只能为999帧的限制


  5.打开网页/文件（需要基础脚本）——可以打开指定的网址或者指定位置的文件
    在事件页的脚本中输入：
      m5_open_url(网址/文件地址)
    即可打开网页/文件
    网址、地址前后需要加上英文双引号，文件地址中的“\”要换成“/”


  6.生成TXT（需要基础脚本）——可以生成一个TXT文件并在里面写入文字
    在事件页的脚本中输入：
      m5_save_txt(TXT文件名,文字内容,书写方式)
    文件名和文字内容前后要加上英文双引号
    书写方式为0时，若TXT文件已经存在则覆盖对应的TXT文件
    书写方式为1时，若TXT文件已经存在则在TXT文件的结尾追加文字


  7.清除所有变量——将所有变量清除，回归游戏最开始的状态
    在事件页的脚本中输入：
      m5_cv
    可以将全部的变量重置为游戏最开始时的状态
    输入：
      m5_cv(1,2,3)
    可以将除了1、2、3号变量以外的其他变量重置为游戏最开始时的状态


  8.清除所有开关——将所有开关清除，回归游戏最开始的状态
    在事件页的脚本中输入：
      m5_cs
    可以将全部的开关重置为游戏最开始时的状态
    输入：
      m5_cs(1,2,3)
    可以将除了1、2、3号开关以外的其他开关重置为游戏最开始时的状态

  9.执行代码
    在事件页的脚本中输入：
      m5_eval
    若下一个指令是显示滚动文字指令，则会跳过该指令并执行写在滚动文字指令中的代码
    相比于直接用事件脚本执行代码，
    滚动文字指令不会对代码进行强制换行，允许输入的行数也是无限的

=end
#==============================================================================
#  脚本部分
#==============================================================================
$m5script ||= {}; $m5script[:M5Command20140821] = 20150801
module M5Command20140821
  def self.check_basic
    raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
    M5script.version(20150706)
  end
end
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
  def m5_cp(*list)
    screen.pictures.each{ |pic| pic.erase unless list.include?(pic.number) }
  end
  def m5_c_ss(map,ev = [],swi = [])
    $game_self_switches.instance_variable_get("@data").each_key do |key|
      next if key[0] != map
      next if ev.include?(key[1]) || swi.include?(key[2])
      $game_self_switches[key] = false
    end
  end
  def m5_wait(*time)
    time0 = [time.sort![0],0].max
    time1 = time[1] ? [time[1],1].max : time0
    time0 += time[1] ? rand(time1 - time0) : 0
    wait(time0)
  end
  def m5_open_url(addr)
    M5Command20140821.check_basic
    M5script.open_url(addr)
  end
  def m5_save_txt(name,word = "",type = 0)
    M5Command20140821.check_basic
    M5script.creat_text("#{name}.txt",word,type == 0 ? "w+" : "a+")
  end
  def m5_cv(*list)
    value = list.collect {|id| $game_variables[id] }
    $game_variables.instance_variable_set("@data", [])
    list.each_with_index { |id,i| $game_variables[id] = value[i] }
    $game_variables.on_change
  end
  def m5_cs(*list)
    value = list.collect {|id| $game_switches[id] }
    $game_switches.instance_variable_set("@data", [])
    list.each_with_index { |id,i| $game_switches[id] = value[i] }
    $game_switches.on_change
  end
  def m5_eval
    code, @index = '', @index + 1
    while next_event_code == 405
      code += @list[(@index += 1)].parameters[0] + "\n"
    end
    eval(code)
  end
end