require 'cosmos'

class StarBeginfileProcessor < Cosmos::Processor
  def initialize()
    puts "This is the stardata processor"
  end

  def call(packet, buffer)

    filename = packet.read("FILENAME").strip
    if(File.file?(filename))
      puts "File '#{filename}' exists! Deleting"
    else
      puts "File '#{filename}' doesn't exist, ready to write"
    end
  end
  
  
end