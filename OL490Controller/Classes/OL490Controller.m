%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490Controller < handle
    
    properties
        ol_obj                          % handle to OL490
        ol490CalibrationDataset         % 0 = 150µm, 1 = 350µm, 2 = 500µm, 3 = 750µm
        ol490Index                      % index of ol490 0, 1...
    end
    
    methods
        %% constructor
        function obj = OL490Controller( ol490Index, ol490CalibrationDataset )
            obj.ol490Index = ol490Index;
            obj.ol490CalibrationDataset = ol490CalibrationDataset;
        end
        
        %% init connection
        function obj = init( obj )
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
            disp( sprintf( 'OL490NumberOfStoredCalibrations: %s', num2str( OL490NumberOfStoredCalibrations ) ) );
            
            obj.ol_obj = ol_obj;
        end
        
        %% open shutter
        function obj = openShutter( obj )
            obj.ol_obj.OpenShutter();
        end
        
        %% open shutter
        function obj = closeShutter( obj )
            obj.ol_obj.CloseShutter();
        end
        
        %% send a spectrum
        function obj = sendSpectrum( obj, currentSpectrum )
            disp( sprintf( 'correcting spectrum with %1.2f', currentSpectrum.correctionFactor ) );
            olSpectrum = currentSpectrum.ol490Spectrum.spectrum * currentSpectrum.correctionFactor;
            obj.ol_obj.TurnOnColumn( int64( olSpectrum ) );
        end
    end
    
end