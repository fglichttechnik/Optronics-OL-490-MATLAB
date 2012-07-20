%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490CalibrationSpectrum < handle
    %% properties
    properties
        spectrum	% handle to OL490
        dimLevel	% dimLevel
    end
    methods
        %% constructor
        function obj = OL490CalibrationSpectrum( spectrum, dimLevel )
            obj.spectrum = spectrum;
            obj.dimLevel = dimLevel;
        end
    end
end