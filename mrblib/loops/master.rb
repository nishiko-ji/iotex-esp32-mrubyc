def tof(i2c, display)
  p "tof now"
  sleep 1
end

def menu(i2c, display)
  p "menu now"
  sleep 1
end

def env2_init(i2c)
  p 'env2 init'
  sht3x = SHT3X.new(i2c)
  p "sht3x init"
  bmp280 = BMP280.new(i2c)
  p "bmp280 init"
  return bmp280, sht3x
end

def env2(i2c, display, bmp280, sht3x)
  temp_s = sht3x.readTemperature
  temp_b = bmp280.readTemperature
  pressure = bmp280.readPressure
  p "#{temp_s} C"
  p "#{temp_b} C, #{pressure / 100} hPa" 
  draw_back(display)
  str = sprintf("%.1f\n%.1f\n%d", temp_s, temp_b, pressure / 100)
  display.writeString(str, 189, 75, 14, 31, 28, ILI934X.color(0x27, 0x1c, 0x19), nil)
  sleep 1
end

def draw_back(display)
  xs = [184, 217, 250] 
  ys = [70, 103, 136, 170]
  2.times do |x|
    3.times do |y|
      display.drawRectangle(xs[x], xs[x + 1], ys[y], ys[y + 1], ILI934X.color(255, 222, 179))
    end
  end
end

swpins = [39, 38, 37]
switches = []
swpins.each do |swpin|
  switches << GPIO.new(swpin, GPIO::IN, GPIO::PULL_UP)
end

i2c = I2C.new(22, 21)
display = ILI934X.new(23, 18, 14, 27, 33, 32)
state = 1

while true
  switches.each_with_index do |sw, i|
    if sw.read == 1
      state = i
    end
  end
  case state
  when 0
    tof(i2c, display)
  when 1
    menu(i2c, display)
  when 2
    env2(i2c, display)
  end
end
