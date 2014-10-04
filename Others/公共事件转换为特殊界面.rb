=begin
===============================================================================
  公共事件转换为特殊界面 By喵呜喵5
===============================================================================

【说明】

  可以将按照指定格式设置的公共事件转换为类似音乐盒、书籍系统这样的特殊界面
  
  ● 特殊规约注意！
  
    将本脚本用于收费游戏前请与我联系。
  
  ● 公共事件的设置格式
  
    请参考范例工程中的1号公共事件
    
  ● 打开对应公共事件转换的界面
  
    在事件指令中的脚本里输入
  
      M5CES20141001.call(公共事件的ID)
      
    或者在设置部分设置将转换的界面添加进菜单后从菜单中打开
  
=end
$m5script ||= {};$m5script[:M5CES20141001] = 20141005
module M5CES20141001
  MENU = [
#==============================================================================
#  设定部分
#==============================================================================

  
  ["人物图鉴",3],["持有道具",4],["音乐欣赏",5],["执行代码",6],
  
  
  # 将转换后的界面加入菜单
  # 设置格式为
  
  #    ["菜单指令名称",对应的公共事件ID],
  
  # 菜单指令的名称前后需要加上英文双引号，结尾需要加上英文逗号
  # 每条设置前后需要加上英文中括号，结尾需要加上英文逗号
  

#==============================================================================
#  设定结束
#==============================================================================
  ]
  def self.call(id = 1)
    SceneManager.call(Scene_M5CES20141001)
    SceneManager.scene.prepare(id)
  end
  def self.refresh
    return unless SceneManager.scene_is?(Scene_M5CES20141001)
    id = SceneManager.scene.ev
    SceneManager.goto(Scene_M5CES20141001)
    SceneManager.scene.prepare(id)
  end
end # module M5CES20141001

module M5CES20141001
  
class Load < Game_Interpreter
  def clear
    super
    @open = []
    @command = []
    @end = []
    @status = :open
  end
  def setup(list)
    super(list, 0)
    update while running?    
    return @open,@command,@end
  end
  def wait_for_message;end
  def run
    wait_for_message    
    while @list[@index] do
      execute_command      
      @index += 1
    end    
    Fiber.yield
    @fiber = nil
  end
  def next_event
    @list[@index + 1]
  end
  def execute_command    
    command = @list[@index]
    @params = command.parameters
    @indent = command.indent
    case @status
    when :open
      if command.code == 112 && @indent == 0
        @open.push RPG::EventCommand.new(0,0,[])
        @status = :command
      else
        @open.push command
      end
    when :command
      if command.code == 413 && @indent == 0
        @status = :end
      end
      if command.code == 111
        method_name = "command_#{command.code}"
        send(method_name) if respond_to?(method_name)
      end
      if command.code == 402
        name = command.parameters[1]
        command_list = []
        while next_event.indent != @indent
          command_list.push next_event
          @index += 1
        end
        command_list.push RPG::EventCommand.new(0,0,[])
        @command.push [name,command_list]
      end
    when :end
      @end.push command
    end
  end
end
  
class Interpreter < Game_Interpreter
  def clear    
    super
    @method_list = nil
  end
  def setup(list, method = nil)
    super(list, 0)
    @method_list = method
    update while running?
  end
  def wait(duration)
    Graphics.wait duration
  end
  def wait_for_message;end
  #--------------------------------------------------------------------------
  # ● 背景卷动
  #--------------------------------------------------------------------------  
  def command_204
    @method_list[:command_204].call(@params[0], @params[1], @params[2])
  end
  #--------------------------------------------------------------------------
  # ● 显示图片
  #--------------------------------------------------------------------------  
  def command_231
    return unless @method_list
    if @params[3] == 0
      x,y = @params[4],@params[5]
    else
      x,y = $game_variables[@params[4]],$game_variables[@params[5]]      
    end
    @method_list[:command_231].call(@params[0],@params[1], @params[2],
      x, y, @params[6], @params[7], @params[8], @params[9])
  end  
  #--------------------------------------------------------------------------
  # ● 消除图片
  #--------------------------------------------------------------------------
  def command_235
    @method_list[:command_235].call(@params[0])    
  end
  #--------------------------------------------------------------------------
  # ● 显示滚动文字
  #--------------------------------------------------------------------------
  def command_105
    return unless @method_list
    message = ""
    while next_event_code == 405
      @index += 1
      message += @list[@index].parameters[0]
      message += "\n"
    end
    @method_list[:command_105].call(message)
  end
  #--------------------------------------------------------------------------
  # ● 脚本
  #--------------------------------------------------------------------------
  def command_355
    script = @list[@index].parameters[0] + "\n"
    while next_event_code == 655
      @index += 1
      script += @list[@index].parameters[0] + "\n"
    end
    @method_list[:command_355].call(script)
  end
end

