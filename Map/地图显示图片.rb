=begin
===============================================================================
  地图显示图片 By 喵呜喵5
===============================================================================

【说明】

  根据变量在地图上显示图片，支持许多的自定义操作

=end
$m5script ||= {}
$m5script[:M5Pic20210711] = 20210711
module M5Pic20210711;VAR_CONFIG =[
=begin
#==============================================================================
#  设定部分
#==============================================================================

  下面的每一对大括号对应地图上的一个图片，中间的内容就是图片的属性
  具体的格式请参考下面给出的范例（※注意每大括号最后的逗号）

  添加内容的格式为：

    需要设置的属性: 属性的值 ,

  （※ 冒号和属性的值之间请加上空格，不要忘记每条设置最后的逗号）

  可以设置的属性如下：

  VAR      变量的ID，根据此变量ID决定要显示的图片
           不配置此属性表示变量值固定为 0
  IMAGE    要显示的图片，请参考下面的范例配置，设置格式为：
           [
             {图片1的属性1: 值1, 图片1的属性2: 值2,},
             {图片2的属性1: 值3, 图片2的属性2: 值4,},
           ]
           图片支持以下属性：

             VALUE  当变量为此值时，按照配置显示对应图片
                    同一个图片只有一个满足条件的配置能生效，优先级从上到下
                    变量的值不等于任何一个图片时，图片隐藏
                    填写 [范围1, 范围2] 可以在变量处于特定范围时显示图片
                    不配置此属性表示变量为任何值都显示此图片
             IMAGE  要显示的图片文件名，前后要加上英文引号
                    填写成 [图片1, 图片2] 的形式则会循环播放列表中的图片
                    （※ 播放列表的图片过多时可能存在效率问题）
             SPEED  当图片循环播放时播放速度（单位：帧）
             LOOP   填写为 true 时，图片将以远景图的方式平铺显示

  X        图片的X坐标
  Y        图片的Y坐标
  Z        图片的Z高度，可以为负数
           高度比较大的图片将遮住高度比较低的图片
  SWI      图片的开关ID，当对应ID的开关打开时不显示这个图片
  INV_SWI  图片的开关ID，当对应ID的开关【关闭】时不显示这个图片
  EVAL     判断图片内容的变量数值变为代码的返回值，VAR属性将被忽略（需要双引号）
           如果不懂意思的话请不要设置这个属性
  SCENE    图片只在特定的 Scene 才显示，如果不懂意思的话请不要设置这个属性

=end

  {
    VAR: 1,
    X: 354,
    Y: 86,
    SWI: 1,
    IMAGE: [
      {
        VALUE: 0,
        IMAGE: '1',
      },
      {
        VALUE: [-100, 0],
        IMAGE: '2',
      },
      {
        VALUE: [0, 100],
        IMAGE: '4',
      }
    ]
  },

  {
    X: 0,
    Y: 86,
    INV_SWI: 2,
    IMAGE: [
      {
        IMAGE: ['1','1','1','1','1','1','1','1','3'],
        SPEED: 10,
      }
    ]
  },

  {
    INV_SWI: 3,
    Z: 300,
    IMAGE: [
      {
        IMAGE: '5',
        LOOP: true,
      }
    ]
  },

  {
    SCENE: Scene_Status,
    EVAL: "$game_party.menu_actor.name",
    X: 354,
    Y: 86,
    Z: 200,
    IMAGE: [
      {
        VALUE: '喵子',
        IMAGE: '1',
      },
      {
        VALUE: '伊萨贝拉',
        IMAGE: '2',
      },
      {
        VALUE: '爱丽丝',
        IMAGE: '3',
      },
      {
        IMAGE: '4',
      }
    ]
  },

  ] # 请不要删除这行

  Z = 0   # 如果图片遮住其他不希望遮住的内容了，请调小这个数值

  PIC_PATH = "Graphics/Pictures/"   # 要显示的图片文件所在的文件夹

  SPEED = 5  # 图片的默认播放速度

  SWI = 5  # 对应ID的开关打开时，关闭本脚本的功能，
           # 这个全局开关优先于各个窗口单独设置的开关
           # 我的其他需要本脚本支持的脚本也会受到这个开关的影响而失效
           # 如果不需要这个开关的话，这里请填 nil

  INV_SWI = nil  # 对应ID的开关【关闭】时，关闭本脚本的功能，
                 # 这个全局开关优先于各个窗口单独设置的开关以及上面设置的开关
                 # 我的其他需要本脚本支持的脚本也会受到这个开关的影响而失效
                 # 如果不需要这个开关的话，这里请填 nil

