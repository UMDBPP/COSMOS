def get_star_files ()


  for i in 0..9
  cmd("STAR", "FILEINFO", "FILEIDX" => i);
  
  wait_check_packet("STAR", "FILEINFO", 1, 2, 0.1)

  filename = tlm("STAR FILEINFO FILENAME")
  set_tlm("STAR_META FILES FILENAME#{i+1} = '" << filename << "'")
  
  filesize = tlm("STAR FILEINFO FILESIZE")
  set_tlm("STAR_META FILES FILESIZE#{i+1}= " << filesize.to_s())
  
  cmd("STAR", "FILECHKSUM", "FILEIDX" => i);
  
  wait_check_packet("STAR", "FILECHKSUM", 1, 2, 0.1)
  
  filechecksum = tlm("STAR FILECHKSUM CHCKSUM")
  set_tlm("STAR_META FILES FILECHKSUM#{i+1}= " << filechecksum.to_s())
  
  end
  
end
