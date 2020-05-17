difference()
{
    mirror_copy([0,1,0])
    {
        mirror_copy()
        {
            cube([3,2,10]);
            translate([0,1.5,0])
                cube([11.5, 8, 10]);
            translate([5,6,10])
            {
                difference()
                {
                    cylinder(d1 = 7, d2=6, 9, $fn=18);
                    translate([0,0,5])
                        cylinder(d = 5, 4, $fn=18);
                }
            }
        }
    }
    
    cylinder(d = 2, 10, $fn=18);
}


module mirror_copy(v = [1, 0, 0]) 
{
    children();
    mirror(v) children();
}