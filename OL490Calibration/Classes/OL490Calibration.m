%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490Calibration < handle
    %% properties
    properties
        ol490Controller                 % controller for ol490
        numberOfMeasurementIterations   % number of repetitions per light level
        ol490CalibrationDataset         % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
        ol490Index                      % index of ol490 0, 1...
        calibrationSpectrumCellArray    % cell array with calibration spectrum 0%-100% in 5% steps
        timeToWaitBeforeMeasurementInS  % time to leave the lab
        cs2000MeasurementCellArray      % created by startcalibration measurements
        cs2000NDFilter                  % 0, 10, 100 ND Filter %0 => 0, 10 => 1, 100 => 2
        sendProgressToURL               % if 1, update RSS feed is called via URL
        numberOfDimLevels               % 11, 21, 41, 101
        fileNameOfCalibrationData       % specific file name with date tag
    end
    methods
        %% constructor
        function obj = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, numberOfMeasurementIterations, timeToWaitBeforeMeasurementInS, numberOfDimLevels, sendProgressToURL )
            obj.ol490CalibrationDataset = ol490CalibrationDataset;
            obj.timeToWaitBeforeMeasurementInS = timeToWaitBeforeMeasurementInS;
            obj.ol490Index = ol490Index;
            obj.cs2000NDFilter = cs2000NDFilter;
            obj.numberOfMeasurementIterations = numberOfMeasurementIterations;
            obj.sendProgressToURL = sendProgressToURL;
            obj.numberOfDimLevels = numberOfDimLevels;
            obj.init( );
            tic();
        end
        
        %% init devices
        function [ obj ] = init( obj )
            obj.initCS2000();
            obj.initOL490();
        end
        
        %% disconnect devices
        function obj = terminate( obj )
            CS2000_terminateConnection();
            %obj.initOL490(); %% TODO:implement disconnect
        end
        
        %% init CS2000
        function obj = initCS2000( obj  )
            disp('initializing CS2000')
            CS2000_initConnection();
            CS2000_setNDFilter( obj.cs2000NDFilter );
            disp('DONE: initializing CS2000')
        end
        
        %% init OL490
        function obj = initOL490( obj )
            disp('initializing OL 490')
            
            ol490Controller = OL490Controller( obj.ol490Index, obj.ol490CalibrationDataset );
            ol490Controller.init();
            obj.ol490Controller = ol490Controller;
            
            disp('DONE: initializing OL 490')
        end
        
        %% pause
        function obj = waitToBegin( obj )
            
            timeToWaitInS = floor( obj.timeToWaitBeforeMeasurementInS );
            if ( timeToWaitInS  < 1)
                disp( 'I m not waiting' );
            else
                for seconds = 1 : timeToWaitInS
                    disp( sprintf( 'time to wait: %d', ( timeToWaitInS - seconds ) ) );
                    pause( 1 );
                end
            end
        end
        
        %% measure calibration data
        function obj = measureDataForCalibration( obj )
            
            %try
                %wait for personnel to leave the lab
                obj.waitToBegin();
                
                disp('starting calibration')
                
                obj.ol490Controller.openShutter();
                
                calibrationSpectrumCellArray = obj.calibrationSpectrumCellArray;
                cs2000MeasurementCellArray = cell( length( calibrationSpectrumCellArray ), 1 );
                
                % we ignore the 0% measurement and fake a result:
                cs2000ColorimetricDataClass = CS2000ColorimetricData();
                classProperties = properties( cs2000ColorimetricDataClass );
                cs2000ColorimetricData = cell( length( classProperties ) );
                cs2000ColorimetricData{ 2 } = 1;
                %cs2000ColorimetricData.Lv = 0;
                cs2000MeasurementCellArray{ 1 } = CS2000Measurement( clock() , zeros( 401, 1 ) , cs2000ColorimetricData );
                
                % make the real measurements for all other dim levels
                for currentSpectrumIndex = 2 : length( calibrationSpectrumCellArray );
                    disp( sprintf( 'sending spectrum %d', currentSpectrumIndex ) );
                    
                    % recall spectrum in OL490
                    currentSpectrum = calibrationSpectrumCellArray{ currentSpectrumIndex }
                    obj.ol490Controller.sendSpectrum( currentSpectrum.spectrum );
                    
                    %just be sure that the OL490 is ready
                    pause( 1 );
                    
                    % measure spectrum via CS2000
                    disp( 'measuring' );
                    [message1, message2, cs2000Measurement, colorimetricNames] = CS2000_measure();
                    
                    %% TODO: repeat this step for numberOfMeasurementIterations
                    %% and calc mean
                    cs2000MeasurementCellArray{ currentSpectrumIndex } = cs2000Measurement;
                    
                    obj.beepHigh();
                end
                
                obj.beepLow();
                obj.beepHigh();
                
                obj.cs2000MeasurementCellArray = cs2000MeasurementCellArray;
                toc();
                
                %auto evaluate data
                obj.evaluateDataForCalibration();
                
