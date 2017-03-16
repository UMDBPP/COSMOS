class StarEndfileProcessor < Cosmos::Processor
  def initialize(filesize, filechecksum)
    puts "This is the endfile processor"
    
  end

  def call(packet, buffer)
    puts "Endfile Call method:"
    puts packet
    #if(File.file?(filename))
    #  puts "File exists! Deleting"
    #else
    #  puts "File doesn't exist, read to write"
    #end
    
  end
  
  
end