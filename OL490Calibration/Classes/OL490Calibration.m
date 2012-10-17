% AUTHOR:	Jan Winter, Marian Leifert, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



classdef OL490Calibration < handle

    properties
        ol490Controller                 % controller for ol490
        numberOfMeasurementIterations   % number of repetitions per light level
        ol490CalibrationDataset         % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
        ol490Index                      % index of ol490 0, 1...
        calibrationSpectrumCellArray    % cell array with calibration spectrum 0%-100%
        calibrationSpectrumDimLevelArray   % array with actual dim levels
        timeToWaitBeforeMeasurementInS  % time to leave the lab
        cs2000MeasurementCellArray      % created by startcalibration measurements
        cs2000NDFilter                  % 0, 10, 100 ND Filter %0 => 0, 10 => 1, 100 => 2
        %sendProgressToURL               % if 1, update RSS feed is called via URL
        numberOfDimLevels               % 11, 21, 41, 101
        fileNameOfCalibrationData       % specific file name with date tag
        calibrationDate                 % date of calibration
        calibrationType                 % background or target
        
        %calibration data
        %calculated on demand
        calibrationDataPrepared         % indicates whether the data has been prepared (interpolated)
        inputOutputCalibrationMatrix    % actual required dimLevels
        interpolatedSpectralDataCalibrationMatrix % relative spectral dimLevel data
        maxValueOfAllSpectra            % used as reference for interpolatedSpectralDataCalibrationMatrix
    end
    methods
        %% constructor
        function obj = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, timeToWaitBeforeMeasurementInS, numberOfDimLevels, calibrationType )
            obj.ol490CalibrationDataset = ol490CalibrationDataset;
            obj.timeToWaitBeforeMeasurementInS = timeToWaitBeforeMeasurementInS;
            obj.ol490Index = ol490Index;
            obj.cs2000NDFilter = cs2000NDFilter;
            obj.numberOfMeasurementIterations = 1;
            %obj.sendProgressToURL = sendProgressToURL;
            obj.numberOfDimLevels = numberOfDimLevels;
            obj.calibrationType = calibrationType;
            obj.calibrationDataPrepared = 0;
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
            %CS2000_terminateConnection();
            obj.ol490Controller = 0;
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
        
        %% measureDataForCalibration
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
                obj.ol490Controller.sendOLSpectrum( currentSpectrum.spectrum );
                
                %just be sure that the OL490 is ready
                pause( 1 );
                
                % measure spectrum via CS2000
                disp( 'measuring' );
                [message1, message2, cs2000Measurement, colorimetricNames] = CS2000_measure();
                
                disp( sprintf( 'measured: %3.3f cd/m^2', cs2000Measurement.colorimetricData.Lv ) );
                
                %% TODO: repeat this step for numberOfMeasurementIterations
                %% and calc mean
                cs2000MeasurementCellArray{ currentSpectrumIndex } = cs2000Measurement;
                
                obj.beepHigh();
            end
            
            obj.beepLow();
            obj.beepHigh();
            
            obj.cs2000MeasurementCellArray = cs2000MeasurementCellArray;
            toc();
            
            %clean up
            obj.terminate();
            
            %auto evaluate data
            obj.evaluateDataForCalibration();
            
            %             catch exceptObj
            %                 disp( sprintf( 'error caught %s', exceptObj.message ) );
            %                 exceptObj
            %                 exceptObj.stack
            %             end
            
            %obj.indicateFinish();
            
        end
        
        %% evaluate Data for calibration
        function obj = evaluateDataForCalibration( obj )
            
            cs2000MeasurementCellArray = obj.cs2000MeasurementCellArray;
            %we want to save the dimLevels as well
            calibrationSpectrumCellArray = obj.calibrationSpectrumCellArray;
            
            %prepare save
            currentTimeString = datestr( now, 'dd-mmm-yyyy_HH_MM_SS' );
            obj.calibrationDate = currentTimeString;
            
            if( strcmp( obj.calibrationType, 'background' ) )
                ol490CalibrationBackground = obj;
                calibrationVariableName = 'ol490CalibrationBackground';
            elseif ( strcmp( obj.calibrationType, 'target' ) )
                ol490CalibrationTarget = obj;
                calibrationVariableName = 'ol490CalibrationTarget';
            end
            
            %save variables to unique mat file
            fileName = sprintf( 'calibrationData_%s_%s.mat', obj.calibrationType, currentTimeString );
            obj.fileNameOfCalibrationData = fileName;
            save( fileName, calibrationVariableName );
            %save( fileName, 'inputOutputMatrix', 'interpolatedSpectralDataMatrix', 'cs2000MeasurementCellArray', 'interpolatedMaxValuesForDimLevelSpectra' );
            %save( fileName, 'cs2000MeasurementCellArray',
            %'calibrationSpectrumCellArray' );
            
            %save variable to mat file which will be overwritten every time
            fileName = sprintf( 'calibrationData_%s.mat', obj.calibrationType );
            save( fileName, calibrationVariableName );
            %save( fileName, 'inputOutputMatrix', 'interpolatedSpectralDataMatrix', 'cs2000MeasurementCellArray', 'interpolatedMaxValuesForDimLevelSpectra' );
            %save( fileName, 'cs2000MeasurementCellArray', 'calibrationSpectrumCellArray' );
            
            disp('DONE: calibration')
            toc();
        end
        
        %         %% indicateFinish
        %         function obj = indicateFinish( obj )
        %
        %             %don't do this if not requested
        %             if ( ~obj.sendProgressToURL )
        %                 return
        %             end
        %
        %             %% TODO: we need a server with portforwarding
        %             try
        %                 s = urlread( 'http://130.149.60.46:13370' );
        %             catch exceptObj
        %                 disp( sprintf( 'error caught %s', exceptObj.message ) );
        %                 exceptObj
        %                 exceptObj.stack
        %             end
        %         end
        
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
                
                % we make 5 more precise measurements from 0 : 0.1
             %   numberOfPreciseDimLevels = 0;%10;%0;
            %    toValueOfPreciseMeasurements = 0;%0.1;%0;
             %   numberOfDimLevels = obj.numberOfDimLevels - numberOfPreciseDimLevels;
             %   dimStepIncrease = (1 - toValueOfPreciseMeasurements) / ( numberOfDimLevels - 1 );
             %   dimStepIncreasePrecise = toValueOfPreciseMeasurements / ( numberOfPreciseDimLevels - 1 );
                
                % 1 percent steps from 0 to 20
                dimLevelArrayLow = 0.0 : 0.01 : 0.2;
                % 5 percent steps from 20 to 100
                dimLevelArrayHigh = 0.25 : 0.05 : 1.0;
                dimLevelArray = [ dimLevelArrayLow, dimLevelArrayHigh ];
                numberOfDimLevels = length ( dimLevelArray );
                
                calibrationSpectrumCellArray = cell( numberOfDimLevels, 1 );
                obj.calibrationSpectrumDimLevelArray = zeros( numberOfDimLevels, 1 );
                
                OL490_MAX_VALUE = 49152;
                
                currentDimValue = 0;    %will increase by dimStepIncrease each step
                for currentSpectrumIndex = 1 : numberOfDimLevels %+ numberOfPreciseDimLevels
                currentDimValue = dimLevelArray( currentSpectrumIndex );
                    currentSpectrum = ones( 1024, 1 ) * OL490_MAX_VALUE * currentDimValue;
                    calibrationSpectrum = OL490CalibrationSpectrum( currentSpectrum, currentDimValue );
                    calibrationSpectrumCellArray{ currentSpectrumIndex } = calibrationSpectrum;
                    obj.calibrationSpectrumDimLevelArray( currentSpectrumIndex ) = currentDimValue;
                    %incearse dimValue for next iteration
                   % if( currentSpectrumIndex < numberOfPreciseDimLevels )
                   %     currentDimValue = currentDimValue + dimStepIncreasePrecise;
                  %  else
                  %      currentDimValue = currentDimValue + dimStepIncrease;
                  %  end
                    
                end
                
                obj.calibrationSpectrumCellArray = calibrationSpectrumCellArray;
                
            end
            value = obj.calibrationSpectrumCellArray;
        end
        
        
        %% prepareCalibrationData
        function prepareCalibrationData( obj )
            %filePath, calibrationSpectrumCellArray
            %load measurements
            %load( filePath );
            disp( 'interpolating calibration data' );
            
            %prepare data for function
            numberOfMeasurements = obj.numberOfDimLevels;% length( cs2000MeasurementCellArray );
            numberOfSpectralLines = length( obj.cs2000MeasurementCellArray{ 1 }.spectralData );
            
            % get original dimLevels
            dimLevelResolutionOriginal = obj.calibrationSpectrumDimLevelArray;%zeros( size( calibrationSpectrumCellArray ) );
