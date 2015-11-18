=begin
===============================================================================
  更安全的 alias 方式
===============================================================================

【说明】

  对于继承自父类且在当前类未定义的方法，先显式定义，再 alias

  instance_methods(false).include?(:method_name) ||
    (def method_name; super; end)

  （细节：http://rm.66rpg.com/thread-383400-1-1.html）

=end
class A
  def method1; p 'method1:A'; end
  def method2; p 'method2:A'; end
  def method3; p 'method3:A'; end
end
class B < A; end
class C < B
  def method3
    super
    p 'method3:C0'
  end
end

class C
  instance_methods(false).include?(:method2) ||
    (def method2; super; end)
  instance_methods(false).include?(:method3) ||
    (def method3; super; end)

  alias c_method1 method1
  alias c_method2 method2
  alias c_method3 method3
  def method1
    c_method1
    p 'method1:C'
  end
  def method2
    c_method2
    p 'method2:C'
  end
  def method3
    c_method3
    p 'method3:C'
  end
end

class B
  alias b_method1 method1
  alias b_method2 method2
  alias b_method3 method3

  def method1
    b_method1
    p 'method1:B'
  end
  def method2
    b_method2
    p 'method2:B'
  end
  def method3
    b_method3
    p 'method3:B'
  end
end

test = C.new
test.method1
test.method2
test.method3