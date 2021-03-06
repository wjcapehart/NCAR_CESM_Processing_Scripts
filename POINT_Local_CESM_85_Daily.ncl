
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin

 ;   setfileoption("nc", "FileStructure", "Advanced")
 ;   setfileoption("nc", "Format",  "NetCDF4")

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;
   ;  User Modification Area
   ;
   ;   User selects Repositories, Years and File Locations
   ;

   ;
   ; Repository, and Date Runs
   ;

   rcploop = (/ "RCP45","RCP85" /)


   ;
   ; Clipbox Latitude and Longitudes
   ;

   ; CONUS

   far_south =  45.70681 ; degrees_north
   far_north =  far_south ; degrees_north

   far_west  =  257.5; degrees_east
   far_east  =  far_west; degrees_east

   if (far_west .le. 180) then
      coord_string = sprinti("E%0.3i_", toint(round(far_west,0))   )
   else
      coord_string = sprinti("W%0.3i_", toint(round(360-far_west,0)))
   end if


   if (far_west .ge. 0) then
      coord_string = coord_string + sprinti("N%0.2i", toint(abs(far_north)))
   else
      coord_string = coord_string + sprinti("S%0.2i", toint(abs(far_north)))
   end if





   ; SWAfrica

      ;;far_south =   23.00 ; degrees_north
      ;far_north =   55.00 ; degrees_north

      ;far_west  = -129.00 + 360.0; degrees_east
      ;far_east  =  -52.00 + 360.0; degrees_east

   ; Mongolia

      ;far_south =   23.00 ; degrees_north
      ;far_north =   55.00 ; degrees_north

      ;far_west  = -129.00 + 360.0; degrees_east
      ;far_east  =  -52.00 + 360.0; degrees_east



   parameters := (/  "QRUNOFF",         \
                     "FSNO",            \
                     "H2OSNO",          \
                     "SOILWATER_10CM",  \
                     "RAIN",            \
                     "SNOW",            \
                     "TREFHT",          \
                     "TREFHTMN",        \
                     "TREFHTMX",        \
                     "PRECTMX",         \
                     "PRECT",           \
                     "QBOT",            \
                     "UBOT",            \
                     "VBOT",            \
                     "PSL"              /)




   parameters := (/  "TREFHT",          \
                     "TREFHTMN",        \
                     "TREFHTMX",        \
                     "PRECTMX",         \
                     "PRECT",           \
                     "QBOT",           \
                     "PSL",             \
                     "QRUNOFF",         \
                     "FSNO",            \
                     "H2OSNO",          \
                     "SOILWATER_10CM",  \
                     "RAIN",            \
                     "SNOW",            \
                     "UBOT",            \
                     "VBOT"           /)





   final_dir          = "/glade/u/home/capehart/CESM_data/"
   scratch_dir        = final_dir + "scratch/"
   root_dir_20th      = "/glade/p/cesmLE/CESM-CAM5-BGC-LE/"
   post_root_dir_20th = "tseries/daily/"

