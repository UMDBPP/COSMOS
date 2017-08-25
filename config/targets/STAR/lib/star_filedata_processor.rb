class StarFiledataProcessor < Cosmos::Processor
  def initialize()
    puts "This is the filedata processor"
    
  end

  def call(packet, buffer)
    
    puts "FileData Call method:"
    filename = Dir.pwd << '/' << packet.read("FILENAME").strip
    
    puts "Writing to #{filename}"
    # open and append to file
    target = open(filename, 'a')
  
    # write the data to the file
    target.write(packet.read("FILEDATA"))
  
    target.close
    
  end
  
  
end