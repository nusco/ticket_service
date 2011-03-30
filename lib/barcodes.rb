def barcode(abus_code, atram_code)
  require 'barby'
  require 'barby/outputter/png_outputter'
  Barby::QrCode.new("#{abus_code}_#{atram_code}").to_png
end
