clear all;
%Input-Data 
%(for 11,21,41 or 101 data sections)
[file, path]        = uigetfile('*.*','select reference data');
data                = xlsread( [path file] );
data(:,1)           = [];
dataPercent         = data ./ max( max( data ));
PercentResolution   = 0 : 0.1 : 100;
save                = 0;
[file, path]        = uigetfile('*.*','select user data');
userSpectrum        = xlsread( [path file] ) ;
%dimValues           = [0.9 , 0.8 ]; 

%calibration preparation
disp('calibration file start');
firstSpline  = percentSpline( dataPercent, PercentResolution );
secondSpline = nmSpline( firstSpline );
ioReal       = ioRealGeneration( secondSpline);
if save == 1;
    xlswrite( 'ioReal_SpecGen.csv', ioReal );
    xlswrite( 'splinedData_SpecGen.csv', secondSpline );
end
disp('calibration file done');


%spectrum adaption
disp('adaption start');
for fileCounter = 1 : size( userSpectrum, 2)
    realValues( :, fileCounter ) = spectrumAdaption( userSpectrum( :, fileCounter ),secondSpline, ioReal );  
end
file = ['spectrum_' date '.csv'];
xlswrite(file,realValues);  
disp('adaption done');

