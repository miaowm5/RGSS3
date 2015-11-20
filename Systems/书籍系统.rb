=begin
===============================================================================
  书籍系统 By喵呜喵5
===============================================================================

【说明】

  在屏幕上显示指定的图片，使用左右键可以切换不同的图片（下一张/上一张）

  说是书籍系统，这个系统更类似于一个相册

  所有显示的图片均放在 Graphics/M5Book 目录下


  在事件脚本中使用指令

    M5Book20151113.open(:书籍的名称)

  来打开对应的书籍

  书籍的具体设置请参考下方的说明以及脚本默认的范例


=end
$m5script ||= {};$m5script[:M5Book20151113] = 20151120
module M5Book20151113; CONFIG ={
=begin
#==============================================================================
#  设定部分
#==============================================================================

  下面的每一个设置对应一本书籍，设置的格式为

    :书籍的名称 => { 书籍的设置 },

    ※ 书籍名称开头的英文冒号以及书籍设置最后的英文逗号不能省略
    ※ 名为 :默认书籍 的设置为【所有】书籍的默认设置

  在两个大括号之间，可以设置书籍本身的属性，设置的格式为：

    需要设置的属性: 属性的值 ,

    ※ 冒号和属性的值之间请加上空格，不要忘记每条设置最后的逗号

  可以设置的属性如下：

  FOLD        书籍图片所在的目录，默认目录为“Graphics/M5Book”。
              例如，若这里设置为“Foo”，则书籍图片的目录将变成
              “Graphics/M5Book/Foo”目录，依此类推

  MAX         书籍的总页数，同时也指定了书籍要显示的图片。
              例如，设置为 4 时，
              显示的图片便为指定目录下文件名为 1、2、3、4 的这四张图片

  LIST        书籍的图片文件名列表，设置格式为 ['文件名1','文件名2','文件名n']
              ※ 文件名前后加上英文引号，中间用英文逗号分隔
              例如，设置为 ['1','2','4','5'] 时，
              显示的图片便为指定目录下名为 1、2、4、5 的这四张图片
              当设置了这个属性后，上方的 MAX 属性将失效

              当这里设置为 ['0',['1',100,100],['1',100,200],'2'] 时
              书籍的第二页显示名为 1 的图片，显示位置为(100,100)
              翻到第三页时，图片不会改变，而是将显示位置移动到(100,200)

  MOVE_SPEED  当图片设置了移动时（上面后半部分提到的设置方式），
              图片的移动速度

  BACK        界面的背景图片文件名，文件名前后需要加上英文引号
              背景图片文件的目录始终为“Graphics/M5Book”

  FORE        界面的遮罩图片文件名，文件名前后需要加上英文引号
              遮罩图片文件的目录始终为“Graphics/M5Book”

  HINT        界面的提示图片文件名，文件名前后需要加上英文引号
              提示图片文件的目录始终为“Graphics/M5Book”
              提示图片和遮罩图片类似，都是显示在界面最上方
              不过长时间没有按键时，提示图片会自动隐藏

  HIDE_TIME   设置多长时间没有操作时自动隐藏提示图片

  HIDE_SPEED  设置提示图片隐藏/显示的速度

  START_PAGE  书籍最开始的页数

  SCROLL      设置为 true 时，书籍翻到最后一页后继续翻页会回到第一页

  SPEED       书籍翻页的速度

  OPEN_SE     打开书籍界面时播放的音效文件名，前后需要加上英文引号

  CLOSE_SE    关闭书籍界面时播放的音效文件名，前后需要加上英文引号

  PAGE_SE     书籍翻页时播放的音效文件名，前后需要加上英文引号

  ERROR_SE    书籍无法翻页时播放的音效文件名，前后需要加上英文引号


  下面四个是书籍界面按钮的设置，设置格式为 [按钮1,按钮2,按钮n]

  各个按钮的格式为：

    :DOWN :LEFT :RIGHT :UP                  分别对应方向键中的下、左、右、上

    :A :B :C :X :Y :Z :L :R                 对应 F1 中各自的按键

    :SHIFT :CTRL :ALT :F5 :F6 :F7 :F8 :F9   直接对应键盘上面的相应按键

  按键设置为 [] 时对应功能失效


  PRE_BUTTON      书籍向前翻页的按钮
                  默认为 :LEFT 键（默认对应键盘的 左 键）

  NEXT_BUTTON     书籍向后翻页的按钮
                  默认为 :RIGHT 键（默认对应键盘的 右 键）

  CLOSE_BUTTON1   关闭书籍界面的按钮
                  默认为 :B 键（默认对应键盘的 X 键）

