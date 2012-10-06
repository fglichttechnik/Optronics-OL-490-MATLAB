% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



function [ calibrationFileName ] = ol490CreateCalibration( ...
    ol490CalibrationDataset, ol490Index, timeToWaitBeforeMeasurementInS,...
    cs2000NDFilter, numberOfDimLevels, ol490Type )
%function [ calibrationFileName ] = ol490CreateCalibration( ...
    ol490CalibrationDataset, ol490Index, timeToWaitBeforeMeasurementInS,...
    cs2000NDFilter, numberOfDimLevels, ol490Type )
% creates an OL490 calibration file
% most probably deprecated


%we measure only once
 numberOfMeasurementIterations = 1;      % number of repetitions per light level

%% -----------------------
%% nothing to be done below
OL490CalibrationInstance = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, numberOfMeasurementIterations, timeToWaitBeforeMeasurementInS, numberOfDimLevels, ol490Type );
OL490CalibrationInstance.measureDataForCalibration();
OL490CalibrationInstance.terminate();
calibrationFileName = OL490CalibrationInstance.fileNameOfCalibrationData;
disp( sprintf( 'saved calibration file to %s', calibrationFileName ) );

end


