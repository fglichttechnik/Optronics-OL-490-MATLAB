clear all;

%% set your parameters here
targetSpectrum = ones( 401, 1 );  % 401 spectral values, e.g. from cs2000 measurement
dimlevels = 1;  % in range 0 : 1, array or skalar
filePathToCalibrationData = 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\OL490-Calibration\calibrationData.mat';
savePathFileName = 'C:\Dokumente und Einstellungen\jaw\Desktop\Development\OL490-Calibration\spectralData.mat'

%% nothing to be done below

%% TODO this is not proper implemented, yet
ol490SpectrumGeneratorInstance = OL490SpectrumGenerator( targetSpectrum, dimLevels, filePathToCalibrationData );
ol490SpectrumGeneratorInstance.createAdjustedSpectra();
save( savePathFileName, 'ol490SpectrumGeneratorInstance' );

