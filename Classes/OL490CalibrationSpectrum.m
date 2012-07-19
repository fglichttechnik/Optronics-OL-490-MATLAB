%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490CalibrationSpectrum < handle
    %% properties
    properties
        spectrum	% handle to OL490
        dimValue	% number of repetitions per light level
    end
    methods
        %% constructor
        function obj = OL490Calibration( spectrum, dimValue )
            obj.spectrum = spectrum;
            obj.dimValue = dimValue;
        end
    end
end