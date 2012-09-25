function [ io_real ] = io_real_gen( spectral_data )
%io_real_gen generates a input-output-function for the spectral data 
 for k=1:size(spectral_data,1)                                                                   
    for l=1:size(spectral_data,2)
        io_real(k,l) = spectral_data(k,l) / ( spectral_data(size(spectral_data,1),l) / 100 );       
    end
end
end