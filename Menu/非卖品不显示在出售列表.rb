class Window_ShopSell
  alias m5_20150914_include? include?
  def include?(item)
    return false unless m5_20150914_include?(item)
    enable?(item)
  end
end
