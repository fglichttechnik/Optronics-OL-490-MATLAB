%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490SpectrumGenerator < handle
    
    properties
        targetSpectrum              % this is the requested spectrum to generate OL490 adapted data for
        desiredLv                   % these is the desired luminance
        ol490Spectrum               % these are the adapted spectra based on the calibration data for each dimLevel
        filePathToCalibrationData   % filePath to calibration data
        olType                      % target, background or glare OL490
    end
    
    methods
        %% constructor
        function obj = OL490SpectrumGenerator( targetSpectrum, desiredLv, filePathToCalibrationData, olType )
            obj.targetSpectrum = targetSpectrum;
            obj.desiredLv = desiredLv;
            obj.filePathToCalibrationData = filePathToCalibrationData;
            obj.olType = olType;
        end
        
        %% generateSpectrum
        function obj = generateSpectrum( obj, inputOutputMatrix, interpolatedSpectralDataMatrix, interpolatedMaxValuesForDimLevelSpectra )
            
            if( nargin < 2)
                % load calibration data
                [ inputOutputMatrix,...
                    interpolatedSpectralDataMatrix,...
                    maxValueOfAllSpectra ] = OL490Calibration.loadCalibrationData( obj.filePathToCalibrationData );
                %'inputOutputMatrix',
                %'interpolatedSpectralDataMatrix',
                %'cs2000MeasurementCellArray'
                %, 'interpolatedMaxValuesForDimLevelSpectra'
            end
            
            %calc maximum possible spectrum for targetSpectrum
            %ol490Spectrum = OL490Spectrum( obj.targetSpectrum );
            dimFactor = 1;
            [ ol490TargetSpectrum ] = generateOL490Spectrum( ...
                obj.targetSpectrum,...
                interpolatedSpectralDataMatrix, ...
                inputOutputMatrix, ...
                maxValueOfAllSpectra, ...
                dimFactor...
                );
            
            %now calc spectrum with certain dimFactor to create desired Lv            
            %maybe we have to do this iterative
            numberOfIterations = 0;
            maxNumberOfIterations = 3;
            dimFactor = obj.desiredLv / ol490TargetSpectrum.Lv;
            while( numberOfIterations <= maxNumberOfIterations )                
                [ ol490TargetSpectrum ] = generateOL490Spectrum( ...
                    obj.targetSpectrum,...
                    interpolatedSpectralDataMatrix, ...
                    inputOutputMatrix, ...
                    maxValueOfAllSpectra, ...
                    dimFactor...
                    );
                dimFactor = obj.desiredLv / ol490TargetSpectrum.Lv * dimFactor;
                numberOfIterations = numberOfIterations + 1;
            end
            
            obj.ol490Spectrum = ol490TargetSpectrum;            
        end
    end
end