#==============================================================================
#  设定结束
#==============================================================================
class Main
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  def initialize(config)
    @sprite = nil
    @image_config = nil
    @bitmap_cache = {}
    @anime_index = 0
    get_config(config)
    update
    refresh if @config[:ONLY]
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的设置
  #--------------------------------------------------------------------------
  def get_config(config)
    @config = config.clone
    @config[:X] ||= 0
    @config[:Y] ||= 0
    @config[:Z] ||= 0
    @config[:Z] += Z
    return if @config[:EVAL]
    @config[:EVAL] = @config[:VAR] ? "$game_variables[#{@config[:VAR]}]" : "0"
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    return close if close_judge?
    update_content
    return close unless @image_config
    if @sprite
      if Graphics.frame_count % @image_config[:SPEED] == 0
        last_index = @anime_index
        @anime_index = (@anime_index + 1) % @image_config[:IMAGE].length
        update_image if last_index != @anime_index
      end
    else
      update_image
    end
  end
  #--------------------------------------------------------------------------
  # ● 隐藏图片
  #--------------------------------------------------------------------------
  def close
    if @sprite
      @sprite.dispose
      @sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 图片是否应该隐藏? (true:关闭)
  #--------------------------------------------------------------------------
  def close_judge?
    return true if INV_SWI && !$game_switches[INV_SWI]
    return true if SWI && $game_switches[SWI]
    return true if @config[:INV_SWI] && !$game_switches[@config[:INV_SWI]]
    return true if @config[:SWI] && $game_switches[@config[:SWI]]
    false
  end
  #--------------------------------------------------------------------------
  # ● 判断图片是否需要更新
  #--------------------------------------------------------------------------
  def update_content
    content = @content
    begin
      @content = eval(@config[:EVAL])
    rescue
      p "图片：#{@config}","错误：#{$!.to_s}","追踪：#{$!.backtrace}"
      msgbox('地图显示图片脚本的某个窗口发生错误，错误信息已输出到控制台')
      exit
    end
    refresh unless content == @content
  end
  #--------------------------------------------------------------------------
  # ● 刷新图片的配置
  #--------------------------------------------------------------------------
  def refresh
    value = @content
    @image_config = @config[:IMAGE].find do |img|
      next true unless img[:VALUE]
      next false unless img[:IMAGE]
      if (img[:VALUE].instance_of?(Array))
        v = value.to_i
        next v <= img[:VALUE].max && v >= img[:VALUE].min
      else
        next value == img[:VALUE]
      end
    end
    return unless @image_config
    prepare_sprite
    update_image
  end
  #--------------------------------------------------------------------------
  # ● 读取图片
  #--------------------------------------------------------------------------
  def load_bitmap(file)
    path = PIC_PATH + file
    @bitmap_cache[path] = Bitmap.new(path) unless @bitmap_cache[path]
    @bitmap_cache[path]
  end
  #--------------------------------------------------------------------------
  # ● 准备图片精灵
  #--------------------------------------------------------------------------
  def prepare_sprite
    image_loop = @image_config[:LOOP]
    if @sprite
      if image_loop
        if @sprite.instance_of?(Sprite)
          @sprite.dispose
          @sprite = nil
        end
      elsif @sprite.instance_of?(Plane)
        @sprite.dispose
        @sprite = nil
      end
    end
    unless @sprite
      if image_loop then @sprite = Plane.new
      else
        @sprite = Sprite.new
        @sprite.x = @config[:X]
        @sprite.y = @config[:Y]
      end
      @sprite.z = @config[:Z]
    end
    @anime_index = 0
    # 以下两个处理修改了原始的配置对象
    unless @image_config[:IMAGE].instance_of?(Array)
      @image_config[:IMAGE] = [@image_config[:IMAGE]]
    end
    @image_config[:SPEED] = SPEED unless @image_config[:SPEED]
  end
  #--------------------------------------------------------------------------
  # ● 刷新图片
  #--------------------------------------------------------------------------
  def update_image
    @sprite || prepare_sprite
    image_file = @image_config[:IMAGE][@anime_index]
    @sprite.bitmap = load_bitmap(image_file)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    @sprite && @sprite.dispose
    @bitmap_cache.values.each{|bitmap| bitmap.dispose}
  end
end
end # M5Pic20210711
#--------------------------------------------------------------------------
# ● Scene_Base
#--------------------------------------------------------------------------
class Scene_Base
  #--------------------------------------------------------------------------
  # ● 生成图片
  #--------------------------------------------------------------------------
  alias m5_20210711_start start
  def start
    m5_20210711_start
    @m5_20210711_var_pic = []
    (M5Pic20210711::VAR_CONFIG + self.class.m5_20210711_pic).each do |config|
      next unless config
      next unless self.class == (config[:SCENE] ? config[:SCENE] : Scene_Map)
      next unless config[:IMAGE]
      @m5_20210711_var_pic.push(M5Pic20210711::Main.new(config))
    end
    @m5_20210711_var_pic.compact!
  end
  #--------------------------------------------------------------------------
  # ● 更新图片
  #--------------------------------------------------------------------------
  alias m5_20210711_update update
  def update
    m5_20210711_update
    return if scene_changing?
    return unless @m5_20210711_var_pic
    @m5_20210711_var_pic.each {|pic| pic.update if pic}
  end
  #--------------------------------------------------------------------------
  # ● 释放图片
  #--------------------------------------------------------------------------
  alias m5_20210711_terminate terminate
  def terminate
    m5_20210711_terminate
    return unless @m5_20210711_var_pic
    @m5_20210711_var_pic.each {|pic| pic.dispose if pic}
  end
  #--------------------------------------------------------------------------
  # ● 为其他脚本提供的接口
  #--------------------------------------------------------------------------
  def self.m5_20210711_pic(config = nil)
    @m5_20210711_add_pic ||= []
    return @m5_20210711_add_pic unless config
    hash = { EVAL: "#{config}.var", SCENE: self }
    [:X, :Y, :Z, :IMAGE, :SWI, :INV_SWI].each do |key|
      hash[key] = config.const_get(key) rescue nil
    end
    @m5_20210711_add_pic.push hash
  end
end
