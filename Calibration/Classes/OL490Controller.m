classdef OL490Controller < handle

properties
	ol490Index 	% the index of the ol490, 0 or 1
end

methods
	%% constructor
	function obj = OL490Controller( ol490Index )
		obj.ol490Index = ol490Index;
	end
	
	%% init connection
	function obj = init( obj )
		%% TODO: implement this, init connection to OL490
	end
	
	%% send a spectrum
	function obj = sendSpectrum( obj, spectrum )
		%% TODO: implement this, send certain spectrum
	end
end

end