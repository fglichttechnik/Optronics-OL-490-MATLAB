%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490SweepGenerator < handle
    
    properties
        ol490Spectrum           % the maximum spectrum
        ol490SpectrumArrayUp      % the array with intermediate luminance levels
        ol490SpectrumArrayDown      % inverted ol490SpectrumArrayUp
        minDimLevelRatio        % dimFactor for lowest dimLevel as factor on Lv of ol490Spectrum
        sweepType               % sweep type: linear, logarithmic (lin, log)
        sweepTime               % time for whole sweep
        sweepSteps              % number of iterations
        sweepSleepTime          % depending on sweepTime and sweepSteps
    end
    
    methods
        %% constructor
        function obj = OL490SweepGenerator( ol490Spectrum, sweepTime, sweepType )
            obj.ol490Spectrum = ol490Spectrum;
            obj.sweepTime = sweepTime;
            obj.sweepType = sweepType;
        end
        
        %% generateSpectrum
        function obj = generateSweep( obj )
            
            targetSpectrumCS2000Measurement = obj.ol490Spectrum.targetSpectrumCS2000Measurement;
            filePathForCalibrationFile = obj.ol490Spectrum.filePathToCalibrationData;
            ol490Type = obj.ol490Spectrum.olType;
            
            numberOfSweepSteps = obj.sweepSteps;
            
            %generate dimLevels
            
            dimlevelRatio = obj.minDimLevelRatio;
            if( strcmp( obj.sweepType, 'lin' ) )
                dimLevelArray = linspace( dimlevelRatio, 1, numberOfSweepSteps );
            elseif( strcmp( obj.sweepType, 'log' ) )
                tao = 35;
                steps = linspace( 0, numberOfSweepSteps, numberOfSweepSteps );
                dimValues = exp( -steps / tao );
                dimValues = dimValues ./ max( dimValues );
                dimValues = 1 - dimValues;
                minimum = min( dimValues );
                dimValues = dimValues + dimlevelRatio;
                maximum = max( dimValues );
                dimValues = dimValues / maximum;
                dimLevelArray = dimValues;
            else
                error( 'unkown sweepType' );
            end
            
            
            %generate sweepUp
            desiredLv = obj.ol490Spectrum.desiredLv;
            obj.ol490SpectrumArrayUp = cell( numberOfSweepSteps, 1  );
            for currentDimLevelIndex = 1 : numberOfSweepSteps
                currentLv = desiredLv * dimLevelArray( currentDimLevelIndex );
                currentOL490Spectrum = OL490SpectrumGenerator( targetSpectrumCS2000Measurement, currentLv, filePathForCalibrationFile, ol490Type )
                currentOL490Spectrum.generateSpectrum( );
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