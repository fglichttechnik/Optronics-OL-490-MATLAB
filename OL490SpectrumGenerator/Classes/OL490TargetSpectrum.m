% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



classdef OL490TargetSpectrum < handle
    %% properties
    properties
        spectrum                    % the actual spectrum to send to the OL490
        dimValue                    % the dimValue resulting from Lv and the maximum possible luminance
        Lv 							% the desired luminance of the spectrum
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