# mruby-plato-led-sx1508b

PlatoDevice::SX1508B::LED class

## install by mrbgems

- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

  # ... (snip) ...

  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-i2c'
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-i2c-nrf52'   # I2C device class for your device
  conf.gem :git => 'https://github.com/mruby-plato/mruby-plato-led-sx1508b'
end
```

## example
```ruby
PlatoDevice::SX1509B::LED.setup(0, 1, 2)  # Use LED0, LED1 and LED2
LED[0].on
LED[1].pwm(128)
LED[2].blink(16, 31)
```

## License
under the MIT License:
- see LICENSE file
