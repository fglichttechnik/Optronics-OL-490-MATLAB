function [ calibrationFileName ] = ol490CreateCalibration( ...
    ol490CalibrationDataset, ol490Index, timeToWaitBeforeMeasurementInS,...
    cs2000NDFilter, numberOfDimLevels )

%we measure only once
 numberOfMeasurementIterations = 1;      % number of repetitions per light level

%% -----------------------
%% nothing to be done below
OL490CalibrationInstance = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, numberOfMeasurementIterations, timeToWaitBeforeMeasurementInS, numberOfDimLevels );
OL490CalibrationInstance.measureDataForCalibration();
OL490CalibrationInstance.terminate();
calibrationFileName = OL490CalibrationInstance.fileNameOfCalibrationData;
disp( sprintf( 'saved calibration file to %s', calibrationFileName ) );

end