end # module M5CES20141001
module M5CES20141001
#--------------------------------------------------------------------------
# ● Window_Command
#--------------------------------------------------------------------------
class Window_Command < Window_Command
  attr_accessor :window
  attr_accessor :background
  attr_writer   :update_when_move
  attr_writer   :command
  attr_writer   :cancel_enabled  
  attr_writer   :lr_mode
  def initialize(command,interpreter)
    @command = command
    @interpreter = interpreter
    @window = Window_Status.new
    @background = Plane_Background.new
    @picture_sprites = []
    @update_when_move = @lr_mode = false
    @cancel_enabled = true
    @choose_flag = false
    creat_method_list
    super(0, 0)
    self.index = -1
  end
  def update
    super
    @background.update
  end
  def dispose
    super
    @window.dispose
    @background.bitmap.dispose if @background.bitmap
    @background.dispose
    @picture_sprites.compact.each do |sprite|
      sprite.bitmap.dispose if sprite.bitmap
      sprite.dispose
    end
  end
  def make_command_list
    @command.each do |command|
      add_command(command[0], :nil, true)
    end
  end
  def window_height
    [super,Graphics.height].min
  end
  
  def choose(index)
    return if @choose_flag
    @choose_flag = true
    self.index = [[index,item_max].min,0].max if index
    process_ok if @update_when_move
  end
  def select(pos)
    now_index = index
    super
    return if now_index == index
    process_ok if @update_when_move
  end
  #--------------------------------------------------------------------------
  # ● 光标移动
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    return if index == -1
    super
  end
  alias orign_cursor_up cursor_up
  def cursor_up(wrap = false)
    return if @lr_mode
    orign_cursor_up(wrap)
  end
  alias orign_cursor_down cursor_down
  def cursor_down(wrap = false)
    return if @lr_mode
    orign_cursor_down(wrap)
  end
  def cursor_right(wrap = false)
    return unless @lr_mode
    orign_cursor_down(wrap)
  end
  def cursor_left(wrap = false)
    return unless @lr_mode
    orign_cursor_up(wrap)    
  end
  #--------------------------------------------------------------------------
  # ● 确定、取消键的处理
  #--------------------------------------------------------------------------
  def process_ok
    if current_item_enabled?
      @interpreter.setup(@command[@index][1],@method_list)      
      activate
    end
    self
  end
  def cancel_enabled?; @cancel_enabled; end
  def call_cancel_handler;SceneManager.return;end
  def call_handler_with_param(symbol,param)
    @handler[symbol].call(param) if handle?(symbol)
  end
  #--------------------------------------------------------------------------
  # ● 设置指令
  #--------------------------------------------------------------------------
  def creat_method_list
    @method_list = {}
    self.methods.grep(/^command_(\d+)$/) do
      key = $&.to_sym
      @method_list[key] = method(key)
    end
  end
  def command_204(type,value,speed)
    case type
    when 2 then @background.set_y(- value, speed)
    when 4 then @background.set_x(- value, speed)
    when 6 then @background.set_x(value, speed)
    when 8 then @background.set_y(value, speed)
    end            
  end
  def command_231(num,name,origin,x,y,zoom_x,zoom_y,opacity,type)    
    @picture_sprites[num] ||= Sprite.new
    @picture_sprites[num].bitmap.dispose if @picture_sprites[num].bitmap
    @picture_sprites[num].bitmap = Cache.picture(name)    
    if origin == 0
      @picture_sprites[num].ox = 0
      @picture_sprites[num].oy = 0
    else
      @picture_sprites[num].ox = @picture_sprites[num].bitmap.width / 2
      @picture_sprites[num].oy = @picture_sprites[num].bitmap.height / 2
    end
    @picture_sprites[num].x,@picture_sprites[num].y = x,y    
    @picture_sprites[num].zoom_x = zoom_x / 100.0
    @picture_sprites[num].zoom_y = zoom_y / 100.0
    @picture_sprites[num].opacity = opacity
    @picture_sprites[num].blend_type = type
    @picture_sprites[num].z = 50 + num + 1
  end
  def command_235(num)
    @picture_sprites[num] ||= Sprite.new
    @picture_sprites[num].bitmap.dispose if @picture_sprites[num].bitmap
  end
  def command_105(string)
    @window.refresh string
  end
  def command_355(script)
    eval(script)
  end  
end
#--------------------------------------------------------------------------
# ● Window_Status
#--------------------------------------------------------------------------
class Window_Status < Window_Base
  def initialize
    super(160, 0, Graphics.width - 160, Graphics.height)
  end
  def refresh(text = "")
    contents.clear
    draw_text_ex(4, 0, text)
  end
  def create_contents
    super;self
  end
