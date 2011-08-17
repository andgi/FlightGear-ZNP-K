###############################################################################
##
## Goodyear K-type airship for FlightGear.
## Walk view configuration.
##
##  Copyright (C) 2011  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##
###############################################################################

# Constraints
var carConstraint =
    walkview.makeUnionConstraint(
        [
         walkview.makePolylinePath
             ([ [27.65, 0.00, -12.25],
                [29.05, 0.00, -12.25] ],
              0.30),
         walkview.makePolylinePath
             ([ [29.05, 0.00, -12.25],
                [37.00, 0.00, -12.25] ],
              1.30),
         walkview.makePolylinePath
             ([ [37.00, 0.00, -12.25],
                [37.30, 0.00, -12.25] ],
              1.0, 1)
        ]);

# The view manager.
var walker = walkview.Walker.new("Rigger View", carConstraint);

