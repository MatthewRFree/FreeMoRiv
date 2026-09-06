function zrec = getWtHPF(z,ds,Lthresh)

[wt,f] = cwt(z,1/ds);
zrec = icwt(wt, 'Morse', f, [max((1/Lthresh),min(f)), max(f)]);

end

