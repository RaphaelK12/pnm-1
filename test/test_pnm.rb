# test_pnm.rb: Unit tests for the PNM library.
#
# Copyright (C) 2013 Marcus Stollsteimer

require 'minitest/spec'
require 'minitest/autorun'
require 'pnm'


describe PNM do

  before do
    @srcpath = File.dirname(__FILE__)
  end

  it 'can read an ASCII encoded PBM file' do
    file = File.expand_path("#{@srcpath}/bilevel_ascii.pbm")
    image = PNM.read(file)

    image.info.must_match %r{^PBM 5x6 Bilevel}
    image.maxgray.must_equal 1
    image.pixels.must_equal [[0,0,0,0,0],
                             [0,1,1,1,0],
                             [0,0,1,0,0],
                             [0,0,1,0,0],
                             [0,0,1,0,0],
                             [0,0,0,0,0,]]
  end

  it 'can read an ASCII encoded PGM file' do
    file = File.expand_path("#{@srcpath}/grayscale_ascii.pgm")
    image = PNM.read(file)

    image.info.must_match %r{^PGM 4x3 Grayscale}
    image.maxgray.must_equal 250
    image.pixels.must_equal [[  0, 50,100,150],
                             [ 50,100,150,200],
                             [100,150,200,250]]
  end

  it 'can read an ASCII encoded PPM file' do
    file = File.expand_path("#{@srcpath}/color_ascii.ppm")
    image = PNM.read(file)

    image.info.must_match %r{^PPM 5x3 Color}
    image.maxgray.must_equal 6
    image.pixels.must_equal [[[0,6,0], [1,5,1], [2,4,2], [3,3,4], [4,2,6]],
                             [[1,5,2], [2,4,2], [3,3,2], [4,2,2], [5,1,2]],
                             [[2,4,6], [3,3,4], [4,2,2], [5,1,1], [6,0,0]]]
  end
end
