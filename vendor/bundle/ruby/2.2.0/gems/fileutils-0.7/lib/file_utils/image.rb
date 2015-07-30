require 'RMagick'

module FileUtils

    module Image

        def self.dimensions (path)
            img = Magick::Image.read(path)[0]
            { :width => img.columns, :height => img.rows }
        end

        def self.scale (source, target, width, height = nil)
            height = width unless height

            # Scale source
            simg = Magick::Image.read(source)[0]

            if simg.columns > width && simg.rows > height
                simg.resize_to_fit!(width, height)
            end
                        
            # Create transparent image
            timg = Magick::Image.new(width, height)
            d = Magick::Draw.new
            d.fill('white')
            d.draw(timg)
            timg = timg.transparent('white')

            # Insert thumb
            timg.composite!(simg, Magick::CenterGravity, Magick::OverCompositeOp)

            # Save result
            timg.write(target)
        end

    end
    
end