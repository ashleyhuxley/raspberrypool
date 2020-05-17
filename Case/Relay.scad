h = 0.6;
i = 25.4;

fn = 20;

w = 2.45 * i;
d = 1.2 * i;


difference()
{
    minkowski()
    {
        cube([w, d, h]);
        cylinder(d = 0.1 * i, h, $fn = fn);
    }
    
    translate([0.3 * i, 0.1 * i, 0])
        quads(2 * i, 1 * i)
            cylinder(0.1 * i, h, $fn = fn);
}

translate ([1.96 * i,0.74 * i,h + 24])
{
    translate([-1,0,-24]) cylinder(d = 0.2, 24);
    translate([1,0,-24]) cylinder(d = 0.2, 24);
    cylinder(d = 6, 1, $fn = fn);
    cylinder(d = 5, 5, $fn = fn);
}

translate([0.5 *i,0.1 * i,h])
{
    scale([i,i,1])
    linear_extrude(20)
    {
        polygon([[0,0], [0,1.1], [0.54,1.09], [0.54, 0.9], [1.3,0.9], [1.3,0.1], [0.7, 0.1], [0.7,0], [0,0]]);
    }
}

module quads(x, y)
{
    translate([0,0]) children();
    translate([x,0]) children();
    translate([0,y]) children();
    translate([x,y]) children();
}