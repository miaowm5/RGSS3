=begin
===============================================================================
  导入、导出文本 By喵呜喵5
===============================================================================

【说明】

  将每个事件的文本导出到单独的TXT文件中去
  修改TXT的内容后可以把这些内容再重新导入回游戏中

  可以让文本量较大的游戏能够更方便的对每一句对话进行纠错
  也可以方便汉化组对游戏的汉化

  使用过程中碰到什么BUG请及时汇报

  【关于使用的一些注意事项】

  使用本脚本前请备份好你的工程，我不负责修复任何因为本脚本造成的工程数据丢失
  游戏正式发布时请删除这个脚本

  只有包含文本的内容的数据会被导出为TXT。导入时则会将对应目录下所有的TXT文件导入

  请不要修改txt文件名，请不要修改/删除导出的TXT中包含特殊符号 ● 的行，否则导入将出现异常
  介于特殊符号 ● 之间的行将会被导入游戏中，其余的行则会被忽略

  导入后的内容在编辑器中会出现下面两种情况：
  1. 若翻译后的文本超过4行时，导入后的显示文字指令显示的内容也对应会超过4行
  2. 显示选项指令中《显示选项XXX》和《如果选择XXX》的提示不符合
  重新编辑这个指令（不需要修改文字）可以使编辑器中显示的内容恢复正常
  即使没有重新编辑这些指令，实际运行游戏时也不会出现什么问题

=end

$m5script ||= {};$m5script[:M5IT20250512] = 20250512;module M5IT20250512; end
module M5IT20250512
#==============================================================================
# 设定部分
#==============================================================================

  M5MARK = "●"

  # 这里设置一个【永远不会】在对话文本中出现的特殊符号

  #【姓名表】
  #（设置姓名表可以增加导出后TXT的可读性，角色姓名的判断依赖于对话时显示的脸图）
  #（即使不设置姓名表，本脚本仍然可以正常的进行导入、导出的操作）

  NAMELIST = {

  # 从这里开始添加姓名
  # 添加的格式为：
  # "脸图的文件名" => ["第一个角色的姓名","第二个角色的姓名","第X个角色的姓名"],
  # （注意标点符号，特别是最后的逗号）
  # 角色依照脸图从左至右从上至下的顺序排列

  "Actor1" => ["拉尔夫","女人","男人","吴莉嘉","劳伦斯"],
  "Actor2" => ["男人","女人","班尼特","女人","男人","伊尔维亚"],
  "Actor3" => ["男人","薇拉","艾尔玛"],
  "Actor4" => ["艾里克","娜塔丽","泰伦斯","女人","阿奈思特","女人","龙马"],
  "Actor5" => ["男人","布伦达","瑞克","女人","男人","爱丽丝","诺亚","伊萨贝拉"],

  # 添加姓名结束
  }

  TARGET = "Event"

  # 储存导出/导入的 txt 的文件夹

#==============================================================================
# 设定结束
#==============================================================================
end