%             for currentDimLevelIndex = 1 : numberOfMeasurements
%                 dimLevelResolutionOriginal( currentDimLevelIndex ) = calibrationSpectrumCellArray{ currentDimLevelIndex }.dimLevel;
%             end
            
            %scale values relatively
            spectral_data_dimLevels = zeros( numberOfMeasurements, numberOfSpectralLines );
            %spectral_data_dimLevelsRelative = zeros( numberOfMeasurements, numberOfSpectralLines );
            %maxValuesOfDimLevelSpectrum = zeros( numberOfMeasurements, 1 );
            
            for currentSpectrumIndex = 1 : numberOfMeasurements
                currentSpectrum = obj.cs2000MeasurementCellArray{ currentSpectrumIndex }.spectralData;
                spectral_data_dimLevels( currentSpectrumIndex, : ) = currentSpectrum;
            end
            
            obj.maxValueOfAllSpectra = max( max( spectral_data_dimLevels ) );
            spectral_data_dimLevelsRelative = spectral_data_dimLevels ./ obj.maxValueOfAllSpectra;
            
            figure();
            mesh( spectral_data_dimLevelsRelative );
            fileName = sprintf( 'spectral_data_dimLevelsRelative_%s_%s', obj.calibrationDate, obj.calibrationType );
            saveas( gcf, fileName, 'fig' );
            saveas( gcf, fileName, 'epsc' );
            close( gcf() );
            
            %generate interpolated reference data
            dimLevelResolutionInterpolated   = 0 : 0.1 : 100;
            interpolatedDimLevelSpectralData  = OL490Calibration.interpolateDimLevels( spectral_data_dimLevelsRelative, dimLevelResolutionOriginal, dimLevelResolutionInterpolated );
            interpolatedSpectralLinesSpectralData = OL490Calibration.interpolateSpectrum( interpolatedDimLevelSpectralData );
            interpolatedSpectralDataMatrix = interpolatedSpectralLinesSpectralData;
            inputOutputMatrix  = OL490Calibration.generateInputOutputFunction( interpolatedSpectralDataMatrix );
            disp('');
            
            %save data
            obj.calibrationDataPrepared = 1;
            obj.inputOutputCalibrationMatrix = inputOutputMatrix;
            obj.interpolatedSpectralDataCalibrationMatrix = interpolatedSpectralDataMatrix;
            %obj.maxValueOfAllSpectra = maxValueOfAllSpectra;
        end
    end
    %% ------------------------------------
    methods(Static)
        %% interpolateSpectrum
        function [ interpolatedData ] = interpolateSpectrum( spectralData )
            %cubic spline interpolation over 1024 steps
            currentNumberOfSpectralLines = size( spectralData, 2 );
            currentResolution = linspace( 0, currentNumberOfSpectralLines - 1,  currentNumberOfSpectralLines );
            interpolatedResolution = linspace( 0, currentNumberOfSpectralLines - 1, 1024 );
            
            numberOfDimLevels = size( spectralData, 1 );
            interpolatedData = zeros( numberOfDimLevels, length( interpolatedResolution ) );
            for dimlevelIndex = 1 : numberOfDimLevels
                currentDimLevelSpectralData = spectralData( dimlevelIndex, : );
                interpolatedData( dimlevelIndex, : ) = spline( currentResolution, currentDimLevelSpectralData, interpolatedResolution );
            end
        end
        
        %% interpolateDimLevels
        function [ interpolatedData ] = interpolateDimLevels( spectralData, dimLevelResolutionOriginal, dimLevelResolutionInterpolated )
            %cubic spline interpolation for dimLevels
            dimLevelResolutionOriginal = dimLevelResolutionOriginal * 100;
            
            if ( min( dimLevelResolutionOriginal ) < 0 )
                error( 'wrong input for dimlevel interpolation!' )
            end
            if ( max( dimLevelResolutionOriginal ) > 100 )
                % error( 'wrong input for dimlevel interpolation!' )
            end
            
            numberOfSpectralLines = size( spectralData, 2 );
            interpolatedData = zeros( length( dimLevelResolutionInterpolated ), numberOfSpectralLines );
            for spectralLineIndex = 1 : numberOfSpectralLines
                currentSpectralLineSpectralData = spectralData( :, spectralLineIndex );
                interpolatedData( :, spectralLineIndex ) = spline( dimLevelResolutionOriginal , currentSpectralLineSpectralData, dimLevelResolutionInterpolated );
            end
        end
        
        %% generateInputOutputFunction
        function [ inputOutputMatrix ] = generateInputOutputFunction( data )
            % generates an input-output-function for the spectral data
            
            inputOutputMatrix = zeros( size( data ) );
            numberOfSpectralLines = size( data, 2 );
            for spectralLineIndex = 1 : numberOfSpectralLines
                inputOutputMatrix( :, spectralLineIndex ) = data( :, spectralLineIndex) ./ data (1001, spectralLineIndex );
            end
        end
        
        
    end
end