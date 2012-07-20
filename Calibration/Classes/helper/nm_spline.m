function [ splined_data ] = nm_spline( spectral_data )
%nm_spline makes a cubic spline adaption over 1024 steps because of ol490
lamda_res = size(spectral_data,2) / 1023;
lamda_vector = 0:(size(spectral_data,2)-1);
spline_lamda = 0:lamda_res:size(spectral_data,2);
for k=1:size(spectral_data,1)
    splined_data(k,:) = spline(lamda_vector,spectral_data(k,:),spline_lamda);
end
end