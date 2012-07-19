%% set your parameters here
numberOfMeasurementIterations = 1;   % number of repetitions per light level
ol490CalibrationDataset = 1;         % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
ol490Index = 0;                     % index of ol490 0, 1...
timeToWaitBeforeMeasurementInS = 2;  % time to leave the lab
cs2000NDFilter = 0;                  % 0, 10, 100 ND Filter %0 => 0, 10 => 1, 100 => 2

%% nothing to be done below
OL490CalibrationInstance = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, numberOfMeasurementIterations, timeToWaitBeforeMeasurementInS );
OL490CalibrationInstance.measureDataForCalibration();