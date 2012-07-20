function [ real_value ] = spec_adaption( user_spectrum, spectral_percent, io_real )
%spec_adaption generates the wanted spectrum
    ol490_max = 49152;
    ol490_max_down_percent = (ol490_max / 100);
    counter_repeat = 0;
    repeat = 1;
    while repeat == 1
        counter_repeat = counter_repeat + 1;
        %Daten aufbereiten
        for k=1:size(user_spectrum,1)
            user_spectrum_percent(k) = (user_spectrum(k,3) / ol490_max);
            value_one = abs(spectral_percent(1,k)-user_spectrum_percent(k));
            pointer_one = 1;
            for i = 2 : size( spectral_percent, 1 )
                value_two = abs(spectral_percent(i,k)-user_spectrum_percent(k));
                if (value_two < value_one)
                    value_one = value_two;
                    pointer_one = i;
                end
            end

            if ( ( k > 51 ) && (k<size(user_spectrum,1)-256))     % 51 = 400nm & 1024 - 256 = 768 = 680nm 
                if value_one > 0.01
                    repeat = 1;
                    break
                end
            end
            if k == (size(user_spectrum,1)-256)
                repeat = 0;
            end
            holder = (pointer_one - 1)/10;
            value_one = abs(holder - io_real(1,k));
            pointer_two = 1;
            for j=2:size(io_real,1)
                value_two = abs(holder - io_real(j,k));
                if (value_two < value_one)
                    value_one = value_two;
                    pointer_two = j;
                end
            end
            real_value(k) = pointer_two;  
        end


        %evtl Anpassung des Userspektrums
        if repeat == 1
            for k=1:size(user_spectrum,1)
                user_spectrum(k,3) = user_spectrum(k,3) - ol490_max_down_percent;
                if user_spectrum(k,3) < 0
                    user_spectrum(k,3) = 0;
                end  
            end
        else break
        end
        if counter_repeat == 101
            repeat = 0;
        end
    end
end

