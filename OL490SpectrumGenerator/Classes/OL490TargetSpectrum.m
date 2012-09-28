%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490TargetSpectrum < handle
    %% properties
    properties
        ol490Spectrum                    % 
        dimValue                    % 
        Lv
    end
    methods
        %% constructor
        function obj = OL490TargetSpectrum( ol490Spectrum, dimValue, Lv )
            obj.ol490Spectrum = ol490Spectrum;
            obj.dimValue = dimValue;
            obj.Lv = Lv;
        end
        
    end
end