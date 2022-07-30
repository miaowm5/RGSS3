=begin
===============================================================================
  事件指令功能加强 By喵呜喵5
===============================================================================

  【说明】

  针对事件脚本，扩展了多个可用的指令
  以下全部指令使用方式都是在事件页的脚本输入框中输入

===============================================================================

  【淡入淡出加强】可以控制时间的淡入、淡出
    输入：
      m5_command[:淡入, 35]
      m5_command[:淡出, 35]
    可以以 35 帧的速度淡入、淡出画面

    输入：
      m5_command[:放大淡出]
    可以使用放大特效淡出画面。原理是对游戏画面截图后放大，所以放大时会出现画面锯齿
    此指令默认时间为 60 帧，每帧画面放大 0.1 倍
    输入：
      m5_command[:放大淡出, 30, 0.02]
    可以将效果时间修改为 30 帧，每帧画面放大 0.02 倍

===============================================================================

  【消除图片加强】可以批量消除图片
    输入：
      m5_command[:消除图片]
    可以将屏幕上全部已经显示的图片消除
    输入：
      m5_command[:消除图片, 1, 2, 3]
    可以将除了编号为 1、2、3 以外的图片全部消除，依此类推

===============================================================================

  【关闭独立开关】可以批量关闭某张地图上打开的独立开关
    输入：
      m5_command[:关闭独立开关, 1]
    可以将 1 号地图上所有的独立开关全部关闭
    输入：
      m5_command[:关闭独立开关, 1, [2, 3]]
    可以关闭 1 号地图除了 2、3 号事件以外的独立开关，依此类推
    输入：
      m5_command[:清空独立开关]
    可以关闭全部的独立开关
    输入：
      m5_command[:清空独立开关, 1, 2]
    可以关闭除了1、2号地图外其他地图的独立开关，依此类推

===============================================================================

  【等待时间加强】可以突破单次等待的上限或者等待随机时间
    输入：
      m5_command[:等待, 50, 100]
    可以在 50~100 帧之间随机挑选一个时间执行等待指令
    输入：
      m5_command[:等待, 1000]
    可以等待 1000 帧，不受默认事件指令单次等待时间只能为999帧的限制

===============================================================================

  【清空变量/开关】将所有变量/开关清除，回归游戏最开始的状态
    输入：
      m5_command[:清空变量]
    可以将全部的变量重置为游戏最开始时的状态
    输入：
      m5_command[:清空变量, 1, 2, 3]
    可以将除了1、2、3号变量以外的其他变量重置为游戏最开始时的状态
    输入：
      m5_command[:清空开关]
    可以将全部的开关重置为游戏最开始时的状态
    输入：
      m5_command[:清空开关, 1, 2, 3]
    可以将除了1、2、3号开关以外的其他开关重置为游戏最开始时的状态

===============================================================================

  【执行代码】
    输入：
      m5_command[:执行代码]
    若下一个指令是显示滚动文字指令，则会跳过该指令并执行写在滚动文字指令中的代码
    相比于直接用事件脚本执行代码，
    滚动文字指令不会对代码进行强制换行，允许输入的行数也是无限的

===============================================================================

  【打开网页/文件（需要基础脚本）】可以打开指定的网址或者指定位置的文件
    输入：
      m5_command[:打开地址, 网址/文件地址]
    即可打开网页/文件
    网址、地址前后需要加上英文双引号，文件地址中的“\”要换成“/”

===============================================================================

  【生成TXT（需要基础脚本）】可以生成一个TXT文件并在里面写入文字
    输入：
      m5_command[:生成txt, TXT文件名, 文字内容, 书写方式]
    文件名和文字内容前后要加上英文双引号
    书写方式为0时，若TXT文件已经存在则覆盖对应的TXT文件
    书写方式为1时，若TXT文件已经存在则在TXT文件的结尾追加文字

=end
#==============================================================================
#  脚本部分
#==============================================================================
$m5script ||= {}; $m5script[:M5Command20140821] = 20161205
module M5Command20140821
  def self.check_basic
    raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
    M5script.version(20150706)
  end
end
class Game_Interpreter
  def m5_command(debug=false)
    function = {}
    function[:淡入] = ->(time=250) do
      Fiber.yield while $game_message.visible
      screen.start_fadein(time)
      wait(time)
    end
    function[:淡出] = ->(time=250) do
      Fiber.yield while $game_message.visible
      screen.start_fadeout(time)
      wait(time)
    end
    function[:放大淡出] = ->(time=60, power=0.01) do
      sprite = Sprite.new
      sprite.bitmap = Graphics.snap_to_bitmap
      sprite.x = sprite.ox = sprite.bitmap.width  / 2
      sprite.y = sprite.oy = sprite.bitmap.height / 2
      sprite.z = 200
      screen.start_fadeout(1)
      time.times do
        Fiber.yield
        sprite.zoom_x += power
        sprite.zoom_y += power
        sprite.opacity -= 255.0 / time
        Graphics.update
      end
      sprite.bitmap.dispose
      sprite.dispose
    end
    function[:消除图片] = ->(*list) do
      screen.pictures.each{ |pic| pic.erase unless list.include?(pic.number) }
    end
    function[:关闭独立开关] = ->(map,ev = []) do
      $game_self_switches.instance_variable_get("@data").delete_if do |key|
        map == key[0] && !ev.include?(key[1])
      end
      $game_self_switches.on_change
    end
    function[:清空独立开关] = ->(map=[]) do
      $game_self_switches.instance_variable_get("@data").delete_if do |key|
        !map.include?(key[0])
      end
      $game_self_switches.on_change
    end
    function[:等待] = ->(*time) do
      time0 = [time.sort![0],0].max
      time1 = time[1] ? [time[1],1].max : time0
      time0 += time[1] ? rand(time1 - time0) : 0
      wait(time0)
    end
    function[:打开地址] = ->(addr) do
      M5Command20140821.check_basic
      M5script.open_url(addr)
    end
    function[:生成txt] = ->(name,word = "",type = 0) do
      M5Command20140821.check_basic
      M5script.creat_text("#{name}.txt",word,type == 0 ? "w+" : "a+")
    end
    function[:清空变量] = ->(*list) do
      value = list.collect {|id| $game_variables[id] }
      $game_variables.instance_variable_set("@data", [])
      list.each_with_index { |id,i| $game_variables[id] = value[i] }
      $game_variables.on_change
    end
    function[:清空开关] = ->(*list) do
      value = list.collect {|id| $game_switches[id] }
      $game_switches.instance_variable_set("@data", [])
      list.each_with_index { |id,i| $game_switches[id] = value[i] }
      $game_switches.on_change
    end
    function[:执行代码] = ->() do
      code, @index = '', @index + 1
      while next_event_code == 405
        code += @list[(@index += 1)].parameters[0] + "\n"
      end
      eval(code)
    end
    debug && (return function)
    ->(name,*param){ function[name][*param] }
  end
end
