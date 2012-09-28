%author Jan Winter TU Berlin
%email j.winter@tu-berlin.de

classdef OL490TargetSpectrum < handle
    %% properties
    properties
        spectrum                    % 
        dimValue                    % 
        Lv
    end
    methods
        %% constructor
        function obj = OL490TargetSpectrum( spectrum, dimValue, Lv )
            obj.spectrum = spectrum;
            obj.dimValue = dimValue;
            obj.Lv = Lv;
        end
        
    end
end