require File.dirname(__FILE__) + "/../test_helper"

class PdfTest < Test::Unit::TestCase

    TEST_PDF = File.dirname(__FILE__) + "/../helpers/2pages.pdf"

    def test_pdf_exists
        assert_nothing_raised do
            FileUtils::Pdf
        end
    end

    def test_pdf_metas
        assert_nothing_raised do
            metas = FileUtils::Pdf.metas(TEST_PDF)
            assert_kind_of Hash, metas
            assert_equal 'OpenOffice.org 3.2', metas['Producer']
        end
    end

    def test_pdf_pages
        assert_equal 2, FileUtils::Pdf.pages(TEST_PDF)
    end

    def test_pdf_screenshot
        target1 = File.dirname(__FILE__) + "/../../pdf1.jpg"
        target2 = File.dirname(__FILE__) + "/../../pdf2.jpg"
        target3 = File.dirname(__FILE__) + "/../../pdf3.jpg"

        [target1, target2, target2].each do |target|
            File.delete(target) if File.exists?(target)
        end
                
        assert_nothing_raised do
            FileUtils::Pdf.preview(TEST_PDF, target1)
            assert File.exists?(target1)
            FileUtils::Pdf.preview(TEST_PDF, target2, 0)
            assert File.exists?(target2)
            FileUtils::Pdf.preview(TEST_PDF, target3, 1)
            assert File.exists?(target3)
            assert_equal IO.read(target1), IO.read(target2)
        end
    end

    def test_pdf_merge
        source1 = File.dirname(__FILE__) + "/../helpers/2pages.pdf"
        source2 = File.dirname(__FILE__) + "/../helpers/pdf2.pdf"
        target  = File.dirname(__FILE__) + "/../../result.pdf"

        File.delete(target) if File.exists?(target)

        assert_nothing_raised do
            FileUtils::Pdf.merge(target, source1, source2)
            assert File.exists?(target)
            assert_equal 3, FileUtils::Pdf.pages(target)
        end
    end

    def test_pdf_merge_3
        source1 = File.dirname(__FILE__) + "/../helpers/2pages.pdf"
        source2 = File.dirname(__FILE__) + "/../helpers/pdf2.pdf"
        source3 = File.dirname(__FILE__) + "/../helpers/pdf3.pdf"
        target  = File.dirname(__FILE__) + "/../../result.pdf"

        File.delete(target) if File.exists?(target)

        assert_nothing_raised do
            FileUtils::Pdf.merge(target, source1, source2, source3)
            assert File.exists?(target)
            assert_equal 4, FileUtils::Pdf.pages(target)
        end
    end

end