end
#--------------------------------------------------------------------------
# ● Plane_Background
#--------------------------------------------------------------------------
class Plane_Background < Plane
  def initialize
    super
    @x = @y = @update_x = @update_y = 0    
  end
  def update    
    return unless self.bitmap
    @x += @update_x
    @y += @update_y
    self.ox, self.oy = @x, @y
  end
  def set_x(x, speed)
    @x = self.ox
    @update_x = move_speed(x, speed)
  end
  def set_y(y, speed)
    @y = self.oy
    @update_y = move_speed(y, speed)
  end
  def move_speed(value,speed)
    case speed
    when 1 then return value.to_f / 8
    when 2 then return value.to_f / 4
    when 3 then return value.to_f / 2
    when 4 then return value.to_f * 1
    when 5 then return value.to_f * 2
    when 6 then return value.to_f * 4
    end    
  end
end
  
end # module M5CES20141001

#--------------------------------------------------------------------------
# ● Scene_M5CES20141001
#--------------------------------------------------------------------------
class Scene_M5CES20141001 < Scene_MenuBase
  attr_reader :ev
  def prepare(id);@ev = id;end
  def start
    super
    @interpreter = M5CES20141001::Interpreter.new
    @window = M5CES20141001::Window_Command.new(load_events(@ev),@interpreter)    
    @bgm = RPG::BGM.last
    @bgs = RPG::BGS.last
    @default_choose = 0
    creat_method_list
    @interpreter.setup(@open_command,@method_list)    
    @window.command = load_events(@ev)
    @window.refresh
    @window.window.create_contents
    Input.update
    @window.choose(@default_choose)
  end
  def terminate
    @interpreter.setup(@end_command,@method_list)    
    super
  end
  def creat_method_list
    @method_list = {}
    @window.methods.grep(/^command_(\d+)$/) do
      key = $&.to_sym
      @method_list[key] = @window.method(key)
    end
    @method_list[:command_355] = method(:command_355)
  end
  def command_355(script)
    eval(script)
  end
  def load_events(id)
    ev = $data_common_events[id]
    raise "公共事件读取失败！" unless ev
    ev_list = ev.list.clone
    @load = M5CES20141001::Load.new    
    @open_command,@command_list,@end_command = @load.setup(ev_list)    
    return @command_list
  end
  #--------------------------------------------------------------------------
  # ● Scene_动作
  #--------------------------------------------------------------------------
  def scene_back(value);@window.background.bitmap = Cache.picture(value);end
  def default_choose(value);@default_choose = value - 1;end
  def update_when_move(value = true);@window.update_when_move = value;end
  def command_x(value);@window.x = value;end
  def command_y(value);@window.y = value;end
  def command_width(value);@window.width = value.abs;end
  def command_height(value);@window.height = value.abs;end
  def command_hide;@window.hide;end
  def command_opacity(value = 0);@window.opacity = value;end
  def cancel_enabled(value = false);@window.cancel_enabled = value;end
  def window_x(value);@window.window.x = value;end
  def window_y(value);@window.window.y = value;end
  def window_width(value);@window.window.width = value.abs;end
  def window_height(value); @window.window.height = value.abs; end
  def window_hide; @window.window.hide; end
  def window_opacity(value = 0); @window.window.opacity = value; end
  def lr_mode(value = true); @window.lr_mode = value; end
  def hide_arrows(value = false); @window.arrows_visible = value; end
  def bgm_replay; @bgm.play; end
  def bgs_replay; @bgs.play; end
end
#--------------------------------------------------------------------------
# ● Window_MenuCommand
#--------------------------------------------------------------------------
class Window_MenuCommand
  alias m5_20141001_add_formation_command add_formation_command
  def add_formation_command
    m5_20141001_add_formation_command
    M5CES20141001::MENU.each_with_index do |set|      
      add_command(set[0],"m5_ces20141001_#{set[1]}".to_sym)
    end
  end
  alias m5_20141001_handle? handle?
  def handle?(symbol)
    if /m5_ces20141001_\S+/ =~ symbol.to_s
      return true
    else
      return m5_20141001_handle?(symbol)
    end
  end
  alias m5_20141001_call_handler call_handler
  def call_handler(symbol)
    id = /m5_ces20141001_(\S+)/ =~ symbol.to_s ? $1.to_i : nil
    return m5_20141001_call_handler(symbol) unless id    
    M5CES20141001.call(id)
  end
end
#--------------------------------------------------------------------------
# ● 中文名
#--------------------------------------------------------------------------
class Scene_M5CES20141001
  alias 界面背景      scene_back
  alias 默认选择      default_choose
  alias 自动更新      update_when_move
  alias 选择窗口X     command_x
  alias 选择窗口Y     command_y
  alias 选择窗口宽    command_width
  alias 选择窗口高    command_height
  alias 选择窗口隐藏  command_hide
  alias 选择窗口透明  command_opacity
  alias 信息窗口X     window_x
  alias 信息窗口Y     window_y
  alias 信息窗口宽    window_width
  alias 信息窗口高    window_height
  alias 信息窗口隐藏  window_hide
  alias 信息窗口透明  window_opacity
  alias 重播音乐      bgm_replay
  alias 重播声音      bgs_replay
  alias 禁止取消      cancel_enabled
  alias 横向按键      lr_mode
  alias 隐藏箭头      hide_arrows
end
