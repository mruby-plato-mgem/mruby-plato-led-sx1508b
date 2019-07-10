module PlatoDevice
  module SX1508B
    # constants
    I2C_ADDR = 0x20

    class LED
      # constants
      LEDREGS = [
        [0x16],
        [0x17],
        [0x19, 0x18, 0x1a],
        [0x1c, 0x1b, 0x1d, 0x1e, 0x1f],
        [0x20],
        [0x21],
        [0x23, 0x22, 0x24],
        [0x26, 0x25, 0x27, 0x28, 0x29]
      ]

      # class variables
      @@i2c = nil
      @@leds = []

      def initialize(id, ion, ton=nil, off=nil, trise=nil, tfall=nil)
        @id, @ion, @ton, @off, @trise, @tfall = id, ion, ton, off, trise, tfall
        @@i2c = Plato::I2C.open(I2C_ADDR) unless @@i2c
      end

      # LED#pwm(v)
      # Writes PWM value to LED.
      # <params>
      #   v:  PWM duty (0..255)
      def pwm(v)
        regdata = @@i2c.read(0x08, 1)
        @@i2c.write([0x08, regdata[0] | (1 << @id)])
        @@i2c.write([@ion, v])
        @@i2c.write([0x08, regdata[0]])
      end

      # LED#off
      # Turns off LED.
      def off
        pwm(0x00)
      end

      # LED#on
      # Turns on LED.
      def on
        pwm(0xff)
      end

      # LED#blink(ton, toff, ion, ioff)
      # Blink LED.
      # <params>
      #   ton:  ON time of LED.
      #         0:  infinite
      #         1..15:  64 * ton * 255 / Clk
      #         16..32: 512 * ton * 255 / Clk
      #   toff: OFF time of LED.
      #         0:  infinite
      #         1..15:  64 * ton * 255 / Clk
      #         16..32: 512 * ton * 255 / Clk
      #   ion:  PWM value at LED ON. (0..255)
      #   ioff: PWM value at LED OFF. (0..7)
      def blink(ton, toff=nil, ion=0xff, ioff=0x00)
        if (@ton && @off)
          toff = ton unless toff
          regdata = @@i2c.read(0x08, 1)
          @@i2c.write([0x08, regdata[0] | (1 << @id)])
          @@i2c.write([@ion, ion])
          @@i2c.write([@ton, ton])
          @@i2c.write([@off, (toff << 3) | (ioff & 0b00000111)])
          @@i2c.write([0x08, regdata[0] & ~(1 << @id)])
        end
      end

      #
      # Class methods
      #
      class << self
        def setup(*leds)
          @@leds = []
          @@ledbit = 0
      
          # LEDs
          leds.each {|led|
            if params = LEDREGS[led]
              @@leds[led] = LED.new(led, *params) unless @@leds[led]
              @@ledbit |= (1 << led)
            end
          }

          @@ledbit = leds.inject(0) {|bits, b| bits |= 1 << b}
          r_ledbit = ~@@ledbit & 0xff
      
          # RegReset #1:0x12, #2:0x34
          @@i2c.write([0x7d, 0x12])
          @@i2c.write([0x7d, 0x34])
          # RegInputDisable
          @@i2c.write([0x00, @@ledbit])
          # RegPullUp
          @@i2c.write([0x03, 0x00])
          # RegOpenDrain
          @@i2c.write([0x05, @@ledbit])
          # RegDir
          @@i2c.write([0x07, r_ledbit])
          # RegClock
          @@i2c.write([0x0f, 0x40])   # b6:5=10
          # RegMisc
          @@i2c.write([0x10, 0x1c])   # b6:4=001, b3=1, b1=1
          # RegLEDDriverEnable
          @@i2c.write([0x11, @@ledbit])
          # RegIOnX, RegTOnX, RegOffX, RegTRiseX, RegTFallX
          (0x16..0x29).each {|reg|
            @@i2c.write([reg, 0x00])
          }
          # RegData
          @@i2c.write([0x08, r_ledbit])
        end

        def [](id)
          @@leds[id]
        end
      end
    end
  end
end
