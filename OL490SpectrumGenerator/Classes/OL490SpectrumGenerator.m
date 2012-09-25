%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490SpectrumGenerator < handle

properties
	targetSpectrum              % this is the requested spectrum to generate OL490 adapted data for
	luminance                   % these is the desired luminance
	ol490AdjustedSpectrum         % these are the adapted spectra based on the calibration data for each dimLevel
    filePathToCalibrationData   % filePath to calibration data
end

methods
	%% constructor
	function obj = OL490SpectrumGenerator( targetSpectrum, luminance, filePathToCalibrationData )
		obj.targetSpectrum = targetSpectrum;
		obj.luminance = luminance;
        obj.filePathToCalibrationData = filePathToCalibrationData;
    end
	
	%% get dimLevel for luminance
	%% TODO: implement this - return closest match for requested luminance
% 	function [ obj, adjustedSpectrum ] = adjustedSpectrumForLuminance( obj )
%         % calc max possible luminance
%         % load calibration spectrum:
%         data                = load( obj.filePathToCalibrationData );
%         dataPercent         = data ./ max( max( data ));
%         PercentResolution   = 0 : 0.1 : 100;
%         userSpectrum        = load( obj.targetSpectrum ) ;
%         
%         
% 	end
	
	%% create adapted spectrum on demand
	%function value = get.ol490AdaptedSpectrum( obj )
    function obj = createAdjustedSpectrum( obj )
		
		%if( isempty( obj.ol490AdaptedSpectrum ) )
            
            % load calibration data
            load( obj.filePathToCalibrationData );
            
            %calc maximum possible spectrum for targetSpectrum
            [ adjustedSpectrum, Lv_max ] = spectrumAdaption( obj.targetSpectrum, max_percent_adaption, io_real, 1, maxValues );

            
            obj.ol490AdjustedSpectrum = adjustedSpectrum;
            
		%end
	
		%value = obj.ol490AdaptedSpectrum;
	end
end
end