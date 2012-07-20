%OL490
cur = what;
path = cur.path;
OLIPluginLibrary = NET.addAssembly([path '\dll\OLIPluginLibrary.dll']);
OL490LIB = NET.addAssembly([path '\dll\OL490LIB.dll']);
OL490_SDK_Dll = NET.addAssembly([path '\dll\OL490_SDK_Dll.dll']);
CyUSB = NET.addAssembly([path '\dll\CyUSB.dll']);
ol_obj = OL490_SDK_Dll.OL490SdkLibrary();
ol_obj.ConnectToOL490(0)
ol_obj.CloseShutter;
ol_obj.OpenShutter
ol_obj.LoadAndUseStoredCalibration(3); %750um-Spalt


ol_obj.GetOL490SerialNumber()
ol_obj.GetFirmwareVersion()
ol_obj.GetFlashVersion()
ol_obj.GetFPGAVersion()
ol_obj.GetNumberOfStoredCalibrations()


for i=1:11
    spec_string = sprintf('spektrum_%d.csv',i);
    spec = xlsread([path '\spektren\' spec_string]);
    spec_list(:,i) = spec(:,3);
end

spec=xlsread('spektrum_1.csv')
speclist=spec(:,3)

ol_obj.OpenShutter()
ol_obj.TurnOnColumns( int64( speclist ) )

eErrorCodes SetGrayScaleValue(long value)
Sets the gray scale value for the DMD rendering.  Monochrome achieves the fastest rate.  Note that the higher the number the lower the max frame rate speed. 
Value range 0 – Monochrome (1bit)
         1 – (2 bit resolution)
         2 – (3 bit resolution)
         3 – (4 bit resolution)
         4 – (5 bit resolution)
         5 – (6 bit resolution)

Returns : OL490NotConnectedError	- OL490 not connected
	 ParameterExceedLimitError	- Gray scale value is between 0 and 5 inclusive
	 SequenceRunningError		- There is a sequence already loop
	 Success				- Standard success return

There are two methods to download renderings to the OL490.  One method is to send them ‘live’ to the unit without using the RAM built into the OL490.  This limits the max speed of the renderings, but keeps you from having to deal with the need to work with the start, stop, and pause triggering options.  The other method is to download the renderings to the RAM.  Once the data is in RAM, you have complete control to repeat the sequence that is downloaded over and over and over again.


%generate reference data
res_spline = 0 : 0.1 : 100;
percent_vector = 0 : 5 : 100;
    [ first_spline ] = percent_spline( spectral_data, percent_vector, res_spline);
    [ final_spline ] = nm_spline( first_spline );
    [ io_real ] = io_real_gen( final_spline );
    [ max_percent_adaption ] = spectral_percent( final_spline );
   
    
    checkbox = get(handles.save_file_check,'Value');
    if checkbox == 1
        %save data
        cd (output_path)
        %outputfile = [io_real;max_percent_adaption];
        %dlmwrite('OL490_reference_data.csv',outputfile,'delimiter',';');
        csvwrite('ol490_io_real.csv',io_real);
        csvwrite('ol490_max_percent_adaption.csv',max_percent_adaption);
    end    