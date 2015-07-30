require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < Test::Unit::TestCase

    def test_image_exists
        assert_nothing_raised do
            FileUtils::Image
        end
    end

    def test_image_dimensions
        dim =  { :width => 150, :height => 200 }
                
        assert_equal dim, FileUtils::Image.dimensions(File.dirname(__FILE__) + "/../helpers/img150x200.jpg")
    end

    def test_image_scale
        dim = { :width => 100, :height => 100 }
        source = File.dirname(__FILE__) + "/../helpers/scale.jpg"
        target = File.dirname(__FILE__) + "/../../target.png"

        File.delete(target) if File.exists?(target)

        FileUtils::Image.scale(source, target, 100)
        assert File.exists?(target)
        assert_equal dim, FileUtils::Image.dimensions(target)
    end

    def test_image_scale_width_and_height
        dim = { :width => 100, :height => 150 }
        source = File.dirname(__FILE__) + "/../helpers/scale.jpg"
        target = File.dirname(__FILE__) + "/../../target2.png"

        File.delete(target) if File.exists?(target)

        FileUtils::Image.scale(source, target, 100, 150)
        assert File.exists?(target)
        assert_equal dim, FileUtils::Image.dimensions(target)
    end

    def test_image_scale_width_and_height_big
        dim = { :width => 1000, :height => 1500 }
        source = File.dirname(__FILE__) + "/../helpers/scale.jpg"
        target = File.dirname(__FILE__) + "/../../target3.png"

        File.delete(target) if File.exists?(target)

        FileUtils::Image.scale(source, target, 1000, 1500)
        assert File.exists?(target)
        assert_equal dim, FileUtils::Image.dimensions(target)
    end
    
end