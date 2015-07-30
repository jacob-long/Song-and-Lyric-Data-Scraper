require 'RMagick'

module FileUtils

    module Pdf

        def self.metas (path)
            metas = {}

            key = ''
            `#{FileUtils::Config.pdftk} #{path} dump_data`.gsub("\r\n", "\n").gsub("\r", "\n").split("\n").each do |line|
                parts = line.split(':')
                parts[1] = parts[1].gsub('&#0;', '')
                if parts[0] == 'InfoValue'
                    if key != ''
                        metas[key] = parts[1].strip
                        key = ''
                    end
                elsif parts[0] == 'InfoKey'
                    key = parts[1].strip
                else
                    metas[parts[0].strip] = parts[1].strip
                end
            end            

            metas
        end

        def self.pages (path)
            metas(path)['NumberOfPages'].to_i
        end

        # Generates an image of a pdf page
        # Page starts with 0
        def self.preview (source, target, page = 0)
            pdf = Magick::ImageList.new(source)[page]
            pdf.write target
        end

        # Merges the given pdfs into a single pdf
        def self.merge (target, *sources)
            `#{FileUtils::Config.pdftk} #{sources.join(' ')} cat output #{target}`
        end
        
    end

end