class Array
  def m5loop
    return nil if self.size == 0
    param = self.shift    
    if !param.is_a?(Fixnum)
      def param.value
        return self.respond_to?(:clone) ? self.clone : self
      end
    else
      fixnum = true
    end
    yield( fixnum ? param : param.value ) if block_given?
    self.push fixnum ? param : param.value
    return fixnum ? param : param.value
  end
end

arr = [1,2]
arr.m5loop{|v| p v}
arr.m5loop{|v| p v}
