% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



classdef OL490SweepGenerator < handle
    
    properties
        ol490Spectrum           % the maximum spectrum
        ol490SpectrumArrayUp      % the array with intermediate luminance levels
        ol490SpectrumArrayDown      % inverted ol490SpectrumArrayUp
        minDimLevelRatio        % dimFactor for lowest dimLevel as factor on Lv of ol490Spectrum
        maxDimLevelRatio        % dimFactor for highest dimLevel as factor on Lv of ol490Spectrum
        sweepType               % sweep type: linear, logarithmic (lin, log)
        sweepMode               % up or down
        sweepTime               % time for whole sweep
        sweepSteps              % number of iterations
        sweepPeriod             % duration of one sweep presentation: depending on sweepTime and sweepSteps
        currentSweepIndex       % index of current dimLevel of sweep
        currentSweepSpectrum    % current ol490Spectrum for currentSweepIndex (auto increments currentSweepIndex on each call)
        currentSweepSpectrumAtCurrentIndex    % current ol490Spectrum for currentSweepIndex (without auto increments currentSweepIndex on each call)
        dimLevels               % actual dim levels
    end
    
    events
        sweepDoneNotification  % sent when currentSweepIndex > sweepSteps
    end
    
    methods
        %% constructor
        function obj = OL490SweepGenerator( ol490Spectrum, sweepTime, sweepType, sweepMode, sweepSteps, minDimLevelRatio, maxDimLevelRatio )
            obj.ol490Spectrum = ol490Spectrum;
            obj.sweepTime = sweepTime;
            obj.sweepSteps = sweepSteps;
            obj.sweepMode = sweepMode;
            obj.sweepType = sweepType;
            obj.minDimLevelRatio = minDimLevelRatio;
            obj.maxDimLevelRatio = maxDimLevelRatio;
            obj.currentSweepIndex = 1;
            
            obj.sweepPeriod = obj.sweepTime / obj.sweepSteps;
        end
        
        %% get.currentSweepSpectrumAtCurrentIndex
        function value = get.currentSweepSpectrumAtCurrentIndex ( obj )
            
            %indicate out of bounds
            if( obj.currentSweepIndex > obj.sweepSteps )
                notify( obj, 'sweepDoneNotification' );
                
                obj.currentSweepIndex = obj.sweepSteps;
            end
            
            %get corresponding sweep spectrum
            if( strcmp( obj.sweepMode, 'up' ) )
                value = obj.ol490SpectrumArrayUp{ obj.currentSweepIndex };
            elseif( strcmp( obj.sweepMode, 'down' ) )
                value = obj.ol490SpectrumArrayDown{ obj.currentSweepIndex };
            else
                error( 'unknown sweep mode' );
            end
            
        end
        
        %% get.currentSweepSpectrum
        function value = get.currentSweepSpectrum( obj )
            
            disp('accessing currentSweepSpectrum');
            
            value = obj.currentSweepSpectrumAtCurrentIndex();
            
            %auto increment sweep index
            obj.currentSweepIndex = obj.currentSweepIndex + 1;
        end
        
        %% generateSpectrum
        function obj = generateSweep( obj )
            
            %prepare data
            targetSpectrumCS2000Measurement = obj.ol490Spectrum.targetSpectrumCS2000Measurement;
            filePathForCalibrationFile = obj.ol490Spectrum.filePathToCalibrationData;
            %ol490Type = obj.ol490Spectrum.olType;            
            numberOfSweepSteps = obj.sweepSteps;
            obj.currentSweepIndex = 1;
            
            %generate dimLevels            
            minDimlevelRatio = obj.minDimLevelRatio;
            maxDimlevelRatio = obj.maxDimLevelRatio;
            if( strcmp( obj.sweepType, 'lin' ) )
                dimLevelArray = linspace( minDimlevelRatio, maxDimlevelRatio, numberOfSweepSteps );
            elseif( strcmp( obj.sweepType, 'log' ) )
                tao = 35;
                steps = linspace( 0, numberOfSweepSteps, numberOfSweepSteps );
                dimValues = exp( -steps / tao );
                dimValues = dimValues ./ max( dimValues );
                dimValues = 1 - dimValues;
                minimum = min( dimValues );
                dimValues = dimValues + minimum;
                maximum = max( dimValues );
                dimValues = dimValues / maximum;
                dimValues = dimValues * maxDimlevelRatio;
                dimLevelArray = dimValues;
            else
                error( 'unkown sweepType' );
            end
            obj.dimLevels = dimLevelArray;
            
            %generate sweepUp
            desiredLv = obj.ol490Spectrum.desiredLv;
            spectrumTag = obj.ol490Spectrum.targetSpectrumTag;
            obj.ol490SpectrumArrayUp = cell( numberOfSweepSteps, 1  );
            for currentDimLevelIndex = 1 : numberOfSweepSteps
                currentDimLevel = dimLevelArray( currentDimLevelIndex );           
                currentLv = desiredLv * currentDimLevel;
                disp( sprintf( 'current sweepIndex: %d withDimlevel: %1.3f withLv: %1.3f', currentDimLevelIndex, currentDimLevel, currentLv ) );
                currentOL490Spectrum = OL490SpectrumGenerator( targetSpectrumCS2000Measurement, currentLv, filePathForCalibrationFile, spectrumTag )
                currentOL490Spectrum.ol490Calibration = obj.ol490Spectrum.ol490Calibration;
                currentOL490Spectrum.generateSpectrum( );
                currentOL490Spectrum.ol490Calibration = [];
                obj.ol490SpectrumArrayUp{ currentDimLevelIndex } = currentOL490Spectrum;
            end
            
            %generate sweepDown
            obj.ol490SpectrumArrayDown = cell( numberOfSweepSteps, 1  );
            for currentDimLevelIndex = 1 : numberOfSweepSteps
                obj.ol490SpectrumArrayDown{ currentDimLevelIndex } = obj.ol490SpectrumArrayUp{ numberOfSweepSteps - currentDimLevelIndex + 1 };
            end
            
%             timeForStimuliInS = 10;
%             ol490Controller.sendSpectrum( spectra{1}.ol490Spectrum.spectrum );
%             ol490Controller.openShutter();
%             start = tic();
%             for i = 1 : numberOfLevels
%                 timePerStimulus = timeForStimuliInS / numberOfLevels;
%                 tic();
%                 ol490Controller.sendSpectrum( spectra{i}.ol490Spectrum.spectrum );
%                 timePassed = toc();
%                 if( timePassed < timePerStimulus )
%                     timeToWait = timePerStimulus - timePassed;
%                     disp( sprintf( 'waiting %f: s', timeToWait ) );
%                     pause( timeToWait );
%                 else
%                     disp( sprintf( 'too much time passed: %f s', timePassed ) );
%                 end
%             end
%             disp( sprintf( 'total time elapsed: %f s', toc( start ) ) );
        end
    end
end