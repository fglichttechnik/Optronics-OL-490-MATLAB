% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



classdef OL490CalibrationSpectrum < handle
    %% properties
    properties
        spectrum	% raw OL490 values
        dimLevel	% current dimLevel of calibration spectrum
    end
    methods
        %% constructor
        function obj = OL490CalibrationSpectrum( spectrum, dimLevel )
            obj.spectrum = spectrum;
            obj.dimLevel = dimLevel;
        end
    end
end