%             catch exceptObj
%                 disp( sprintf( 'error caught %s', exceptObj.message ) );
%                 exceptObj
%                 exceptObj.stack
%             end
            
            obj.indicateFinish();
            
        end
        
        %% evaluate Data for calibration
        function obj = evaluateDataForCalibration( obj )
            
            measurementCellArray = obj.cs2000MeasurementCellArray;
            
            %prepare data for function
            numberOfMeasurements = length( measurementCellArray );
            numberOfSpectralLines = length( measurementCellArray{ 1 }.spectralData );
            
            spectral_data = zeros( numberOfMeasurements, numberOfSpectralLines );
            maxValues = zeros( numberOfMeasurements, 1 );
            for currentSpectrumIndex = 1 : numberOfMeasurements
                currentSpectrum = measurementCellArray{ currentSpectrumIndex }.spectralData;
                maxValue = max( currentSpectrum );
                maxValues( currentSpectrumIndex ) = maxValue;
                currentSpectrumPercent = currentSpectrum ./ maxValue;
                spectral_data( currentSpectrumIndex, : ) = currentSpectrumPercent;
            end
            
            currentTimeString = datestr( now, 'dd-mmm-yyyy_HH_MM_SS' );
            %fileName = sprintf( 'calibrationRawData_%s.mat', currentTimeString );
            %save( fileName, 'cs2000MeasurementCellArray' )
            
            %% Hack: we currently do only one calibration
            dataPercent = spectral_data( 1 );
            
            %generate reference data
            numberOfDimLevels = obj.numberOfDimLevels;
            dimStepIncrease = 100 / ( numberOfDimLevels - 1 );
            
            res_spline = 0 : 0.1 : 100;
            percent_vector = 0 : dimStepIncrease : 100;            
            firstSpline  = percentSpline( dataPercent, percent_vector );
            secondSpline = nmSpline( firstSpline );
            ioReal       = ioRealGeneration( secondSpline);
            
            %save variable to mat file which will be overwritten every time
            fileName = sprintf( 'calibrationData.mat' );
            save( fileName, 'io_real', 'secondSpline', 'cs2000MeasurementCellArray', 'maxValues' );
            
            %save variables to unique mat file
            fileName = sprintf( 'calibrationData_%s.mat', currentTimeString );
            obj.fileNameOfCalibrationData = fileName;
            save( fileName, 'io_real', 'secondSpline', 'cs2000MeasurementCellArray', 'maxValues' );
            
            disp('DONE: calibration')
            toc();
        end
        
        %% send urlRequest on finish
        function obj = indicateFinish( obj )
            
            %don't do this if not requested
            if ( ~obj.sendProgressToURL )
                return
            end
            
            %% TODO: we need a server with portforwarding
            try
                s = urlread( 'http://130.149.60.46:13370' );
            catch exceptObj
                disp( sprintf( 'error caught %s', exceptObj.message ) );
                exceptObj
                exceptObj.stack
            end
        end
        
        %% beep sound
        function obj = beepHigh( obj )
            %%indicate when finished
            Fs = 44100;
            f = 500;
            lenSeconds = .5;
            beepSound = sin(2 * pi * f * linspace(0,lenSeconds ,Fs * lenSeconds));
            sound(beepSound,Fs);
        end
        function obj = beepLow( obj )
            %%indicate when finished
            Fs = 44100;
            f = 250;
            lenSeconds = .5;
            beepSound = sin(2 * pi * f * linspace(0,lenSeconds ,Fs * lenSeconds));
            sound(beepSound,Fs);
        end
        
        %% calibration spectrum
        function value = get.calibrationSpectrumCellArray( obj )
            if ( isempty( obj.calibrationSpectrumCellArray ) )
                
                numberOfDimLevels = obj.numberOfDimLevels;
                dimStepIncrease = 1 / ( numberOfDimLevels - 1 );
                
                calibrationSpectrumCellArray = cell( numberOfDimLevels, 1 );
                OL490_MAX_VALUE = 49152;
                
                currentDimValue = 0;    %will increase by dimStepIncrease each step
                for currentSpectrumIndex = 1 : numberOfDimLevels
                    currentSpectrum = ones( 1024, 1 ) * OL490_MAX_VALUE * currentDimValue;
                    calibrationSpectrum = OL490CalibrationSpectrum( currentSpectrum, currentDimValue );
                    calibrationSpectrumCellArray{ currentSpectrumIndex } = calibrationSpectrum;
                    
                    %incearse dimValue for next iteration
                    currentDimValue = currentDimValue + dimStepIncrease;
                end
                
                obj.calibrationSpectrumCellArray = calibrationSpectrumCellArray;
                
            end
            value = obj.calibrationSpectrumCellArray;
        end
        
    end
end