  CLOSE_BUTTON2   书籍翻到最后一页时关闭书籍界面的按钮
                  默认为 :C 键（默认对应键盘的 Z 键）


=end

  :默认书籍 => {

    PAGE_SE: "Book2",

    ERROR_SE: "Book1",

  },

  # 这个设置中设置的属性将应用到所有书籍中，这里为所有书籍的翻页增加了音效

  :书籍1 => {

    FOLD: "书籍1",

    MAX: 9,

  },

  # 名为 书籍1 的书籍显示 M5Book/书籍1 目录下 1.jpg ~ 9.jpg 这9张图片

  :书籍2 => {

    LIST: ['cg2','pic1','pic4','cg0'],

    SCROLL: true,

  },

  # 名为 书籍2 的书籍显示 M5Book 目录下指定图片同时循环翻页

  :书籍3 => {

    LIST: ['cg2','cg0'],

    BACK: "back",

    FORE: "fore",

    HINT: "hint",

    SPEED: 5,

  },

  # 名为 书籍3 的书籍拥有前景、背景和提示，翻页速度特慢

  :书籍4 => {

    FOLD: '书籍4',

    MAX: 6,

    PRE_BUTTON: [:UP, :B],

    NEXT_BUTTON: [:DOWN, :C],

    CLOSE_BUTTON1: [],

  },

  # 名为 书籍4 的书籍使用上下和确定取消键翻页，只能在最后一页按确定键退出

  :书籍5 => {

    FOLD: '书籍5',

    MAX: 9,

    START_PAGE: 2,

    OPEN_SE: "Cat",

    CLOSE_SE: "Cat",

    ERROR_SE: "Dog",

  },

  # 名为 书籍5 的书籍最开始显示第二张图片，同时打开、关闭时有音效，
  # 并覆盖了默认翻页错误音效

  :书籍6 => {

    LIST: ['cg', ['cg',-140,0], ['cg',-280,0]],

    MOVE_SPEED: 5,

  },

