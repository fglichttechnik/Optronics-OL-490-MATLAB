% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



classdef OL490SpectrumGenerator < handle
    
    properties
        targetSpectrumCS2000Measurement % original measurement file
        targetSpectrum              % this is the requested spectrum to generate OL490 adapted data for
        targetSpectrumTag           % tag for TargetSpectrum
        desiredLv                   % these is the desired luminance
        ol490Spectrum               % these are the adapted spectra based on the calibration data for each dimLevel
        filePathToCalibrationData   % filePath to calibration data
        %olType                      % target, background or glare OL490
        correctionFactor            % correctionFactor (discrepancy between desired and measured Lv)
        peripheralCorrectionFactorTarget  % correction factor if presented on peripheral position due to inhomogenity
        peripheralCorrectionFactorBackground  % correction factor if presented on peripheral position due to inhomogenity
        %spectralCorrectionFactor    % correctionFactor for discrepandy between desired and measured Spectrum
        
        ol490Sweep                  % sweep to ol490Spectrum
        documentedCS2000Measurement % for documentation purposes
        correctionCS2000Measurement % for documentation purposes
		end
		properties(Dependent)
		ol490Calibration            % calibration data
        end
    properties(Access=private)
        ol490CalibrationInternal    % for internal use only
    end
    
    methods
        %% constructor
        function obj = OL490SpectrumGenerator( targetSpectrumCS2000Measurement, desiredLv, filePathToCalibrationData, targetSpectrumTag )
            obj.targetSpectrumCS2000Measurement = targetSpectrumCS2000Measurement;
            obj.targetSpectrum = cs2000Spectrum_2_OL490Spectrum( obj.targetSpectrumCS2000Measurement );
            obj.desiredLv = desiredLv;
            obj.filePathToCalibrationData = filePathToCalibrationData;
            %obj.olType = olType;
            obj.targetSpectrumTag = targetSpectrumTag;
            obj.correctionFactor = 1;
            obj.peripheralCorrectionFactorTarget = 1;
            obj.peripheralCorrectionFactorBackground = 1;
            %obj.spectralCorrectionFactor = ones( size( obj.targetSpectrum ) );
        end
        
        %% generateSpectrum
        function obj = generateSpectrum( obj )
            
            % prepare data if required
            if( ~obj.ol490Calibration.calibrationDataPrepared )
                obj.ol490Calibration.prepareCalibrationData();
            end
            
            inputOutputMatrix = obj.ol490Calibration.inputOutputCalibrationMatrix;
            interpolatedSpectralDataMatrix = obj.ol490Calibration.interpolatedSpectralDataCalibrationMatrix;
            maxValueOfAllSpectra = obj.ol490Calibration.maxValueOfAllSpectra;
            
            desiredTargetSpectrum = obj.targetSpectrum;
            %experimental: add spectral correction
            %             OL490MAX = 49152;
            %             oldDesiredTargetSpectrum = obj.targetSpectrum .* obj.spectralCorrectionFactor;
            %             desiredTargetSpectrum = oldDesiredTargetSpectrum / max( oldDesiredTargetSpectrum ) * OL490MAX;
            %
            %calc maximum possible spectrum for targetSpectrum
            %ol490Spectrum = OL490Spectrum( obj.targetSpectrum );
            dimFactor = 1;
            [ ol490TargetSpectrum ] = generateOL490Spectrum( ...
                desiredTargetSpectrum,...
                interpolatedSpectralDataMatrix, ...
                inputOutputMatrix, ...
                maxValueOfAllSpectra, ...
                dimFactor...
                );
            
            %now calc spectrum with certain dimFactor to create desired Lv
            %maybe we have to do this iterative
            numberOfIterations = 0;
            maxNumberOfIterations = 10;
            dimFactor = obj.desiredLv / ol490TargetSpectrum.Lv;
            allowedError = 0.01;
            while( numberOfIterations <= maxNumberOfIterations )
                [ ol490TargetSpectrum ] = generateOL490Spectrum( ...
                    desiredTargetSpectrum,...
                    interpolatedSpectralDataMatrix, ...
                    inputOutputMatrix, ...
                    maxValueOfAllSpectra, ...
                    dimFactor...
                    );
                currentError = obj.desiredLv / ol490TargetSpectrum.Lv;
                if( abs( currentError - 1 ) <  allowedError )
                    break;
                end
                dimFactor = currentError * dimFactor;
                numberOfIterations = numberOfIterations + 1;
            end
            
            %save spectrum
            obj.ol490Spectrum = ol490TargetSpectrum;
        end
        
        %% prepareSweep
        function prepareSweep( obj, sweepTime, sweepType, sweepMode, sweepSteps, minDimLevelRatio, maxDimLevelRatio )
            obj.ol490Sweep = OL490SweepGenerator( obj, sweepTime, sweepType, sweepMode, sweepSteps, minDimLevelRatio, maxDimLevelRatio );
            obj.ol490Sweep.generateSweep();
        end
        
        %% removeInterpolatedCalibrationData
        function removeInterpolatedCalibrationData( obj )
            obj.ol490Calibration.calibrationDataPrepared = 0;
            obj.ol490Calibration.inputOutputCalibrationMatrix = [];
            obj.ol490Calibration.interpolatedSpectralDataCalibrationMatrix = [];
            obj.ol490Calibration.maxValueOfAllSpectra = [];
        end
        
        %% visualizeData
        function visualizeData( obj )
            
            ol490TargetSpectrum = obj.ol490Spectrum;
            
            %visualize data
            from = 100;
            to = length( ol490TargetSpectrum.spectrum ) - 100;
            disp( sprintf( 'meanOfSpectrum: %5.0f stdOfSpectrum: %5.1f', mean( ol490TargetSpectrum.spectrum( from : to ) ), std( ol490TargetSpectrum.spectrum( from : to ) ) )  );
            xenonSpectrum = cs2000Spectrum_2_OL490Spectrum(obj.ol490Calibration.cs2000MeasurementCellArray{end} );
            figure();
            plot( obj.targetSpectrum / max ( obj.targetSpectrum ), 'r');
            hold on;
            plot( ol490TargetSpectrum.spectrum / max ( ol490TargetSpectrum.spectrum ), 'gr');
            plot( xenonSpectrum / max ( xenonSpectrum ), 'b');
            hold off;
            legend( 'target', 'ol490', 'xenon' );
            close( gcf() );
            
        end
        
        %% get.ol490Calibration
        function value = get.ol490Calibration( obj )
            if( isempty( obj.ol490CalibrationInternal ) )
                load( obj.filePathToCalibrationData );
                if( exist( 'ol490CalibrationBackground', 'var' ) )
                    obj.ol490CalibrationInternal = ol490CalibrationBackground;
                elseif( exist( 'ol490CalibrationTarget', 'var' ) )
                    obj.ol490CalibrationInternal = ol490CalibrationTarget;
                else
                    disp( 'no calibration file found' );
                end
                
                if( ~isempty( obj.ol490CalibrationInternal ) )
                fprintf( 'Using calibration file with date: %s\n', obj.ol490CalibrationInternal.calibrationDate );
                end
                
            end
            value = obj.ol490CalibrationInternal;
        end
        
        %% set.ol490Calibration
        function set.ol490Calibration( obj, newCalibration )            
            obj.ol490CalibrationInternal = newCalibration;
        end
        
        %% calculateLuminancCorrectionFactor
        function calculateLuminancCorrectionFactor( obj )
            
            %measure data
            obj.correctionCS2000Measurement = obj.measureSpectralVariance();
            actualCS2000Measurement = obj.correctionCS2000Measurement;
            
            %calculate correction factor
            actualMeasurement = cs2000Spectrum_2_OL490Spectrum( actualCS2000Measurement );
            relativeMeasurementSpectrum = actualMeasurement / max( actualMeasurement );
            relativeTargetSpectrum = obj.targetSpectrum / max( obj.targetSpectrum );
            %obj.spectralCorrectionFactor = relativeMeasurementSpectrum ./ relativeTargetSpectrum;
            obj.correctionFactor = 1 / ( actualCS2000Measurement.colorimetricData.Lv / obj.desiredLv );
            disp( sprintf( 'correctionFactor: %1.2f (desiredLuminance: %2.3f)', obj.correctionFactor, obj.desiredLv ) );
        end
        
        %% adjustLuminanceCorrectionFactorForProjectedBackgroundLuminance 
        function adjustLuminanceCorrectionFactorForProjectedBackgroundLuminance( obj, backgroundLuminance )
            
            actualCS2000Measurement = obj.correctionCS2000Measurement;
            
            %recalculate correction factor
            actualMeasurement = cs2000Spectrum_2_OL490Spectrum( actualCS2000Measurement );
            relativeMeasurementSpectrum = actualMeasurement / max( actualMeasurement );
            relativeTargetSpectrum = obj.targetSpectrum / max( obj.targetSpectrum );
            %obj.spectralCorrectionFactor = relativeMeasurementSpectrum ./ relativeTargetSpectrum;
            oldCorrectionFactor = obj.correctionFactor;
            obj.correctionFactor = abs( 1 / ( ( actualCS2000Measurement.colorimetricData.Lv - backgroundLuminance ) / obj.desiredLv ) );
            disp( sprintf( 'adjusted correctionFactorTo: %1.2f (from: %1.2f) (desiredLuminance: %2.3f)', obj.correctionFactor, oldCorrectionFactor, obj.desiredLv ) );
        end
        
        %% documentSpectralVariance
        function documentSpectralVariance( obj, titleString, fileName )
            
            % save measured data for documentation
            obj.documentedCS2000Measurement = obj.measureSpectralVariance( titleString, fileName  );
        end
        
        %% measureSpectralVariance
        function actualCS2000Measurement = measureSpectralVariance( obj, titleString, fileName )
            
            % measure spectrum via CS2000
            disp( 'measuring' );
            %CS2000_initConnection();
            [message1, message2, actualCS2000Measurement, colorimetricNames] = CS2000_measure();
            %CS2000_terminateConnection();
            pause( 1 );
            
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
            
            if( exist( 'titleString' ) )
                title( titleString );
            end
            %ylabel( 'L_{e,rel}(\lambda)' );
            y = ylabel('$$\mbox{L}_{e,rel}(\lambda)$$');
            set(y,'Interpreter','LaTeX','FontSize',14)
            %save variable to mat file which will be overwritten every time
            %fileName = sprintf( 'targetSpectralVariance_%s.mat', currentTimeString );
            
            luminanceText = sprintf( 'Lv,act = %3.3f cd/m^2', actualCS2000Measurement.colorimetricData.Lv );
            luminanceTextRef = sprintf( 'Lv,tar = %3.3f cd/m^2', obj.desiredLv );
            t=text( 0.1, 0.1, luminanceText, 'Units', 'normalized' );
            t=text( 0.1, 0.2, luminanceTextRef, 'Units', 'normalized' );
            set( gca, 'YScale', 'lin' );
            disp( sprintf( 'measured luminance: %3.3f cd/m^2', actualCS2000Measurement.colorimetricData.Lv ) );
            
            %prepare filename and save
            if( exist( 'fileName' ) && exist( 'titleString' ) )
                spacesIndices = strfind( titleString,' ' );
                for currentSpaceIndex = 1 : length( spacesIndices )
                    titleString( spacesIndices( currentSpaceIndex ) ) = '_';
                end
                spacesIndices = strfind( titleString,'^' );
                for currentSpaceIndex = 1 : length( spacesIndices )
                    titleString( spacesIndices( currentSpaceIndex ) ) = '_';
                end
                spacesIndices = strfind( titleString,'/' );
                for currentSpaceIndex = 1 : length( spacesIndices )
                    titleString( spacesIndices( currentSpaceIndex ) ) = '_';
                end
                spacesIndices = strfind( titleString,'.' );
                for currentSpaceIndex = 1 : length( spacesIndices )
                    titleString( spacesIndices( currentSpaceIndex ) ) = '_';
                end
                
                disp( sprintf( 'saving with fileName: %s', titleString ) );
               % saveas( gcf(), sprintf('%s_measurement_%s', fileName, titleString ), 'fig' );
               % saveas( gcf(), sprintf('%s_measurement_%s', fileName, titleString ), 'epsc' );
            end
            close( gcf() );
            
            
        end
    end
end