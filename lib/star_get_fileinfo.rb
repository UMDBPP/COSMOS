def get_star_fileinfo (fileIdx)

  cmd("STAR", "FILEINFO", "FILEIDX" => fileIdx);
  
  wait_check_packet("STAR", "FILEINFO", 1, 0.5, 0.1)

  filename = tlm("STAR FILEINFO FILENAME")
  set_tlm("STAR_META FILEINFO FILENAME_#{fileIdx} = '" << filename << "'")
  
  filesize = tlm("STAR FILEINFO FILESIZE")
  set_tlm("STAR_META FILEINFO FILESIZE_#{fileIdx}= " << filesize.to_s())
  
  chcksum = tlm("STAR FILEINFO CHCKSUM")
  set_tlm("STAR_META FILEINFO FILECHKSUM_#{fileIdx}= " << chcksum.to_s())
    
end
