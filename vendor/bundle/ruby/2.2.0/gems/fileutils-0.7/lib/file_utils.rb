require 'RMagick'

module FileUtils
        
    # Creates a screenshot from the given url
    # Uses CutyCapt (cutycapt.sourceforge.net)
    def capture (url, target)
        command = FileUtils::Config::Xvfb.command(File.dirname(__FILE__) + "/../bin/CutyCapt --min-width=1024 --min-height=768 --url=#{url} --out=#{target}")
        `#{command}`
    end

    module_function :capture

    # Sources consists of paths followed by the filename that must be used in the zip 
    def zip (target, *sources)
        targetdir = "#{FileUtils::Config.tmp_dir}/zip"
        id = 1
        while File.exists?(targetdir)
            targetdir = "#{FileUtils::Config.tmp_dir}/zip#{id}"
            id += 1
        end
        FileUtils.mkdir(targetdir)

        path = ''
        sources.each do |value|
            if path == ''
                path = value
            else
                FileUtils.copy(path, "#{targetdir}/#{value}")
                path = ''
            end
        end

        `#{FileUtils::Config.zip} -j #{target} #{targetdir}/*`

        FileUtils.rm_rf(targetdir)
    end

    module_function :zip

    def extension (filename)
        return '' unless filename.include?('.')
        filename.split('.').last
    end

    module_function :extension

    def preview (source, target, width, height)
        extension = self.extension(source).upcase

        # Image ?
        formats = Magick.formats
        if formats.key?(extension) && formats[extension].include?('r')
            begin
                FileUtils::Image.scale(source, target, width, height)
                return true
            rescue
                return false
            end
        end

        tmppdf = self.temp('pdf')
        tmppng = self.temp('png')
        begin
            # Create a pdf of the document
            FileUtils::OpenOffice.convert(source, tmppdf)
            # Create a screenshot of first page of the generated pdf
            FileUtils::Pdf.preview(tmppdf, tmppng)
            # Scale it down to thumb
            FileUtils::Image.scale(tmppng, target, width, height)
            return true
        rescue

        ensure
            # Cleanup
            File.delete(tmppdf) if File.exists?(tmppdf) && File.writable?(tmppdf)
            File.delete(tmppng) if File.exists?(tmppng) && File.writable?(tmppng)
        end

        nil
    end

    module_function :preview

    # Generates a temp filepath for the given extension
    def temp (extension)
        path = "#{FileUtils::Config.tmp_dir}/tmp.#{extension}"
        id = 1
        while File.exists?(path)
            path = "#{FileUtils::Config.tmp_dir}/tmp.#{id}.#{extension}"
            id += 1
        end

        path
    end

    module_function :temp

    # Tries to convert content of file to plaintext or html
    def index (path)
        extension = FileUtils.extension(path).downcase

        if extension == 'txt'
            return IO.read(path)
        end

        if extension == 'html' || extension == 'htm'
            return IO.read(path)
        end

        tmp = self.temp('html')
        begin
            FileUtils::OpenOffice.convert(path, tmp)
            return IO.read(tmp) if File.exists?(tmp)
        rescue
        ensure
            File.delete(tmp) if File.exists?(tmp) && File.writable?(tmp)
        end

        ''
    end

    module_function :index

    autoload :Image,        File.dirname(__FILE__) + "/file_utils/image"
    autoload :OpenOffice,   File.dirname(__FILE__) + "/file_utils/open_office"
    autoload :Config,       File.dirname(__FILE__) + "/file_utils/config"
    autoload :Pdf,          File.dirname(__FILE__) + "/file_utils/pdf"

end