=begin
===============================================================================
  标题画面背景滚动 By喵呜喵5
===============================================================================

  【说明】

  循环滚动标题画面的背景图片


  如果插入了我的《随游戏进度修改标题画面》脚本的话，

  还可以随着游戏的进度改变标题画面背景的滚动速度（以及背景图片）

  在《随游戏进度修改标题画面》的设置部分可以设置以下属性来控制本脚本的功能：

  :ex1_x1   背景图片在水平方向上的移动速度
  :ex1_y1   背景图片在垂直方向上的移动速度

  :ex1_x2   前景图片在水平方向上的移动速度
  :ex1_y2   前景图片在垂直方向上的移动速度

=end
$m5script ||= {};$m5script[:M5ST20151106] = 20151106
module M5ST20151106
#==============================================================================
#  设定部分
#==============================================================================

  X1 = 1

  # 背景图片在水平方向上的移动速度

  Y1 = 0

  # 背景图片在垂直方向上的移动速度

  X2 = -1

  # 前景图片在水平方向上的移动速度

  Y2 = 0

  # 前景图片在垂直方向上的移动速度

#==============================================================================
#  设定结束
#==============================================================================
  def self.data
    default = [X1, Y1, X2, Y2]
    if $m5script[:M5TC20150320] && $m5script[:M5TC20150320] >= 20151106
      data = M5GV20140811.get_ext[:M5TC20150320]
      tc_default = M5TC20150320::SETTING["DEA"]
      [:ex1_x1, :ex1_y1, :ex1_x2, :ex1_y2].each_with_index do |key,i|
        default[i] = data[key] || tc_default[key] || default[i]
      end
    end
    default
  end
end
class Scene_Title
  alias m5_20151106_create_background create_background
  def create_background
    m5_20151106_create_background
    bitmap1 = @sprite1.bitmap
    bitmap2 = @sprite2.bitmap
    @sprite1.dispose
    @sprite2.dispose
    (@sprite1 = Plane.new).bitmap = bitmap1
    (@sprite2 = Plane.new).bitmap = bitmap2
    @m5_20151106_data = M5ST20151106.data
  end
  alias m5_20151106_update update
  def update
    m5_20151106_update
    @sprite1.ox += @m5_20151106_data[0]
    @sprite1.oy += @m5_20151106_data[1]
    @sprite2.ox += @m5_20151106_data[2]
    @sprite2.oy += @m5_20151106_data[3]
  end
end