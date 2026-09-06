

function [sout,zout,eout,nout,dout] = getSprofileInterp(sin,zin,ein,nin,din)

diffs = diff(sin); % difference between adjacent s readings
dsmin = abs(min(diffs)); % get minimum difference
diffnorm = diffs./dsmin; % normalize all with min difference
diffnorm_filt = diffnorm(diffnorm < 1.10); % disregard higher ones assuming they are multiples and nothing more than 10% deviates in real ds
ds = mean(diffnorm_filt);

sout = min(sin):ds:max(sin);
zout = interp1(sin,zin,sout);
eout = interp1(sin,ein,sout);
nout = interp1(sin,nin,sout);
dout = interp1(sin,din,sout);

end