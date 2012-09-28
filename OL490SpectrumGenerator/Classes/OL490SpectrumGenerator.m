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
        function obj = generateSpectrum( obj )
            
            % load calibration data
            load( obj.filePathToCalibrationData );
            %'inputOutputMatrix',
            %'interpolatedSpectralDataMatrix',
            %'cs2000MeasurementCellArray'
            %, 'interpolatedMaxValuesForDimLevelSpectra'
            
            %calc maximum possible spectrum for targetSpectrum
            %ol490Spectrum = OL490Spectrum( obj.targetSpectrum );
            dimFactor = 1.0;
            [ ol490Spectrum ] = generateOL490Spectrum( ...
                obj.targetSpectrum,...
                interpolatedSpectralDataMatrix, ...
                inputOutputMatrix, ...
                dimFactor,...
                interpolatedMaxValuesForDimLevelSpectra ...
                ); 
            
            obj.ol490Spectrum = ol490Spectrum;
            
        end
    end
end