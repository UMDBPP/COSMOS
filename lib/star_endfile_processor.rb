class StarEndfileProcessor < Cosmos::Processor
  def initialize(filesize, filechecksum)
    puts "This is the endfile processor"
    
  end

  def call(packet, buffer)
    puts "Endfile Call method:"
    puts packet
    
    filename = packet.read("FILENAME").strip
    expected_chksum = packet.read("CHCKSUM")
    calc_chksum = 0xFF
    
    if(File.file?(filename))
      # open and read from file
      file = open(filename, 'r')
    
      # loop through file and calculate checksum
      while (buffer = file.read(1)) do
        calc_chksum = calc_chksum ^ buffer
      end
    
      file.close
      
      if(calc_chksum == expected_chksum)
        puts "File checksum matched!"
      else
        puts "File checksum didn't match... don't trust that file"
      end
    else
      puts "File doesn't exist, can't confirm checksum"
    end
    
  end
  
  
end