class StarFiledataProcessor < Cosmos::Processor
  def initialize(filename)
    puts "This is the filedata processor"
    
  end

  def call(packet, buffer)
    
    puts "FileData Call method:"
    filename = packet.read("FILENAME").strip
    if(File.file?(filename))
      # open and append to file
      target = open(filename, 'a')
    
      # write the data to the file
      target.write(packet.read("FILEDATA"))
    
      target.close
    else
      puts "File doesn't exist, failed to write"
    end
    
  end
  
  
end