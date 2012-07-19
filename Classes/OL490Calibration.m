%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

% classdef OL490Calibration < handle
%     %% properties
%     properties
%         %ol_obj                          % handle to OL490
%         numberOfMeasurementIterations   % number of repetitions per light level
%         calibrationDataset              % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
%         calibrationSpectrumCellArray    % cell array with calibration spectrum 0%-100% in 5% steps
%     end
%     methods
        %% constructor
        function OL490Calibration( calibrationDataset, numberOfMeasurementIterations )
            %obj.calibrationDataset = calibrationDataset;
            %obj.numberOfMeasurementIterations = numberOfMeasurementIterations;
            ol_obj = init( calibrationDataset );
        end
        
        %% init devices
        function [ ol_obj ] = init( calibrationDataset )%obj )
            %obj.initCS2000();
            initCS2000();
            %ol_obj = obj.initOL490();
            ol_obj = initOL490( calibrationDataset );
        end
        
        %% disconnect devices
        function obj = terminate( obj )
            obj.CS2000_terminateConnection();
            %obj.initOL490(); %% TODO:implement disconnect
        end
        
        %% init CS2000
        %function obj = initCS2000( obj )
        function initCS2000(  )
            disp('initializing CS2000')
            CS2000_initConnection();
            disp('DONE: initializing CS2000')
        end
        
        %% init OL490
        function [ ol_obj ] = initOL490( calibrationDataset )
            disp('initializing OL 490')
            cur = what;
            path = cur.path;
            NET.addAssembly([path '\dll\OLIPluginLibrary.dll']);
            NET.addAssembly([path '\dll\OL490LIB.dll']);
            NET.addAssembly([path '\dll\OL490_SDK_Dll.dll']);
            NET.addAssembly([path '\dll\CyUSB.dll']);
            ol_obj = OL490_SDK_Dll.OL490SdkLibrary();
            result = ol_obj.CloseShutter();
            disp( sprintf( 'result of operation: %s', char( result ) ) );
            ol_obj.LoadAndUseStoredCalibration( calibrationDataset );
            
            OL490SerialNumber = ol_obj.GetOL490SerialNumber();
            disp( sprintf( 'OL490SerialNumber: %s', char( OL490SerialNumber ) ) );
            OL490FirmwareVersion = ol_obj.GetFirmwareVersion();
            disp( sprintf( 'OL490SerialNumber: %s', char( OL490FirmwareVersion ) ) );
            OL490FlashVersion = ol_obj.GetFlashVersion();
            disp( sprintf( 'OL490SerialNumber: %s', char( OL490FlashVersion ) ) );
            %OL490FPGAVersion = ol_obj.GetFPGAVersion();
            %disp( sprintf( 'OL490SerialNumber: %s', char( OL490FPGAVersion ) ) );
            OL490NumberOfStoredCalibrations = ol_obj.GetNumberOfStoredCalibrations();
            disp( sprintf( 'OL490SerialNumber: %s', char( OL490NumberOfStoredCalibrations ) ) );
            
            %obj.ol_obj = ol_obj;
            
            disp('DONE: initializing OL 490')
        end
        
        %% measure calibration file
        function obj = startCalibration( obj, ol_obj )
            disp('starting calibration')
            
            ol_obj.OpenShutter();
            
            calibrationSpectrumCellArray = obj.calibrationSpectrumCellArray;
            for currentSpectrumIndex = 1 : length( calibrationSpectrumCellArray );
                disp( sprintf( 'sending spectrum %d', currentSpectrumIndex ) );
                
                % recall spectrum in OL490
                currentSpectrum = calibrationSpectrumCellArray{ currentSpectrumIndex };
                ol_obj.TurnOnColumn( int64( currentSpectrum ) );
                
                % measure spectrum via CS2000
                CS2000_measure()
                
                %% TODO: repeat this step for numberOfMeasurementIterations
                % times
                % save measurement
            end
            
            %% TODO: create calibration file
            
            disp('DONE: calibration')
        end
        
        %% calibration spectrum
        function value = calibrationSpectrumCellArray( )
            %if ( isempty( obj.calibrationSpectrumCellArray ) )
                calibrationSpectrumCellArray = cell( 21, 1 );
                OL490_MAX_VALUE = 49152;
                
                currentDimValue = 0;    %will increase by 5% each step
                for currentSpectrumIndex = 1 : 21
                    calibrationSpectrumCellArray{ currentSpectrumIndex } = ones( 1024, 1 ) * 49152 * currentDimValue;
                    currentDimValue = currentDimValue + 0.05;
                end
                
                %obj.calibrationSpectrumCellArray = calibrationSpectrumCellArray;
                
            %end
            value = calibrationSpectrumCellArray;
        end
        
    %end
%end