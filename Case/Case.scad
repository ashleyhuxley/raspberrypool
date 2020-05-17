box_width = 250;
box_depth = 150;
box_height = 36;
wall = 3;

m25_insert = 3.8;
m3_insert = 4.0;
m5_insert = 6.0;

m25_dia = 3;
m3_dia = 3.4;
m5_dia = 5.4;

inner_width = box_width - (wall * 2);
inner_depth = box_depth - (wall * 2);
inner_height = box_height - wall;

screw_post = 10;

fn = 25;
parts_on = false;

relay_1_pos = [20, 100, 0];
relay_2_pos = [20, 55, 0];
relay_led_offset = [1.96 * 25.4, 0.74 * 25.4,0];

circuit_pos = [136, 75, 0];

module screw_post(size)
{
    post_height = inner_height - wall;

    half = size / 2;
    
    translate([half, half, 0])
    {
        difference()
        {
            union()
            {
                difference()
                {
                    cube([size, size, post_height], center = true);
                    translate([-(half / 2), -(half / 2), 0])
                        cube([half, half, post_height], center=true);
                }
                
                cylinder(d = 10, post_height, center=true, $fn=fn);
            }       

            cylinder(d = m5_dia, inner_height, center = true, $fn = fn);
            translate([0,0,(post_height / 2) - 6.6])
                cylinder(d = m5_insert, 6.6, $fn = fn);        }
    }
}

module standoff(outer_dia, height, insert_dia, insert_height, screw_dia)
{
    difference()
    {
        cylinder(d1 = outer_dia + 5, d2 =  outer_dia, height, $fn = fn);
        cylinder(d = screw_dia, height, $fn = fn);
        translate([0,0,height - insert_height])
            cylinder(d = insert_dia, insert_height, $fn = fn);
    }
}

module quads(x, y)
{
    translate([0,0]) children();
    translate([x,0]) children();
    translate([0,y]) children();
    translate([x,y]) children();
}

module relay()
{
    standoff = 7;
    i = 25.4;
    
    translate([0.3 * i, 0.1 * i, 0])
        quads(2 * i, 1 * i)
            standoff(9.5, standoff, m3_insert, 4, m3_dia);
    
    if (parts_on)
        color([1,0,0])
            translate([0,0,standoff])
                import("relay.stl");
}

module pi()
{
    standoff = 12;
    
    quads(49,58)
    {
        standoff(6.5, standoff, m25_insert, 3.8, m25_dia);
    }
    
    if (parts_on)
        color([1,0,0])
            rotate([0,0,90])
                translate([43.6,-38.6,standoff - 1.4])
                    import("pi4.stl");
}

module clip(width, height, standoff, depth, shelf, overhang)
{
    thickness = 1.7;
    
    a = height - thickness - standoff;
    o = (depth - shelf - 0.5) + overhang;
    A = atan(o / a);
    h = sqrt((a * a) + (o * o)) + 0.1;
    
    translate([-2, 0, 0])
    {
        union() {
            difference()
            {
                cube([depth, width, height]);
                translate([depth - shelf, -0.1, standoff])
                    cube([shelf + 0.1, width + 0.2, thickness]);
                translate([depth - shelf + overhang, 0, standoff + thickness])
                    cube([depth - shelf + overhang, width, height - standoff - thickness]);
                translate([0.5,-0.1,height])
                    rotate([0, 90 - A, 0])
                        cube([h, width + 0.2, h]);
            }

            
            translate([0,(width / 2),0])
                rotate([90,270,0])
                    fillet(1.5, width);
            
            translate([depth / 2,width,0])
                rotate([0,270,0])
                    fillet(1.5, depth);
            
            translate([depth / 2,0,0])
                rotate([180,270,0])
                    fillet(1.5, depth);
        }
    }
}

module fillet(r, h)
{
    translate([r / 2, r / 2, 0])

        difference() {
            cube([r + 0.01, r + 0.01, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true, $fn = fn);

        }
}

module mirror_copy(v = [1, 0, 0]) 
{
    children();
    mirror(v) children();
}

module circuit()
{
    board_clearance = 14.5;
    
    mirror_copy([0,1,0])
        mirror_copy()
            translate([-32.5,-25,0])
                clip(8, board_clearance + 5, board_clearance, 4, 2, 1);
    
    if (parts_on)
    {
        translate([-32.5,-39,board_clearance])
        {
            color([1,0,0])
                import("circuit.stl");
            translate([11.2,12,11])
                color([0,0,1])
                    import("LCD.stl");
        }
    }
    
