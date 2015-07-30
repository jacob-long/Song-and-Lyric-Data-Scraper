require File.dirname(__FILE__) + "/../test_helper"

class FileUtilsTest < Test::Unit::TestCase

    def test_capture
        assert_nothing_raised do
            path = File.dirname(__FILE__) + "/../../google.png"
            File.delete(path) if File.exists?(path)
            FileUtils.capture('http://www.google.be', path)
            assert File.exists?(path)
        end
    end

    def test_zip
        target = File.dirname(__FILE__) + "/../../result.zip"
        source1 = File.dirname(__FILE__) + "/../helpers/2pages.pdf"
        source2 = File.dirname(__FILE__) + "/../helpers/test.odt"

        File.delete(target) if File.exists?(target)

        assert_nothing_raised do
            FileUtils.zip(target, source1, 'doc.pdf', source2, 'doc.odt')
            assert File.exists?(target)
        end
    end

    def test_extension
        assert_equal 'exe', FileUtils.extension('test.exe')
    end

    def test_extension_none
        assert_equal '', FileUtils.extension('test')
    end

    def test_preview
        target = File.dirname(__FILE__) + "/../../result.png"

        assert_nothing_raised do
            source = File.dirname(__FILE__) + "/../../README"
            
            assert_nil FileUtils.preview(source, target, 100, 100)

            # Image
            source = File.dirname(__FILE__) + "/../helpers/scale.jpg"

            File.delete(target) if File.exists?(target)

            assert FileUtils.preview(source, target, 100, 100), 'Creation of image preview'
            assert File.exists?(target), 'File exists? preview of image'

            # Document
            source = File.dirname(__FILE__) + "/../helpers/test.odt"

            File.delete(target) if File.exists?(target)

            assert FileUtils.preview(source, target, 100, 100), 'Creation of odt preview'
            assert File.exists?(target), 'File exists? preview of odt'
        end
    end

    def test_temppath
        assert_nothing_raised do
            path1 = FileUtils.temp('jpg')
            assert_equal "#{FileUtils::Config.tmp_dir}/tmp.jpg", path1

            FileUtils.touch(path1)

            path2 = FileUtils.temp('jpg')
            assert_equal "#{FileUtils::Config.tmp_dir}/tmp.1.jpg", path2

            File.delete(path1)
        end
    end

    def test_index
        assert_nothing_raised do
            assert_equal '', FileUtils.index(File.dirname(__FILE__) + "/../helpers/scale.jpg")
            assert_equal 'test', FileUtils.index(File.dirname(__FILE__) + "/../helpers/test.txt")
            assert FileUtils.index(File.dirname(__FILE__) + "/../helpers/test.odt").include?('TEST'), 'TEST in odt'
            assert_equal 'TESTING', FileUtils.index(File.dirname(__FILE__) + "/../helpers/test.html")
            assert_equal 'TEST.HTM', FileUtils.index(File.dirname(__FILE__) + "/../helpers/test.htm")
        end
    end

    def test_preview_mpg
        source = File.dirname(__FILE__) + "/../helpers/test.mpg"
        target = FileUtils.temp('png')
        File.delete(target) if File.exists?(target)
        assert_nothing_raised do
            assert_equal false, FileUtils.preview(source, target, 160, 200)
        end
    end

end