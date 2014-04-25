module Maybe
  class Maybe
    ([:each] + Enumerable.instance_methods).each do |enumerable_method|
      define_method(enumerable_method) { |*args, &block|
        res = __enumerable_value.send(enumerable_method, *args, &block)
        if res.respond_to?(:each) then Maybe(res[0]) else res end
      }
    end
  end

  class Some < Maybe
    def get() @value; end
    def getOrElse(els) @value; end
    def isSome() true; end
    def isNone() false; end
    def initialize(value) @value = value; end
    def method_missing(method_sym, *args, &block)
      Maybe(@value.send(method_sym, *args, &block))
    end

    private
    def __enumerable_value() [@value]; end
  end

  class None < Maybe
    def get() raise "No such element"; end
    def getOrElse(els=nil) block_given? ? yield : els; end
    def isSome() false; end
    def isNone() true; end
    def method_missing(method_sym, *args, &block)
      None.new
    end

    private
    def __enumerable_value() []; end
  end
end

def Maybe(value)
  if value == nil || (value.respond_to?(:length) && value.length == 0)
    Maybe::None.new()
  else
    Maybe::Some.new(value)
  end
end