function [cohall, cohbootall] = calcwpli(hilbdata,chann1,chann2)

conjprod = hilbdata(:,chann1,:,:) .* conj(hilbdata(:,chann2,:,:));

cohall = squeeze( abs(mean(imag(conjprod),4)) ./ mean(abs(imag(conjprod)),4) );
cohbootall = [];

end