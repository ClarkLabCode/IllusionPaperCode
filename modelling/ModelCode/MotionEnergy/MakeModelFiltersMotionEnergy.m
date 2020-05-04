function [ f ] = MakeModelFiltersMotionEnergy( p )

%% Truncate temporal vector to positive times

t = p.t;
t = t(t>=0);
f.t = t;

%% Define temporal filters
% Note that these filters have unit L2 norm

% Second order exponential lowpass and its derivative
f.lp = sqrt(p.dt) .* 2 .* (p.tauLp^(-3/2)) .* double(t>=0) .* t .* exp(-t/p.tauLp);
f.hp = sqrt(p.dt) .* 2 .* (p.tauHp^(-3/2)) .* double(t>=0) .* (p.tauHp - t) .* exp(-t/p.tauHp);
f.hp = f.hp + f.lp*0.2; % introducing DC components into hp


%% Define spatial filters

% Convert FWHM to STD
sBlur = p.fwhmBlur / (2*sqrt(2*log(2)));

% Compute spatial filter
% Note that this filter has unit L1 norm
envelopeFilt  = exp(-(p.x - p.xExtent/2).^2/(2*sBlur^2)) / sqrt(2 * pi * sBlur^2) * p.dx;
f.spatialFilterOdd  = envelopeFilt .* sin((p.x - p.xExtent/2) * 2 * pi / p.lambda);
f.spatialFilterEven = envelopeFilt .* cos((p.x - p.xExtent/2) * 2 * pi / p.lambda);

% force unit L1 norm (is this necessary?)
f.spatialFilterOdd   =  f.spatialFilterOdd / norm(f.spatialFilterOdd,1);
f.spatialFilterEven  =  f.spatialFilterEven / norm(f.spatialFilterEven,1);
% 

end