  # 名为 书籍6 的书籍演示了如何制作书籍图片移动的效果

#==============================================================================
#  设定结束
#==============================================================================
}
class Scene < Scene_MenuBase
  def bitmap(filename)
    @cache ||= {}
    path = "Graphics/M5Book/"
    path += "#{@config[:FOLD]}/" if @config[:FOLD]
    path += filename
    return @cache[path] if @cache[path]
    @cache[path] = filename.empty? ? Bitmap.new(32,32) : Bitmap.new(path)
  end
  def input?(list)
    list.each do |i|
      if Input.trigger?(i)
        @hint_state[0] = :showing
        return true
      end
    end
    false
  end
  def prepare(config)
    @config = config.clone
    if !@config[:LIST]
      @config[:LIST] = []
      @config[:MAX].times {|i| @config[:LIST] << (i + 1).to_s }
    end
    start = @config[:START_PAGE] || 1
    start -= 1
    start = [[start,0].max, @config[:LIST].size - 1].min
    @config[:START_PAGE] = start
    @config[:SCROLL] ||= false
    @config[:CLOSE_BUTTON1] ||= [:B]
    @config[:CLOSE_BUTTON2] ||= [:C]
    @config[:NEXT_BUTTON] ||= [:RIGHT, :C]
    @config[:PRE_BUTTON] ||= [:LEFT]
    @config[:SPEED] ||= 20
    @config[:MOVE_SPEED] ||= 10
    @config[:HIDE_TIME] ||= 60
    @config[:HIDE_SPEED] ||= 20
  end
  def start
    super
    create_page
    create_foreground
    create_hint
    Audio.se_play "Audio/SE/#{@config[:OPEN_SE]}" if @config[:OPEN_SE]
  end
  def create_background
    @background_bitmap = nil
    return super unless @config[:BACK]
    @background_sprite = Sprite.new
    @background_bitmap = Bitmap.new "Graphics/M5Book/#{@config[:BACK]}"
    @background_sprite.bitmap = @background_bitmap
  end
  def create_page
    @page_index = @config[:START_PAGE]
    @page_change = false
    @now_sprite = Sprite.new
    @next_sprite = Sprite.new
    page = @config[:LIST][@page_index]
    page = [page, 0, 0] unless page.is_a? Array
    @next_sprite.bitmap = bitmap(page[0])
    @next_sprite.x, @next_sprite.y = page[1], page[2]
    @now_sprite.opacity = 0
    @next_sprite.z = 100
  end
  def create_foreground
    @foreground = Sprite.new
    @foreground.z = 150
    if @config[:FORE]
      @foreground.bitmap = Bitmap.new "Graphics/M5Book/#{@config[:FORE]}"
    end
  end
  def create_hint
    @hint = Sprite.new
    @hint.z = 200
    if @config[:HINT]
      @hint.bitmap = Bitmap.new "Graphics/M5Book/#{@config[:HINT]}"
    end
    @hint_state = [:show, @config[:HIDE_TIME]]
  end
  def update
    super
    update_hint_image
    return update_page if @page_change
    @now_sprite.opacity -= @config[:SPEED] unless @now_sprite.opacity == 0
    update_input
  end
  def update_hint_image
    return unless @hint.bitmap
    case @hint_state[0]
    when :showing
      @hint.opacity += @config[:HIDE_SPEED]
      @hint_state = [:show, @config[:HIDE_TIME]] if @hint.opacity == 255
    when :show
      return if @page_change
      time = @hint_state[1]
      time -= 1
      @hint_state[0] = :hiding if time < 0
      @hint_state[1] = time
    when :hiding
      @hint.opacity -= @config[:HIDE_SPEED] unless @hint.opacity == 0
    end
  end

  def update_page
    case @page_change_type[0]
    when :image then update_image_change
    when :move then update_image_move(@page_change_type[1])
    end
  end
  def update_image_change
    @next_sprite.opacity += @config[:SPEED]
    @page_change = false if @next_sprite.opacity == 255
  end
  def update_image_move(data)
    s = @next_sprite
    proc = ->(target, direction, orign) do
      next orign if target == orign
      speed = @config[:MOVE_SPEED]
      speed *= -1 unless direction
      result = orign + speed
      direction ? [result, target].min : [result, target].max
    end
    s.x = proc.call(data[:TX], data[:X], s.x)
    s.y = proc.call(data[:TY], data[:Y], s.y)
    s.x == data[:TX] && s.y == data[:TY] && @page_change = false
  end
  def update_input
    change_page(-1) if input?(@config[:PRE_BUTTON])
    change_page(1) if input?(@config[:NEXT_BUTTON])
    return_scene if input?(@config[:CLOSE_BUTTON1])
    return unless @page_index == @config[:LIST].size - 1
    return_scene if input?(@config[:CLOSE_BUTTON2])
  end
  def change_page(amount)
    old_page = @page_index
    @page_index += amount
    last_page = @config[:LIST].size
    if @page_index < 0 || @page_index > last_page - 1
      @page_index = @config[:SCROLL] ?
        @page_index % last_page : [[@page_index, 0].max, last_page - 1].min
    end
    if old_page != @page_index
      Audio.se_play "Audio/SE/#{@config[:PAGE_SE]}" if @config[:PAGE_SE]
      @page_change = true
      set_page(old_page, @page_index)
      Input.update
    else
      Audio.se_play "Audio/SE/#{@config[:ERROR_SE]}" if @config[:ERROR_SE]
    end
  end
  def set_page(old_page, new_page)
    old_data = @config[:LIST][old_page]
    new_data = @config[:LIST][new_page]
    old_data = [old_data, 0, 0] unless old_data.is_a? Array
    new_data = [new_data, 0, 0] unless new_data.is_a? Array
    return set_move(*new_data) if new_data[0] == old_data[0]
    set_bitmap(*new_data)
  end
  def set_bitmap(filename, x, y)
    @now_sprite, @next_sprite = @next_sprite, @now_sprite
    @now_sprite.z, @next_sprite.z = 50, 100
    @now_sprite.opacity, @next_sprite.opacity = 255, 0
    @next_sprite.bitmap = bitmap(filename)
    @next_sprite.x, @next_sprite.y = x, y
    @page_change_type = [:image]
  end
  def set_move(_, tx, ty)
    move_data = {
      TX: tx, TY: ty,
      X:  tx - @next_sprite.x > 0,
      Y:  ty - @next_sprite.y > 0
    }
    @page_change_type = [:move, move_data]
  end
  def terminate
    Audio.se_play "Audio/SE/#{@config[:CLOSE_SE]}" if @config[:CLOSE_SE]
    super
    @now_sprite.dispose
    @next_sprite.dispose
    @foreground.bitmap.dispose if @foreground.bitmap
    @foreground.dispose
    @hint.bitmap.dispose if @hint.bitmap
    @hint.dispose
    @cache.each_value(&:dispose)
    @background_bitmap.dispose if @background_bitmap
  end
end

  def self.open(name)
    config = CONFIG[:默认书籍] || {}
    config = config.merge (CONFIG[name] || {})
    raise '未设置书籍内容' unless config[:LIST] || config[:MAX]
    SceneManager.call(Scene)
    SceneManager.scene.prepare(config)
  end

end # M5Book20151113