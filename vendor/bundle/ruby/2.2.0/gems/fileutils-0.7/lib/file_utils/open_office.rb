module FileUtils

    module OpenOffice

        autoload :Server,   File.dirname(__FILE__) + "/open_office/server"

        # Converts the given source to target
        #
        # Possible parameters:
        # source (path to source file) + target (path to target file)
        # content (content of source file) + source extension (extension of source file) + target extension (extension of target file)
        def self.convert (*args)
            if args.length == 2
                source = args[0]
                target = args[1]
            elsif args.length == 3
                source = FileUtils.temp(args[1])
                target = FileUtils.temp(args[2])
                # Save Content
                File.open(source, 'w') do |file|
                    file.write args[0]
                end
            else
                raise ArgumentError.new('wrong number of arguments')
            end
            command = File.dirname(__FILE__) + "/../../bin/DocumentConverter.py"
            result = `#{FileUtils::Config::OpenOffice.python} #{command}  #{source} #{target} #{FileUtils::Config::OpenOffice.port}`
            raise result unless result.strip == ''

            if args.length == 3
                result = IO.read(target)
                File.delete(source)
                File.delete(target) if File.writable?(target)
                result
            end
        end

    end

end