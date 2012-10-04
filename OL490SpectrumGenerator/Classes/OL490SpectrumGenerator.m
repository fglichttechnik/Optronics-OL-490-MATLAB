%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490SpectrumGenerator < handle
    
    properties
        targetSpectrumCS2000Measurement % original measurement file
        targetSpectrum              % this is the requested spectrum to generate OL490 adapted data for
        desiredLv                   % these is the desired luminance
        ol490Spectrum               % these are the adapted spectra based on the calibration data for each dimLevel
        filePathToCalibrationData   % filePath to calibration data
        olType                      % target, background or glare OL490
        correctionFactor            % correctionFactor (discrepancy between desired and measured Lv)
    end
    
    methods
        %% constructor
        function obj = OL490SpectrumGenerator( targetSpectrumCS2000Measurement, desiredLv, filePathToCalibrationData, olType )
            obj.targetSpectrumCS2000Measurement = targetSpectrumCS2000Measurement;
            obj.targetSpectrum = cs2000Spectrum_2_OL490Spectrum( obj.targetSpectrumCS2000Measurement );
            obj.desiredLv = desiredLv;
            obj.filePathToCalibrationData = filePathToCalibrationData;
            obj.olType = olType;
            obj.correctionFactor = 1;
        end
        
        %% generateSpectrum
        function obj = generateSpectrum( obj, inputOutputMatrix, interpolatedSpectralDataMatrix )
            
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
        
            %% documentSpectralVariance
        function documentSpectralVariance( obj )
                        
            % measure spectrum via CS2000
            disp( 'measuring' );
            CS2000_initConnection();
            [message1, message2, actualCS2000Measurement, colorimetricNames] = CS2000_measure();
            CS2000_terminateConnection();
            
            %prepare save
            currentTimeString = datestr( now, 'dd-mmm-yyyy_HH_MM_SS' );
            
            %normalize data
            obj.targetSpectrumCS2000Measurement.spectralData = obj.targetSpectrumCS2000Measurement.spectralData / max( obj.targetSpectrumCS2000Measurement.spectralData );
            actualCS2000Measurement.spectralData = actualCS2000Measurement.spectralData / max( actualCS2000Measurement.spectralData );
            
            figure();
            plot( obj.targetSpectrumCS2000Measurement, 'r' );
            hold on;
            plot( actualCS2000Measurement, 'gr' );            
            hold off;
            legend( 'target', 'actual'  );
            %ylabel( 'L_{e,rel}(\lambda)' );
            y = ylabel('$$\mbox{L}_{e,rel}(\lambda)$$');
            set(y,'Interpreter','LaTeX','FontSize',14)
            %save variable to mat file which will be overwritten every time
            %fileName = sprintf( 'targetSpectralVariance_%s.mat', currentTimeString );
            %save( fileName, 'actualCS2000Measurement' );
            luminanceText = sprintf( 'Lv,act = %3.3f cd/m^2', actualCS2000Measurement.colorimetricData.Lv );
            luminanceTextRef = sprintf( 'Lv,tar = %3.3f cd/m^2', obj.desiredLv );
            t=text( 0.1, 0.1, luminanceText, 'Units', 'normalized' );
            t=text( 0.1, 0.2, luminanceTextRef, 'Units', 'normalized' );
            set( gca, 'YScale', 'lin' );
            disp( sprintf( 'measured luminance: %3.3f cd/m^2', actualCS2000Measurement.colorimetricData.Lv ) );
            
            obj.correctionFactor = 1 / ( actualCS2000Measurement.colorimetricData.Lv / obj.desiredLv );
            disp( sprintf( 'correctionFactor: %1.2f', obj.correctionFactor ) );
        end
    end
end