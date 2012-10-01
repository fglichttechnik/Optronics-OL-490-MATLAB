%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490SweepGenerator < handle
    
    properties
        ol490Spectrum           % the maximum spectrum
        ol490SpectrumArray      % the array with intermediate luminance levels
        sweepType               % sweep type: linear, logarithmic
    end
    
    methods
        %% constructor
        function obj = OL490SweepGenerator( ol490Spectrum, sweepType )
            obj.ol490Spectrum = ol490Spectrum;
            obj.sweepType = sweepType;
        end
        
        %% generateSpectrum
        function obj = generateSweep( obj )
            
            
            %calc maximum possible spectrum for targetSpectrum
            %ol490Spectrum = OL490Spectrum( obj.targetSpectrum );
%             dimFactor = obj.desiredLv;
%             [ ol490TargetSpectrum ] = generateOL490Spectrum( ...
%                 obj.targetSpectrum,...
%                 interpolatedSpectralDataMatrix, ...
%                 inputOutputMatrix, ...
%                 interpolatedMaxValuesForDimLevelSpectra, ...
%                 dimFactor...
%                 );
%             
%             obj.ol490Spectrum = ol490TargetSpectrum;
            
        end
    end
end