module M5IT20250512::Loader; end
class << M5IT20250512::Loader
  def get_face_name(face, face_index)
    return '' if face == ""
    namelist = M5IT20250512::NAMELIST[face]
    return "-#{namelist[face_index]}" if namelist && namelist[face_index]
    return "-#{face}（#{face_index}）"
  end
  def load_event_list(event_list, position)
    mark = ::M5IT20250512::M5MARK
    result = []
    index = 0
    text_index = 0
    collect_text = ->(code) do
      index += 1
      command = event_list[index]
      while command
        if code == command.code
          result.push(command.parameters[0])
          index += 1
          command = event_list[index]
        else
          break
        end
      end
      index -= 1
    end
    while index < event_list.size
      command = event_list[index]
      pos = "#{mark}#{([command.code] + position + [text_index]).join('#')}"
      case command.code
      when 101
        # 显示文字
        name = get_face_name(command.parameters[0], command.parameters[1])
        result.push("#{mark}显示文字#{name}#{pos}")
        collect_text.call(401)
        text_index += 1
      when 105
        result.push("#{mark}滚动文字#{pos}")
        collect_text.call(405)
        text_index += 1
      when 102
        # 显示选择项
        result.push("#{mark}显示选项#{pos}")
        command.parameters[0].each{|choice| result.push(choice)}
        text_index += 1
      when 355
        # 插件脚本
        if @load_script
          result.push("#{mark}脚本#{pos}")
          result.push(command.parameters[0])
          collect_text.call(655)
          text_index += 1
        end
      end
      index += 1
    end
    result.push("#{mark}#{mark}") if result.size > 0
    return result
  end
  def load_map_event
    file = load_data("Data/MapInfos.rvdata2")
    file.keys.each do |map_id|
      map = load_data(sprintf("Data/Map%03d.rvdata2",map_id))
      file_content = ["《#{file[map_id].name}#{map.display_name != "" ? "(#{map.display_name})" : ""}》",""]
      event = map.events
      event.keys.each do |event_id|
        event_content = []
        event[event_id].pages.each_with_index do |event_page, page_index|
          list_content = load_event_list(event_page.list, [event_id, page_index])
          if list_content.size > 0
            event_content.push("<事件页#{page_index + 1}>")
            event_content += list_content
          end
        end
        if event_content.size > 0
          file_content.push("#{event[event_id].name}(事件#{event_id}):")
          file_content += event_content
          file_content.push("")
        end
      end
      if file_content.size > 2
        save_text("地图#{map_id}",file_content.join("\n"))
      end
    end
  end
  def load_common_event
    file = load_data("Data/CommonEvents.rvdata2")
    file.each do |event|
      next unless event
      file_content = ["《#{event.name}(公共事件#{event.id})》", ""]
      list_content = load_event_list(event.list, [])
      if list_content.size > 0
        file_content += list_content
      end
      if file_content.size > 2
        save_text("公共事件#{event.id}",file_content.join("\n"))
      end
    end
  end
  def load_troop_event
    file = load_data("Data/Troops.rvdata2")
    file_content = []
    file.each do |troop|
      next if !troop
      file_content = ["《#{troop.name}(敌群#{troop.id})》", ""]
      troop.pages.each_with_index do |event_page, index|
        list_content = load_event_list(event_page.list, [index])
        if list_content.size > 0
          file_content.push("<事件页#{index + 1}>")
          file_content += list_content
        end
      end
      if file_content.size > 2
        save_text("敌群#{troop.id}",file_content.join("\n"))
      end
    end
  end
  def save_text(name,word)
    content = File.open("#{::M5IT20250512::TARGET}/#{name}.txt",'w')
    content.puts word
    content.close
  end
  def load(config)
    Dir.mkdir(::M5IT20250512::TARGET)
    @load_script = config[2]
    load_map_event
    load_common_event if config[0]
    load_troop_event if config[1]
  end
end


module M5IT20250512::Saver; end
class << M5IT20250512::Saver
  def read_txt(file_name)
    filename = "#{::M5IT20250512::TARGET}/#{file_name}.txt"
    return nil unless File.exist?(filename)
    result = []
    current = nil
    IO.foreach(filename) do |text|
      text.chomp!
      if text.start_with?(::M5IT20250512::M5MARK)
        info = text.split(::M5IT20250512::M5MARK)[2]
        result.push(current) if current
        current = nil
        next unless info
        info = info.split('#')
        code = info.shift.to_i
        current = { info: info, code: code, text: [] }
      else
        next unless current
        current[:text].push(text)
      end
    end
    return nil if result.empty?
    return result
  end
  def save_event_list(event_list, config)
    index = 0
    text_index = 0
    result = []
    command = nil
    check_config = ->(import_text, command) do
      return if import_text && import_text[:code] == command.code
      throw new Error("导入的文本和导出时的任务配置不一致")
    end
    skip_command = ->(code_list) do
      index += 1
      command = event_list[index]
      while command
        if code_list.include?(command.code)
          index += 1
          command = event_list[index]
        else
          break
        end
      end
    end
    while index < event_list.size
      command = event_list[index]
      import_text = config[text_index]
      case command.code
      when 101, 105
        # 普通文字, 滚动文字
        check_config.call(import_text, command)
        result.push(command)
        import_text[:text].each do |text|
          result.push(RPG::EventCommand.new(
            command.code == 101 ? 401 : 405, command.indent, [text]
          ))
        end
        skip_command.call([401, 405])
        text_index += 1
        next
      when 102
        # 显示选择项
        check_config.call(import_text, command)
        command.parameters[0].size.times do |choice|
          command.parameters[0][choice] = import_text[:text][choice] || ''
        end
        text_index += 1
      when 355
        # 插件脚本
        if import_text && import_text[:code] == 355
          if !import_text[:text][0]
            command.parameters[0] = ''
          else
            import_text[:text].each_with_index do |text, index|
              if index == 0
                command.parameters[0] = text
                result.push(command)
              else
                result.push(RPG::EventCommand.new(655,command.indent,[text]))
              end
            end
          end
          skip_command.call([655])
          text_index += 1
          next
        end
      end
      result.push(command)
      index += 1
    end
    return result
  end
  def save_map_event
    map_list = load_data("Data/MapInfos.rvdata2").keys
    map_list.each do |map_id|
      result = read_txt("地图#{map_id}")
      next unless result
      ev = {}
      result.each do |event|
        id = event[:info][0].to_i
        page = event[:info][1].to_i
        index = event[:info][2].to_i
        ev[id] = ev[id] || {}
        ev[id][page] = ev[id][page] || {}
        ev[id][page][index] = event
      end
      map = load_data(sprintf("Data/Map%03d.rvdata2",map_id))
      map.events.keys.each do |event_id|
        map.events[event_id].pages.each_with_index do |page, page_index|
          next unless ev[event_id] && ev[event_id][page_index]
          page.list = save_event_list(page.list, ev[event_id][page_index])
        end
      end
      save_data(map,sprintf("Data/Map%03d.rvdata2",map_id))
    end
  end
  def save_common_event
    file = load_data("Data/CommonEvents.rvdata2")
    file.each do |event|
      next unless event
      result = read_txt("公共事件#{event.id}")
      next unless result
      ev = {}
      result.each do |event|
        index = event[:info][0].to_i
        ev[index] = event
      end
      event.list = save_event_list(event.list, ev)
    end
    save_data(file,"Data/CommonEvents.rvdata2")
  end
  def save_troop_event
    file = load_data("Data/Troops.rvdata2")
    file.each do |troop|
      next if !troop
      result = read_txt("敌群#{troop.id}")
      next unless result
      ev = {}
      result.each do |event|
        page = event[:info][0].to_i
        index = event[:info][1].to_i
        ev[page] = ev[page] || {}
        ev[page][index] = event
      end
      troop.pages.each_with_index do |page, page_index|
        next unless ev[page_index]
        page.list = save_event_list(page.list, ev[page_index])
      end
    end
    save_data(file,"Data/Troops.rvdata2")
  end
  def save
    save_map_event
    save_common_event
    save_troop_event
  end
end

module M5IT20250512; module GUI

  class Selector < ::Window_Base
    def initialize(x, y, width, height, text)
      super(x, y, width, height)
      self.visible = false
      refresh(text)
    end
    def refresh(text)
      contents.clear
      contents.draw_text(0, 0, contents.width, contents.height, text, 1)
    end
    def select; cursor_rect.set(0, 0, contents.width, contents.height); end
    def unselect; cursor_rect.empty; end
  end
  class Info < ::Window_Base
    def initialize(x, y, width, height)
      super(x, y, width, height)
    end
    def refresh(text)
      contents.clear
      text.each_with_index do |line, index|
        contents.draw_text(0, line_height * index, contents.width, line_height, line, 0)
      end
    end
  end

  class Group
    def initialize(win); @win = win; end
    def visible=(v); @win.each{|w| w.visible = v}; end
    def select=(v); @win.each{|w| w.unselect}; @win[v].select ; end
    def update; @win.each{|w| w.update}; end
  end
  class Group1 < Group
    def initialize(info)
      super([
        Selector.new(0, 0, Graphics.width, 60, '导出文本'),
        Selector.new(0, 60, Graphics.width, 60, '导入文本'),
      ])
      @info = info
    end
    def refresh(state)
      self.visible = state[0] == :step0
      return unless state[0] == :step0
      self.select = state[1] = [[0, state[1]].max, 1].min
      target = ::M5IT20250512::TARGET
      if state[1] == 1
        @info.refresh([File.directory?(target) ?
          "将 #{target} 目录下的文本导入到游戏中" :
          "待导入文本不存在，请先导出文本后再进行导入"
        ])
      elsif state[1] == 0
        @info.refresh(["将游戏中的文本导出到 #{target} 目录"])
      end
    end
  end
  class Group2 < Group
    def initialize(info)
      super([
        Selector.new(0, 0, Graphics.width, 60, '导出公共事件：导出'),
        Selector.new(0, 60, Graphics.width, 60, '导出敌群事件：导出'),
        Selector.new(0, 120, Graphics.width, 60, '导出事件脚本：不导出'),
        Selector.new(0, 180, Graphics.width, 60, '导出'),
      ])
      @info = info
    end
    def refresh(state)
      self.visible = state[0] == :step1
      return unless state[0] == :step1
      self.select = state[1] = [[0, state[1]].max, 3].min
      if state[1] == 2
        @info.refresh([
          "如果事件脚本中没有包含显示的文字的话，",
          "导入以及导出其实没有什么意义（还可能出错）"
        ])
      else
        @info.refresh([""])
      end
      @win[0].refresh("导出公共事件：#{state[2][0] ? '导出' : '不导出'}")
      @win[1].refresh("导出敌群事件：#{state[2][1] ? '导出' : '不导出'}")
      @win[2].refresh("导出事件脚本：#{state[2][2] ? '导出' : '不导出'}")
    end
  end

  class Manager
    def initialize
      DataManager.init
      @info = Info.new(0, (Graphics.height - 160), Graphics.width, 160)
      @group1 = Group1.new(@info)
      @group2 = Group2.new(@info)
      @state = [:step0, 0]
      refresh
    end
    def refresh
      @group1.refresh(@state)
      @group2.refresh(@state)
    end
    def update
      Graphics.update
      Input.update
      if Input.trigger?(:C)
        if @state[0] == :step0 then trigger_step1
        elsif @state[0] == :step1 then trigger_step2
        end
      elsif Input.trigger?(:UP) then
        @state[1] -= 1
        refresh
      elsif Input.trigger?(:DOWN)
        @state[1] += 1
        refresh
      elsif Input.trigger?(:B)
        if @state[0] == :step1
          @state = [:step0, 0]
          refresh
        end
      end
    end
    def trigger_step1
      target = ::M5IT20250512::TARGET
      if @state[1] == 0
        @state = [:step1, 0, [true, true, false]]
        refresh
      end
      if @state[1] == 1 && File.directory?(target)
        @info.refresh(['正在导入文本...'])
        Graphics.update
        M5IT20250512::Saver.save
        @info.refresh(['导入完毕！','请重新启动编辑器以查看效果'])
      end
    end
    def trigger_step2
      if @state[1] <= 2
        @state[2][@state[1]] = !@state[2][@state[1]]
        refresh
      end
      target = ::M5IT20250512::TARGET
      if @state[1] == 3
        if File.directory?(target)
          @info.refresh([
            "游戏工程下已存在 #{target} 目录",
            "为防止误操作导致的数据覆盖，请手动删除目录后重新导出"
          ])
        else
          @info.refresh(['正在导出文本...'])
          Graphics.update
          M5IT20250512::Loader.load(@state[2])
          @info.refresh(['导出完毕！',"导出的游戏文本保存在游戏工程的 #{target} 目录下"])
        end
      end
    end
  end

end; end

rgss_main {
  manager = M5IT20250512::GUI::Manager.new
  manager.update while true
}
