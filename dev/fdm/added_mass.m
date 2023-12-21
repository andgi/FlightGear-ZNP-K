%% Coefficients for airship added mass modelling.
%% From
%% [Max M. Munk, "Aerodynamic forces on airship hulls", NACA report 184, 1924]

fitness = [1.00  1.50  2.00  2.51  2.99  3.99  4.99  6.01  6.97  8.01  9.02  9.97  20];
K_axial = [0.500 0.305 0.209 0.156 0.122 0.082 0.059 0.045 0.036 0.029 0.024 0.021 0.00];
K_trans = [0.500 0.621 0.702 0.763 0.803 0.860 0.895 0.918 0.933 0.945 0.954 0.960 1.00];
K_rot   = [0.000 0.094 0.240 0.367 0.465 0.608 0.701 0.764 0.805 0.840 0.865 0.883 1.00];

figure(1)
plot(fitness, K_axial,   "b-o;K_{axial};",
     fitness, K_trans, "r-+;K_{transverse};",
     fitness, K_rot,   "g-x;K_{rotational};");
xlim([1, 14]);
xlabel("Fitness ratio");
%print("added_mass_coefficients", "-dpng");
