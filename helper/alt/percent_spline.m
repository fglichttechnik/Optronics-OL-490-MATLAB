function [ splined_data ] = percent_spline( spectral_data, percent_vector, resolution)
%percent_spline makes a cubic spline for the percent rows
for k=1:size(spectral_data,2)
    splined_data(:,k) = spline(percent_vector,spectral_data(:,k),resolution);
end
end