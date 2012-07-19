%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490Calibration < handle
    %% properties
    properties
        ol_obj                          % handle to OL490
        numberOfMeasurementIterations   % number of repetitions per light level
        ol490CalibrationDataset         % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
        ol490Index                      % index of ol490 0, 1...
        calibrationSpectrumCellArray    % cell array with calibration spectrum 0%-100% in 5% steps
        timeToWaitBeforeMeasurementInS  % time to leave the lab
        cs2000MeasurementCellArray      % created by startcalibration measurements
        cs2000NDFilter                  % 0, 10, 100 ND Filter %0 => 0, 10 => 1, 100 => 2
    end
    methods
        %% constructor
        function obj = OL490Calibration( ol490CalibrationDataset, ol490Index, cs2000NDFilter, numberOfMeasurementIterations, timeToWaitBeforeMeasurementInS )
            obj.ol490CalibrationDataset = ol490CalibrationDataset;
            obj.timeToWaitBeforeMeasurementInS = timeToWaitBeforeMeasurementInS;
            obj.ol490Index = ol490Index;
            obj.cs2000NDFilter = cs2000NDFilter;
            obj.numberOfMeasurementIterations = numberOfMeasurementIterations;
            obj.init( );
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
            
            path = 'C:\Programme\GoochandHousego\OL 490 SDK\';
            NET.addAssembly([path 'OLIPluginLibrary.dll']);
            NET.addAssembly([path 'OL490LIB.dll']);
            NET.addAssembly([path 'OL490_SDK_Dll.dll']);
            NET.addAssembly([path 'CyUSB.dll']);
            
            ol_obj = OL490_SDK_Dll.OL490SdkLibrary()
            ol_obj.ConnectToOL490( obj.ol490Index )
            result = ol_obj.CloseShutter()
            disp( sprintf( 'result of operation: %s', char( result ) ) );
            ol_obj.LoadAndUseStoredCalibration( obj.ol490CalibrationDataset );
            
            OL490SerialNumber = ol_obj.GetOL490SerialNumber();
            disp( sprintf( 'OL490SerialNumber: %s', char( OL490SerialNumber ) ) );
            OL490FirmwareVersion = ol_obj.GetFirmwareVersion();
            disp( sprintf( 'OL490FirmwareVersion: %s', char( OL490FirmwareVersion ) ) );
            OL490FlashVersion = ol_obj.GetFlashVersion();
            disp( sprintf( 'OL490FlashVersion: %s', char( OL490FlashVersion ) ) );
            OL490FPGAVersion = ol_obj.GetFPGAVersion();
            disp( sprintf( 'OL490FPGAVersion: %s', char( OL490FPGAVersion ) ) );
            OL490NumberOfStoredCalibrations = ol_obj.GetNumberOfStoredCalibrations();
            disp( sprintf( 'OL490NumberOfStoredCalibrations: %s', char( OL490NumberOfStoredCalibrations ) ) );
            
            obj.ol_obj = ol_obj;
            
            disp('DONE: initializing OL 490')
        end
        
        %% measure calibration data
        function obj = measureDataForCalibration( obj )
            
            pause( obj.timeToWaitBeforeMeasurementInS );
            
            disp('starting calibration')
            
            obj.ol_obj.OpenShutter();
            
            calibrationSpectrumCellArray = obj.calibrationSpectrumCellArray;
            cs2000MeasurementCellArray = cell( length( calibrationSpectrumCellArray ), 1 );
            for currentSpectrumIndex = 1 : length( calibrationSpectrumCellArray );
                disp( sprintf( 'sending spectrum %d', currentSpectrumIndex ) );
                
                % recall spectrum in OL490
                currentSpectrum = calibrationSpectrumCellArray{ currentSpectrumIndex };
                obj.ol_obj.TurnOnColumn( int64( currentSpectrum ) );
                
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
            
            %auto evaluate data
            obj.evaluateDataForCalibration();
        end
        
        %% evaluate Data for calibration
        function obj = evaluateDataForCalibration( obj )
            
            cs2000MeasurementCellArray = obj.cs2000MeasurementCellArray;
            
            %prepare data for function
            numberOfMeasurements = length( cs2000MeasurementCellArray );
            numberOfSpectralLines = length( cs2000MeasurementCellArray{ 1 }.spectralData );
            
            spectral_data = zeros( numberOfMeasurements, numberOfSpectralLines );
            for currentSpectrum = 1 : numberOfMeasurements
                spectral_data( currentSpectrum, : ) = cs2000MeasurementCellArray{ currentSpectrum }.spectralData;
            end
            
            fileName = sprintf( 'calibrationRawData_%s.mat', datestr( now, 'dd-mmm-yyyy_HH_MM_SS' ) );
            save( fileName, 'cs2000MeasurementCellArray' )
            
            %generate reference data
            res_spline = 0 : 0.1 : 100;
            percent_vector = 0 : 5 : 100;
            [ first_spline ] = percent_spline( spectral_data, percent_vector, res_spline);
            [ final_spline ] = nm_spline( first_spline );
            [ io_real ] = io_real_gen( final_spline );
            [ max_percent_adaption ] = spectral_percent( final_spline );
            
            %save variables to mat file
            fileName = sprintf( 'calibrationData_%s.mat', datestr( now, 'dd-mmm-yyyy_HH_MM_SS' ) );
            save( fileName, 'io_real', 'max_percent_adaption' );
            
            disp('DONE: calibration')
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
                
                calibrationSpectrumCellArray = cell( 21, 1 );
                OL490_MAX_VALUE = 49152;
                
                currentDimValue = 0;    %will increase by 5% each step
                for currentSpectrumIndex = 1 : 21
                    calibrationSpectrumCellArray{ currentSpectrumIndex } = ones( 1024, 1 ) * 49152 * currentDimValue;
                    currentDimValue = currentDimValue + 0.05;
                end
                
                obj.calibrationSpectrumCellArray = calibrationSpectrumCellArray;
                
            end
            value = obj.calibrationSpectrumCellArray;
        end
        
    end
end