class StarFiledataProcessor < Cosmos::Processor
  def initialize(filename)
    puts "This is the filedata processor"
    
  end

  def call(packet, buffer)
    puts "FileData Call method:"
    puts packet
    #if(File.file?(filename))
    #  puts "File exists! Deleting"
    #else
    #  puts "File doesn't exist, read to write"
    #end
    
  end
  
  
end