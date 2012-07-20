classdef OL490SpectrumGenerator < handle

properties
	targetSpectrum 	% this is the requested spectrum to generate OL490 adapted data for
	dimLevels 	% these is (are) the desired dimLevel (s)
	ol490AdaptedSpectrum 	% this is the adapted spectrum based on the calibration data
end

methods
	%% constructor
	function obj = OL490SpectrumGenerator( targetSpectrum, dimLevels )
		obj.targetSpectrum = targetSpectrum;
		obj.dimLevels = dimLevels;
	end
	
	%% calculate luminances
	%% TODO: implement this calculate this based on the calibration data
	function [ obj, luminance ] = calcLuminanceForSpectrum( obj, spectrum )
	end
	
	%% get dimLevel for luminance
	%% TODO: implement this return closest matching dim factor for spectrum
	function [ obj, dimLevel ] = dimLevelForLuminance( obj, luminance )
	end
	
	%% create adapted spectrum on demand
	function value = get.ol490AdaptedSpectrum( obj )
		
		if( isempty( obj.ol490AdaptedSpectrum ) )
			%% TODO: implement spectrum generation
            % marians code shall be called here
		
		end
	
		value = obj.ol490AdaptedSpectrum;
	end
end
end