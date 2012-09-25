%%calc photopic luminance
function Lv_photopic = calcPhotopicLuminanceFromSpectrum( spectralRadianceData )
load 'V_CIE.mat'  %load V_strich and lambda_CIE
lambda_i = linspace( 380, 780, 1024 );
V_i = interp1( lambda_CIE, V, lambda_i );
Lv_photopic = 683 * sum( V_i .* spectralRadianceData );
end