class I2CStub
  def initialize(addr, wait=0)
    @addr, @wait = addr, wait
    @reg = 0
    @register = []
  end
  # def _read(len, type=:as_array)
  #   res = []
  #   len.times {|i|
  #     v = @register[@reg]
  #     res << v ? v : 0
  #     @reg += 1
  #   }
  #   return type == :as_string ? res.map {|v| v.chr}.join : res
  # end
  def read(reg, len, type=:as_array)
    res = []
    len.times {|i|
      v = @register[reg]
      res << v ? v : 0
      reg += 1
    }
    return type == :as_string ? res.map {|v| v.chr}.join : res
  end
  def write(*args)
    @reg = args.shift
    args.each {|v|
      @register[@reg] = v
      @reg += 1
    }
  end
  def _start; end
  def _end; end
end

Plato::I2C.register_device(I2CStub)

assert('PlatoDevice::SX1508B', 'type') do
  assert_equal(Module, PlatoDevice::SX1508B.class)
  assert_equal(Class, PlatoDevice::SX1508B::LED.class)
end

assert('PlatoDevice::SX1508B::LED', 'setup') do
  PlatoDevice::SX1508B::LED.setup(0)
  assert_equal(PlatoDevice::SX1508B::LED, PlatoDevice::SX1508B::LED[0].class)
  assert_nil(PlatoDevice::SX1508B::LED[1])
  PlatoDevice::SX1508B::LED.setup(1, 3, 5)
  assert_nil(PlatoDevice::SX1508B::LED[0])
  assert_equal(PlatoDevice::SX1508B::LED, PlatoDevice::SX1508B::LED[1].class)
  assert_nil(PlatoDevice::SX1508B::LED[2])
  assert_equal(PlatoDevice::SX1508B::LED, PlatoDevice::SX1508B::LED[3].class)
  assert_nil(PlatoDevice::SX1508B::LED[4])
  assert_equal(PlatoDevice::SX1508B::LED, PlatoDevice::SX1508B::LED[5].class)
  assert_nil(PlatoDevice::SX1508B::LED[6])
  assert_nil(PlatoDevice::SX1508B::LED[7])
  assert_raise(TypeError) {
    PlatoDevice::SX1508B::LED.setup(:red)
  }
end

assert('PlatoDevice::SX1508B::LED', 'on/off/pwm') do
  PlatoDevice::SX1508B::LED.setup(1, 2, 3)
  assert_nothing_raised {
    PlatoDevice::SX1508B::LED[1].on
    PlatoDevice::SX1508B::LED[2].off
    PlatoDevice::SX1508B::LED[3].pwm(128)
  }
  assert_raise(ArgumentError) {
    PlatoDevice::SX1508B::LED[3].pwm
  }
  assert_raise(ArgumentError) {
    PlatoDevice::SX1508B::LED[3].pwm(1, 2)
  }
end

assert('PlatoDevice::SX1508B::LED', 'blink') do
  PlatoDevice::SX1508B::LED.setup(2)
  led = PlatoDevice::SX1508B::LED[2]
  assert_nothing_raised {
    led.blink(16)
    led.blink(31, 16)
    led.blink(24, 24, 192)
    led.blink(24, 24, 128, 7)
  }
  assert_raise(ArgumentError) {
    led.blink
  }
  assert_raise(ArgumentError) {
    led.blink(24, 24, 128, 7, 16)
  }
end
