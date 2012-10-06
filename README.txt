AUTHOR: Jan Winter, TU Berlin, FG Lichttechnik,
	j.winter@tu-berlin.de, www.li.tu-berlin.de
LICENSE: free to use at your own risk. Kudos appreciated.

This is a framework for MATLAB to communicate with an Optronics OL-490 spectral synthesizer. 
It also provides methods to create a calibration file and a generator
for creating target spectra and intensity sweeps. This requires classes from the
KonicaMinolta CS-2000 framework, also provided through our gitHub repositories.

You need the driver for the OL-490 and these files from the Optronics website:
'OLIPluginLibrary.dll'
'OL490LIB.dll'
'OL490_SDK_Dll.dll'
'CyUSB.dll'

OL490Controller.m: Class for controlling the OL490

%init controller:
olIndex = 0; 		%index of first OL-490 connected to computer
olCalibrationFile = 1; 	%0=150nm, 1=350nm, 2=500nm, 3=750nm 
filePathToOptronicsFiles = 'C:\Programme\GoochandHousego\OL 490 SDK\';
ol490Controller = OL490Controller( olIndex, olCalibrationFile );
ol490Controller.init( filePathToOptronicsFiles );

%send some data:
OL490_MAX_VALUE = 49152;
ol490Controller.sendOLSpectrum( ones( 1024, 1 ) * OL490_MAX_VALUE );
ol490Controller.sendOLSpectrum.openShutter();

ol490CreateCalibration.m 
call this file to create a calibration file and an adjusted spectrum

ol490CreateAdjustedSpectrum.m
call this file to create an adjusted spectrum file based on a certain calibration

OL490Calibration.m: Class for creating a calibration file
requires an CS-2000 + our CS-2000 repository

OL490SpectrumGenerator.m: Class for generating an adjusted spectrum based on calibration file

OL490SweepGenerator.m: Class for generating a sweep
