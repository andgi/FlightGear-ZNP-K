function AC3Denvelope (filename = "test.ac")
% K-Ship shape (K-3 to K-13) according to the spec.
% K-14 had a 39" cylindrical panel added at the maximum section (at 98.4 ft).
% Unit FT.

  env = ZNPKenvelope();

  Xm = env(:,1);
  Ym = env(:,2);

  % Create AC3D file.
  fid = fopen (filename, "w");

  fprintf(fid, "AC3Db\n");
  fprintf(fid, "MATERIAL \"Envelope\" rgb 0.7 0.7 0.7 amb 0.7 0.7 0.7 emis 0 0 0 spec 0.02 0.02 0.02 shi 32 trans 0\n");
  fprintf(fid, "OBJECT world\n");
  fprintf(fid, "kids 1\n");
  fprintf(fid, "OBJECT poly\n");
  fprintf(fid, "name \"Envelope_contour\"\n");
  fprintf(fid, "data 10\n");
  fprintf(fid, "contour\n");
  fprintf(fid, "crease 30.000000\n");
  fprintf(fid, "numvert %d\n", length(Xm));

  for i = 1:length(Xm)
    fprintf(fid, "%f %f %f\n", Xm(i), Ym(i), 0.0);
  endfor

  fprintf(fid, "numsurf %d\n", length(Xm) - 1);
  for i = 0:length(Xm) - 2
    fprintf(fid, "SURF 0x02\n");
    fprintf(fid, "mat 0\n");
    fprintf(fid, "refs 2\n");
    fprintf(fid, "%d 0 0\n", i);
    fprintf(fid, "%d 0 0\n", i + 1);
  endfor
  fprintf(fid, "kids 0\n");

  fclose (fid);
endfunction
