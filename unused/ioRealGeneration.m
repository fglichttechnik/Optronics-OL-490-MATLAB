function [ ioReal ] = ioRealGeneration( data )
%ioRealGeneration generates a input-output-function for the spectral data 
for nmCounter = 1 : size( data, 2 )
    ioReal( :, nmCounter ) = data( :, nmCounter) ./ data (1001, nmCounter );
end
end
