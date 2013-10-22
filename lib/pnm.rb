# = pnm.rb - create/read/write PNM image files (PBM, PGM, PPM)
#
# See PNM module for documentation.

require_relative 'pnm/version'
require_relative 'pnm/image'
require_relative 'pnm/parser'
require_relative 'pnm/converter'


# PNM is a pure Ruby library for creating, reading,
# and writing of +PNM+ image files (Portable AnyMap):
#
# - +PBM+ (Portable Bitmap),
# - +PGM+ (Portable Graymap), and
# - +PPM+ (Portable Pixmap).
#
# == Examples
#
# Create an image from an array of gray values:
#
#     require 'pnm'
#
#     pixels = [[0, 1, 2],
#               [1, 2, 3]]
#     image = PNM::Image.new(:pgm, pixels, {:maxgray => 3, :comment => 'Image'})
#
# Write an image to a file:
#
#     image.write('test.pgm')
#
# Read an image from a file:
#
#     image = PNM.read('test.pgm')
#     image.info     # => "PGM 3x2 Grayscale"
#     image.comment  # => "Image"
#     image.maxgray  # => 3
#     image.pixels   # => [[0, 1, 2], [1, 2, 3]]
#
# == See also
#
# Further information on the PNM library is available on the
# project home page: <https://github.com/stomar/pnm/>.
#
# == Author
#
# Copyright (C) 2013 Marcus Stollsteimer
#
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
#
#--
#
# == PNM magic numbers
#
#  Magic Number  Type              Encoding
#  ------------  ----------------  -------
#  P1            Portable bitmap   ASCII
#  P2            Portable graymap  ASCII
#  P3            Portable pixmap   ASCII
#  P4            Portable bitmap   Binary
#  P5            Portable graymap  Binary
#  P6            Portable pixmap   Binary
#
#++
#
module PNM

  LIBNAME  = 'pnm'                                                # :nodoc:
  HOMEPAGE = 'https://github.com/stomar/pnm'                      # :nodoc:
  TAGLINE  = 'create/read/write PNM image files (PBM, PGM, PPM)'  # :nodoc:

  COPYRIGHT = <<-copyright.gsub(/^ +/, '')                        # :nodoc:
    Copyright (C) 2012-2013 Marcus Stollsteimer.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
  copyright

  # Reads an image file.
  #
  # Returns a PNM::Image object.
  def self.read(file)
    raw_data = nil
    if file.kind_of?(String)
      raw_data = File.binread(file)
    else
      file.binmode
      raw_data = file.read
    end

    content = Parser.parse(raw_data)

    case content[:magic_number]
    when 'P1'
      type = :pbm
      encoding = :ascii
    when 'P2'
      type = :pgm
      encoding = :ascii
    when 'P3'
      type = :ppm
      encoding = :ascii
    when 'P4'
      type = :pbm
      encoding = :binary
    when 'P5'
      type = :pgm
      encoding = :binary
    when 'P6'
      type = :ppm
      encoding = :binary
    end

    width   = content[:width].to_i
    height  = content[:height].to_i
    maxgray = content[:maxgray].to_i
    pixels = if encoding == :ascii
               Converter.ascii2array(type, content[:data])
             else
               Converter.binary2array(type, width, height, content[:data])
             end

    options = {:maxgray => maxgray}
    options[:comment] = content[:comments].join("\n")  if content[:comments]

    Image.new(type, pixels, options)
  end

  def self.magic_number  # :nodoc:
    {
      :pbm => {:ascii => 'P1', :binary => 'P4'},
      :pgm => {:ascii => 'P2', :binary => 'P5'},
      :ppm => {:ascii => 'P3', :binary => 'P6'}
    }
  end
end
