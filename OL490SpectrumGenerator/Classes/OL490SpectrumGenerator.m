%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490SpectrumGenerator < handle
    
    properties
        targetSpectrum              % this is the requested spectrum to generate OL490 adapted data for
        desiredLv                   % these is the desired luminance
        ol490Spectrum         % these are the adapted spectra based on the calibration data for each dimLevel
        filePathToCalibrationData   % filePath to calibration data
    end
    
    methods
        %% constructor
        function obj = OL490SpectrumGenerator( targetSpectrum, desiredLv, filePathToCalibrationData )
            obj.targetSpectrum = targetSpectrum;
            obj.desiredLv = desiredLv;
            obj.filePathToCalibrationData = filePathToCalibrationData;
        end
        
        %% generateSpectrum
        function obj = generateSpectrum( obj, inputOutputMatrix, interpolatedSpectralDataMatrix, interpolatedMaxValuesForDimLevelSpectra )
            
            if( nargin < 2)
                % load calibration data
                [ inputOutputMatrix,...
                    interpolatedSpectralDataMatrix,...
                    interpolatedMaxValuesForDimLevelSpectra ] = OL490Calibration.loadCalibrationData( obj.filePathToCalibrationData );
                %'inputOutputMatrix',
                %'interpolatedSpectralDataMatrix',
                %'cs2000MeasurementCellArray'
                %, 'interpolatedMaxValuesForDimLevelSpectra'
            end
            
            %calc maximum possible spectrum for targetSpectrum
            %ol490Spectrum = OL490Spectrum( obj.targetSpectrum );
            dimFactor = obj.desiredLv;
            [ ol490TargetSpectrum ] = generateOL490Spectrum( ...
                obj.targetSpectrum,...
                interpolatedSpectralDataMatrix, ...
                inputOutputMatrix, ...
                interpolatedMaxValuesForDimLevelSpectra, ...
                dimFactor...
                );
            
            obj.ol490Spectrum = ol490TargetSpectrum;
            
        end
    end
end