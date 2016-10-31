
for i in 0..100
   
   cmd("CAMERA HK_REQ")
   sleep(0.25)
   cmd("CAMERA ENV_STAT_REQ")
   sleep(0.25)
   cmd("CAMERA PWR_STAT_REQ")
   sleep(0.25)
   cmd("CAMERA IMU_STAT_REQ")
   sleep(0.25)
   cmd("LINK GND_HK_REQ")
   sleep(0.25)
   cmd("LINK TLMFLTRTBL")
   $i +=1
   for ii in 0..10
      puts("sleep #{ii} sec" )
      sleep(1)  
   end
end