    translate([-19, -29, 0])
    {
        translate([74.7,     0]) standoff(6.5, board_clearance + 11, m3_insert, 5, m3_dia);
        translate([   0, -31.4]) standoff(6.5, board_clearance + 11, m3_insert, 5, m3_dia);
        translate([74.7, -31.4]) standoff(6.5, board_clearance + 11, m3_insert, 5, m3_dia);
    }
        
}

module box()
{
    difference()
    {
        union()
        {
            translate([0,0,box_height / 2])
            {
                union()
                {
                    difference()
                    {
                        cube([box_width, box_depth, box_height], center=true);
                        
                        translate([0, 0, wall / 2])
                            cube([inner_width, inner_depth, inner_height + 0.1], center=true);
                    }
                    
                    mirror_copy([0,1,0])
                        mirror_copy()
                            translate([inner_width / 2 - screw_post, inner_depth / 2 - screw_post, 0])
                                screw_post(screw_post);
                }
            }
            
            mirror_copy([0,1,0])
                mirror_copy()
                    translate([box_width / 3, (box_depth / 2) + 15, 0])
                        rotate([0,0,180])
                            bracket(15, 15, 5);

            translate([-(inner_width / 2), -(inner_depth / 2), wall])
            {       
                translate(relay_1_pos)
                    relay();
                translate(relay_2_pos)
                    relay();
                
                translate([180, 60])
                    pi();
                
                translate(circuit_pos)
                    circuit();
                
                translate([22, 22, 0])
                {
                    for (x = [0 : 1 : 3])
                    {
                        translate([23.5 * x, 0, 0])
                        {
                            standoff(6, 9, m25_insert, 3.8, m25_dia);
                            if (parts_on)
                                rotate([0,0,90])
                                    translate([0,0,9])
                                        color([1,0,0])
                                            import("terminal.stl");
                        }
                    }
                }
            }
        }
        
        // Cutouts
        translate([-inner_width / 2, -inner_depth / 2, wall])
        {
            // Pi holes
            translate([178, inner_depth - 0.1, 12])
                cube([17, wall + 0.2, 15]);
            translate([inner_width - 0.1, 62, 11])
                cube([wall + 0.2, 11, 7]);
            
            // Mains Wire Holes
            translate([22, 0, 15])
                rotate([90,0,0])
                    for (x = [0 : 1 : 2])
                        translate([23.5 * x, 0, 0])
                            if (x != 2)
                                cylinder(d = 11, wall, $fn = fn);
                            else
                                cylinder(d = 7, wall, $fn = fn);
                            
            // Sensor wire cutout
            translate([150, inner_depth, 15])
            {
                translate([0,wall,0])
                    rotate([90,0,0])
                        cylinder(d = 6, wall, $fn=fn);
                translate([-3, 0, 0])
                    cube([6, wall, 18]);
            }
            
            // Fan
            translate([inner_width-0.1, 30, (inner_height / 2) - 1.5])
            {
                rotate([0,90,0])
                {
                    cylinder(d = 28, wall + 0.2, $fn=fn);
                    mirror_copy()
                        mirror_copy([0,1,0])
                            translate([12, 12, 0])
                                cylinder(d = m25_dia, wall + 0.2, $fn=fn);
                }
            }
            
            // Vent holes
            translate([25, inner_depth - 0.1, 10])
            {
                for (x = [0:1:10])
                {
                    translate([x * 8, 0, 0])
                    {
                        translate([1.5,wall+0.2,0])
                            rotate([90,0,0])
                                cylinder(d=3, wall + 0.2, $fn=fn);
                        translate([1.5,wall+0.2,18])
                            rotate([90,0,0])
                                cylinder(d=3, wall + 0.2, $fn=fn);
                        cube([3, wall + 0.2, 18]);
                    }
                }
            }
        }
    }
}

module relay_text(txt)
{
    relief = 0.5;
    
    translate([0, 8, (wall * 2) - relief])
    {
        difference()
        {
            cube([60, 20, relief]);
            translate ([3,5,0])
                linear_extrude(1, center = true, convexity = 4)
                    text(txt, 10, valign = "bottom", halign = "left");
        }
    }
}

module lid()
{   
    difference()
    {
        union()
        {
            translate([0,0,(wall/2)])
            {
                cube([inner_width - 0.5, inner_depth - 0.5, wall], center=true);
                translate([0,0,wall])
                    cube([box_width, box_depth, wall], center=true);
            }
        }
        
        
        translate([-(inner_width / 2), -(inner_depth / 2), 0])
        { 
            // LED Holes
            translate(relay_1_pos)
                translate(relay_led_offset)
                    cylinder(d1 = 5, d2 = 8, wall * 2, $fn = fn);
            translate(relay_2_pos)
                translate(relay_led_offset)
                    cylinder(d1 = 5, d2 = 8, wall * 2, $fn = fn);
            
            // Relays Text
            translate(relay_1_pos)
                relay_text("PUMP");
            
            translate(relay_2_pos)
                relay_text("HEAT");
            
            translate(circuit_pos)
                translate([-17.5,-58.8,-0.1])
                    cube([73, 27.5, wall * 2 + 0.2]);
        }
        
        lid_text();
        
        // Screw holes
        mirror_copy([0,1,0])
            mirror_copy()
                translate([inner_width / 2 - screw_post, inner_depth / 2 - screw_post, 0])
                    translate([screw_post /  2, screw_post / 2, 0])
                        cylinder(d = m5_dia, wall * 2, $fn=fn);
    }
}

module lid_text()
{
    relief = 1;
    
    translate([40, 26, (wall * 2) - relief / 2])
    {
        difference()
        {
            cube([120, 60, relief], center = true);
            linear_extrude(1, center = true, convexity = 4)
            {
                translate ([-50,10,0])
                    text("Raspberry", 15, valign = "center", halign = "left");
                translate ([-50,-10,0])
                    text("Pool", 15, valign = "center", halign = "left");
            }
        }
    }
}

module bracket(width, depth, thickness)
{
    difference()
    {
        union()
        {
            cube([width, depth, thickness]);
            translate([width / 2, 0, 0])
                cylinder(d = width, thickness, $fn=fn);
            translate([width / 2, depth, thickness])
                rotate([0,270,0])
                    rotate([180,0,0])
                        fillet(3, width);
        }
        
        translate([width / 2, 0, 0])
        {
            cylinder(d = 5, thickness, $fn=fn);
            translate([0,0,2])
            {
                cylinder(d1 = 5, d2 = 10, thickness - 2, $fn=fn);
            }
        }
    }
}

box();

translate([0,0,35]) lid();
