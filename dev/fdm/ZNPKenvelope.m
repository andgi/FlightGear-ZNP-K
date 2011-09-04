function res = ZNPKenvelope
% K-Ship shape (K-3 to K-13) according to the spec.
% K-14 had a 39" cylindrical panel added at the maximum section (at 98.4 ft).
% Unit FT.

  ft2m = 0.3048;

  R = 57.85/2;
  L = 246.0;
  Xmax = 98.4;

  a = L/2;
  Xm = [0:0.1:2 2.5:0.5:72.5 73:0.1:(L.*ft2m)];
  X  = Xm./ft2m;
  x  = X - Xmax;

  Y  = R.*(1 - (x./a - 1/5).^2).^0.5 .* (1.02062 - 0.21263 .* x./a);
  Ym = Y.*ft2m;

  %plot(Xm, Y.*ft2m);
  
  % Offset the contour by 0.4m
  Xm = Xm + 0.4;

  % Extend the envelop rear of 30.40m with 1.00m
  % making it a K-14 and later envelope.
  Xm = Xm + 10*min(0.1, max(0,Xm-30.40));

  res = [Xm' Ym'];
endfunction
