function [ max_percent_adaption ] = spectral_percent( spectral_data)
%spectral_percent gives a percent
%   Detailed explanation goes here
spectral_max = max(max(spectral_data));
for k=1:size(spectral_data,1)
    for i=1:size(spectral_data,2)
        max_percent_adaption(k,i) = spectral_data(k,i) / spectral_max ;
    end
end
end