do rcpl = 1,1

   rcp   = rcploop(rcpl)

   if (rcpl .eq. 0) then
       system("rm -frv /glade/u/home/capehart/CESM_data/scratch/deleteme45.nc")
   else
       system("rm -frv /glade/u/home/capehart/CESM_data/scratch/deleteme85.nc")
   end if

   print("=============================================")
   print("Processing "+rcp)



   if (rcp  .eq.  "RCP85") then



      n_ens = 30
      nens = n_ens



      root_dir    = "/glade/p/cesmLE/CESM-CAM5-BGC-LE/"
      post_root_dir = "tseries/daily/"


      part1 = (/ "b.e11.B20TRC5CNBDRD.f09_g16.",  \
                 "b.e11.BRCP85C5CNBDRD.f09_g16.", \
                 "b.e11.BRCP85C5CNBDRD.f09_g16." /)

      part2 = sprinti("%0.3i", ispan(1,n_ens,1))

      part3 = ".clm2.h0."

      part5 = (/ ".19200101-20051231.nc",  \
                 ".20060101-20801231.nc",  \
                 ".20810101-21001231.nc"  /)

      full_record = coord_string+"_DAILY_1920-2100"


      time_of_last_month = "66064"; "66065"; RCP8.5

      scratchfile = "/glade/u/home/capehart/CESM_data/scratch/deleteme85.nc"


   else

      root_dir    = "/glade/p/ncgd0014/CESM-CAM5-BGC-ME/"
      post_root_dir = "tseries/daily/"



      n_ens = 15
      nens = n_ens



      part1 = (/ "b.e11.B20TRC5CNBDRD.f09_g16.",  \
                 "b.e11.BRCP45C5CNBDRD.f09_g16." /)

      part2 = sprinti("%0.3i", ispan(1,n_ens,1))


      part5 = (/ ".19200101-20051231.nc",  \
                 ".20060101-20801231.nc"  /)

      full_record = coord_string+"_DAILY_1920-2080"

      time_of_last_month =  "58764";"58765"; RCP4.5

      scratchfile = "/glade/u/home/capehart/CESM_data/scratch/deleteme45.nc"

   end if

   ensemble_member                 = ispan(1,n_ens,1)
   ensemble_member!0               = "ensemble_member"
   ensemble_member&ensemble_member = ispan(1,n_ens,1)

   n_timefiles  = dimsizes(part5)
   n_parameters = dimsizes(parameters)

   tf = 0
   ef = 1
   vf = 0



   nco_spatial_extraction_string = " -d lat,"                  + \
                                    sprintf("%5.2f",far_south) + \
                                    ","                        + \
                                    sprintf("%5.2f",far_north) + \
                                    " -d lon,"                 + \
                                    sprintf("%6.2f",far_west)  + \
                                    ","                        + \
                                    sprintf("%6.2f",far_east)  + \
                                    " "

   ;
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ens1_date = 0
      ens1_date@units    = "days since 1850-01-01 00:00:00"
      ens1_date@calendar = "noleap"
   ensx_date    = 0
      ensx_date@calendar = "noleap"
      ensx_date@units    = "days since 1920-01-01 00:00:00"

   ens1_ens1_date_diff = cd_convert(ens1_date,ensx_date@units)

   delta_t_ens001_vs_ens00x =   -25550; <- this will be the dif between ens 1 and the other ensembles

   do vf = 0, n_parameters-1

      print("_____________________________________________")
      print("  Processing "+rcp+" "+parameters(vf))


      if ((parameters(vf) .eq. "QCHANR").or.(parameters(vf) .eq. "VOLR"))  then
         nco_spatial_extraction_string = " -d lat,"                  + \
                                          sprintf("%5.2f",far_south) + \
                                          ","                        + \
                                          sprintf("%5.2f",far_north) + \
                                          " -d lon,"                 + \
                                          sprintf("%6.2f",far_west-360.)  + \
                                          ","                        + \
                                          sprintf("%6.2f",far_east-360.)  + \
                                          " "
      else
         nco_spatial_extraction_string = " -d lat,"                  + \
                                          sprintf("%5.2f",far_south) + \
                                          ","                        + \
                                          sprintf("%5.2f",far_north) + \
                                          " -d lon,"                 + \
                                          sprintf("%6.2f",far_west)  + \
                                          ","                        + \
                                          sprintf("%6.2f",far_east)  + \
                                          " "
      end if

      if ((parameters(vf) .eq. "QCHANR") .or. \
          (parameters(vf) .eq. "VOLR")) then
         part3           = ".rtm.h1."
         cesm_module_dir = "rof/proc"
      else
         if ((parameters(vf) .eq. "FSNO")             .or. \
             (parameters(vf) .eq. "H2OSNO")           .or. \
             (parameters(vf) .eq. "QRUNOFF")          .or. \
             (parameters(vf) .eq. "RAIN")             .or. \
             (parameters(vf) .eq. "SNOW")             .or. \
             (parameters(vf) .eq. "SOILWATER_10CM")   .or. \
             (parameters(vf) .eq. "TREFMNAV_R")       .or. \
             (parameters(vf) .eq. "TREFMNAV_U")       .or. \
             (parameters(vf) .eq. "TREFMXAV_R")       .or. \
             (parameters(vf) .eq. "TREFMXAV_U"))      then
             part3           = ".clm2.h1."
             cesm_module_dir = "lnd/proc"
         else
            part3           = ".cam.h1."
            cesm_module_dir = "atm/proc"
         end if
      end if


      do ef = 0, n_ens-1

         print("---------------------------------------------")
         print("     Processing "+rcp+" "+parameters(vf)+" ens"+sprinti("e%0.3i", (ef + 1)))

         do tf = 0, n_timefiles-1

            print("- - - - - - - - - - - - - - - - - - - - - - -")
            print("        Processing "+rcp+" "+parameters(vf)+" ens"+sprinti("e%0.3i", (ef + 1))+" t"+sprinti("e%0.2i", (tf + 1)))


            system("rm -v " + scratchfile)

            string_year = part5(tf)

            if ((ef .eq. 0).and.(tf .eq. 0)) then
               string_year = ".18500101-20051231.nc"
               root_dir_w  = root_dir_20th
            else
               if (tf .eq. 0) then
                  string_year = part5(tf)
                  root_dir_w  = root_dir_20th
               else
                  string_year = part5(tf)
                  root_dir_w  = root_dir
               end if
            end if

            cesm_filename = root_dir_w        +       \
                            cesm_module_dir +     "/" +    \
                            post_root_dir    +   \
                            parameters(vf) +    "/" +  \
                            part1(tf)       +       \
                            part2(ef)       +       \
                            part3           +    \
                            parameters(vf)  +       \
                            string_year

            temp_file =     scratch_dir                 + \
                            parameters(vf)        + "_" + \
                            rcp                   + "_" + \
                            sprinti("e%0.3i", (ef + 1)) + \
                            "_"                         + \
                            sprinti("t%0.3i", (tf + 1)) + \
                            ".nc"

            ; extract spatial clipbox orig file -> scratch

            nco_command = "ncea "                       + \
                          nco_spatial_extraction_string + \
                          cesm_filename                 + \
                          " "                           + \
                          scratchfile

            print( " " + nco_command)
            system(" nohup " + nco_command)


            ; extract variable from clipped file scratch -> temp_000

               nco_command = "ncks -v "        + \
                              parameters(vf)    + \
                              " "               + \
                              scratchfile       + \
                              " "               + \
                              temp_file

               print( " " + nco_command)
               system(" nohup " + nco_command)

               print( "scratch -> temp_000 :: rm -v " + scratchfile)
               system("rm -v " + scratchfile)


         end do

         temp_files =    scratch_dir                 + \
                         parameters(vf)        + "_" + \
                         rcp                   + "_" + \
                         sprinti("e%0.3i", (ef + 1)) + \
                         "_t*.nc"

         ens_file =      scratch_dir                 + \
                         parameters(vf)        + "_" + \
                         rcp                   + "_" + \
                         sprinti("e%0.3i", (ef + 1)) + \
                         ".nc"

         ; concatemnate ensembles temp_000 -> ensemble_file.nc

         nco_command = "ncrcat -h " + temp_files + " " + ens_file
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; remove the temp_000

         print( "RM: rm -frv " + temp_files)
         system(" rm -frv " + temp_files)

      end do
      ;;
      ;;  we now have to reset the fist ensemble to start at 1920 rather than 1850
      ;;
      ;;  ncap -s "time_bounds=time_bounds-25550" -s  "time=time-25550"  ANN_FAREA_BURNED_RCP85_e001.nc temp.nc
      ;;
      ;;  ncatted -O -a long_name,time,a,c,"time" temp.nc
      ;;  ncatted -O -a units,time,a,c,"days since 1920-01-01 00:00:00" temp.nc
      ;;  ncatted -O -a calendar,time,a,c,"noleap" temp.nc
      ;;  ncatted -O -a bounds,time,a,c,"time_bounds" temp.nc
      ;;
      ;;  ncatted -O -a long_name,time_bounds,a,c,"history time interval endpoints" temp.nc
      ;;
      ;;  ncea  -d time,31.,66065. temp.nc  ANN_FAREA_BURNED_RCP85_e001.nc
      ;;
      ;;  rm -v temp.nc
      ;;
      ;;  ncecat ANN_FAREA_BURNED_RCP85_e00*.nc ANN_FAREA_BURNED_RCP85_CONUS.nc
      ;;
      ;;  ncrename -O -d record,ensemble  ANN_FAREA_BURNED_RCP85_CONUS.nc
      print("_____________________________________________")
      print("  Consolidating "+rcp+" "+parameters(vf))


      ens_001_file = scratch_dir          + \
                     parameters(vf) + "_" + \
                     rcp            + "_" + \
                     "e001"               + \
                     ".nc"

      ens_0xx_files = scratch_dir          + \
                      parameters(vf) + "_" + \
                      rcp            + "_" + \
                      "e*"                 + \
                      ".nc"

      ens_all_file = final_dir             + \
                     parameters(vf)    + "_" + \
                     rcp               + "_" + \
                     full_record             + \
                     ".nc"

      ;; fix the tme bounds for the first ensemnble member

         ; move zero date from 1850 to 1920 for the first ensemble ens_001 -> scratch


         if (part3 .ne. ".cam.h1.") then

            nco_command = "ncap2  -s 'time_bounds=time_bounds-25550' -s 'time=time-25550' "+ ens_001_file + " " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)

            nco_command = "ncatted -O -a bounds,time,m,c,'time_bounds'  " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)

            ; fix longname for time_bounds scratch -> scratch

            nco_command = "ncatted -O -a long_name,time_bounds,m,c,'history time interval endpoints'  " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)





         else

            nco_command = "ncap2  -s 'time_bnds=time_bnds-25550' -s 'time=time-25550' "+ ens_001_file + " " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)

            nco_command = "ncatted -O -a bounds,time,m,c,'time_bnds'  " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)

            ; fix longname for time_bounds scratch -> scratch

            nco_command = "ncatted -O -a long_name,time_bnds,m,c,'history time interval endpoints'  " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)




         end if


         ; wipe out ens_001_file
         print("RM: rm -v "+ ens_001_file)
         system("rm -v "+ ens_001_file)

         ; fix long name for time scratch -> scratch

         nco_command = "ncatted -O -a long_name,time,m,c,'time'  " + scratchfile
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; fix units for time scratch -> scratch

         nco_command = "ncatted -O -a units,time,m,c,'days since 1920-01-01 00:00:00'  " + scratchfile
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; fix calendar for time scratch -> scratch

         nco_command = "ncatted -O -a calendar,time,m,c,'noleap'  " + scratchfile
         print( " " + nco_command)
         system(" nohup " + nco_command)


         ; add coordinate attribute


         if (parameters(vf) .eq. "SOILLIQ") then
            nco_command = "ncatted -O -a coordinate,"+parameters(vf)+",m,c,'time levgrnd latitude longitude'  " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)
         else
            nco_command = "ncatted -O -a coordinate,"+parameters(vf)+",m,c,'time latitude longitude'  " + scratchfile
            print( " " + nco_command)
            system(" nohup " + nco_command)
         end if

         ; fix timebound coordinate for time scratch -> scratch
         ; clip the time series for ensemble 1 to start at 1920 scratch->ens_001_file

         nco_command = "ncea  -d time,00.,"+time_of_last_month+".  " + scratchfile +  " " + ens_001_file
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; remove series scratchfile

         print( "RM: rm -frv " + scratchfile)
         system(   "rm -frv " + scratchfile)

         ; concatenate by all ensemble member into a single file ens_0xx_files->complete_ensemble

         nco_command = "ncecat "+ ens_0xx_files + " " + ens_all_file
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; add longname attribute to the time attribute complete_ensemble->complete_ensemble

         nco_command = "ncatted -O -a long_name,time,m,c,'time' " + ens_all_file
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; change the name of the record dimension from 'record' to 'ensemble' complete_ensemble->complete_ensemble

         nco_command = "ncrename -O -d record,ensemble " + ens_all_file
         print( " " + nco_command)
         system(" nohup " + nco_command)

         ; swap the ensemble and time dimensions complete_ensemble file -> scratch

         nco_command = "ncpdq  -a time,ensemble " + ens_all_file + "  " + scratchfile
         print( " " + nco_command)
         system("nohup " + nco_command)

         ; clean scratch files

         print( "RM: rm -v " + ens_0xx_files)
         system(    "rm -v " + ens_0xx_files)

         ; replace scratch->complete_ensemble

         print( "MV: mv -v " + scratchfile + " " + ens_all_file)
         system(    "mv -v " + scratchfile + " " + ens_all_file)

         ; nccopy classic netcdf v3 to netcdf v4

         netcdf_command = " nccopy -u -k 3 -d 5 " + ens_all_file + " " + ens_all_file+"4"
         print( " " + netcdf_command)
         system(" nohup " + netcdf_command)

         print( "RM: rm -v " + ens_all_file)
         system(    "rm -v " + ens_all_file)


      ;; done!
      print( " ncdump -h " + ens_all_file+"4")
      system(" nohup ncdump -h " + ens_all_file+"4")

   end do
   delete([/ part1,part2,part3,part5, ensemble_member /])

end do

end
