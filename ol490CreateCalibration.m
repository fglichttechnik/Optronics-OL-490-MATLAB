function [ calibrationFileName ] = ol490CreateCalibration( ...
    ol490CalibrationDataset, ol490Index, timeToWaitBeforeMeasurementInS,...
    cs2000NDFilter, numberOfDimLevels )


% %% set your parameters here
 numberOfMeasurementIterations = 1;      % number of repetitions per light level
% ol490CalibrationDataset = 1;            % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
% ol490Index = 0;                         % index of ol490 0, 1...
% timeToWaitBeforeMeasurementInS = 45;    % time to leave the lab
% cs2000NDFilter = 2;                     % 0, 10, 100 ND Filter %0 => 0, 10 => 1, 100 => 2
 sendProgressToURL = 0;                  % if 1 a certain URL is called to update RSS feed
% numberOfDimLevels = 11;                 % 11, 21, 41, 101 effects accuracy of calibration

%% set your parameters here
if nargin == 0
    
    numberOfMeasurementIterations = 1;      % number of repetitions per light level
    ol490CalibrationDataset = 3;            % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
    ol490Index = 0;                         % index of ol490 0, 1...
    timeToWaitBeforeMeasurementInS = 10;    % time to leave the lab
    cs2000NDFilter = 2;                     % 0, 10, 100 ND Filter %0 => 0, 10 => 1, 100 => 2
    sendProgressToURL = 0;                  % if 1 a certain URL is called to update RSS feed
    
end 
%% nothing to be done below
OL490CalibrationInstance = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, numberOfMeasurementIterations, timeToWaitBeforeMeasurementInS, numberOfDimLevels, sendProgressToURL );
OL490CalibrationInstance.measureDataForCalibration();
OL490CalibrationInstance.terminate();
calibrationFileName = OL490CalibrationInstance.fileNameOfCalibrationData;
disp( sprintf( 'saved calibration file to %s', calibrationFileName ) );

end


