fn = 20;

mirror([0,1,0])
{
    difference()
    {
        union()
        {
            cube([80, 36, 1.6]);
            translate([4.8,6.5,1.6])
                cube([71.3, 24.2, 7]);
            
            translate([7.8, 2, -9])
            {
                for(x = [0 : 0.1 : 1.6])
                {
                    translate([x * 25.4, 0, 0])
                    {
                        translate([-0.3, -0.3, 0])
                            cube([0.6, 0.6, 9]);
                        
                        translate([-1.25, -1.25, 6.5])
                            cube([2.5, 2.5, 2.5]);
                    }
                }
            }
        }
        
        translate([2.5, 2.5, 0])
            cylinder(d = 3.2, 1.6, $fn = fn);
        translate([2.5, 33.5, 0])
            cylinder(d = 3.2, 1.6, $fn = fn);
        translate([77.5, 2.5, 0])
            cylinder(d = 3.2, 1.6, $fn = fn);
        translate([77.5, 33.5, 0])
            cylinder(d = 3.2, 1.6, $fn = fn);
    }
}