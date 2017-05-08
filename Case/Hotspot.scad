// the rounded cube module comes from
// https://gist.github.com/groovenectar/92174cb1c98c1089347e

$fs = 0.15;


module roundcylinder(d=1,h=10)
{
    translate([0,0,d/2])
    hull()
    {
    sphere(d=d);
    
    translate([0,0,h-d]) sphere(d=d);
    }
}

module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							sphere(r = radius);
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							rotate(a = rotate)
							cylinder(h = diameter, r = radius, center = true);
						}
					}
				}
			}
		}
	}
}

// end roundedcube contribution


// actual case starts here
// $fn=100;

rpizw_pcb_h = 1.4;
rpizw_pcb_w = 65;
rpizw_pcb_l = 30;

usbpower_offset = 54.0;
usbusb_offset = 41.4;
usb_length = 8.0;
usb_h = 3.0;

hdmi_offset = 12.4;
hdmi_length = 12.0;
hdmi_h = 3.4;




tol = 0.3;
pcb_h = 1.6;
pcb_t = 5;
pcb_w = 48.260;
//pcb_l = 87.860;
pcb_l = 90.86;

stm_h = 11.35;
stm_w = 22.860;
stm_l = 53.430;

stm_usb_w = 14;
stm_usb_h = 9;    
rf_w = 27;    

wall = 1.6;
box_h=30 + 2* tol;
down=-13.5;

extend_h = 32;


module holder()
{
    dia = 2;
    translate([pcb_l,0,-dia/2-0.4]) rotate([270,0,0]) cylinder(d=2,h=pcb_w + wall);
    translate([0,0,-dia/2-0.4]) rotate([270,0,0]) cylinder(d=2,h=pcb_w + wall);
    
    translate([pcb_l,0,dia/2+pcb_h]) rotate([270,0,0]) cylinder(d=2,h=pcb_w + wall);
    translate([0,0,dia/2+pcb_h]) rotate([270,0,0]) cylinder(d=2,h=pcb_w + wall);

}
module pcb()
{
    cube([pcb_l,pcb_w,pcb_h]);
}
module rf7021()
{
    rf_pcb_h = 1;
    ant_dia = 7;
    sma_pin_dia = 1.25;
    translate([-rf_w/2,0,0])cube([rf_w,pcb_w,rf_pcb_h]);
    translate([0,35,rf_pcb_h+sma_pin_dia/2]) rotate([270,0,0]) cylinder(d=ant_dia,h=30);
}

module stm()
{
    cube([stm_l,stm_w,stm_h]);
    translate([stm_l-2,(stm_w-stm_usb_w)/2 ,stm_h-stm_usb_h/2+2.5]) cube([20,stm_usb_w,stm_usb_h]);   
}

module hotspot()
{
    pcb();
    translate([12.7+1,0,pcb_h+10.6])rf7021();
    translate([pcb_l - stm_l,(pcb_w-stm_w)/2,pcb_h]) stm();
}




//translate([-wall,-wall,-wall]) cube([pcb_l+2*wall,pcb_w+2*wall,box_h+wall]);
// hotspot();
// rf7021();
// stm();

module assembly()
{

    translate([-pcb_l/2,-pcb_w/2+wall/2+extend_h/2,down]) 
    {
           // hotspot();    

        holder();
    }

    difference()
    {
        color("Orange")
        translate([0,wall,0]) roundedcube([pcb_l+2*wall, pcb_w+wall+extend_h, box_h+2*wall], true, 2, "y");
   
        {
        roundedcube([pcb_l, pcb_w+wall+extend_h, box_h], true, 2, "y");
        translate([-pcb_l/2,-pcb_w/2+extend_h/2+wall/2,down]) 
        {
            hotspot();    
        }
        
    //    translate([0,-10,0]) cube([pcb_l-2,pcb_w+10,box_h-wall]);
        }
    }
}


module assembly_base()
{
    base_h = 3.6;
    color("Orange")
    // translate([0,-wall/2,0]) roundedcube([pcb_l+2*wall, wall, box_h+2*wall], true, 2, "y");    
    difference() {
    translate([0,base_h/2,0]) roundedcube([pcb_l-2*tol, base_h, box_h-2*tol], true, 2, "y");
    translate([0,base_h/2,0]) roundedcube([pcb_l-wall-2*tol, base_h+5, box_h-wall-2*tol], true, 2, "y");
    }
}

// translate([(pcb_l-2*tol)/2+tol,(box_h-2*tol)/2+tol,-4.7]) rotate ([90,0,0]) assembly_base();



module pizw()
{

    difference()
    {
        cube([30,65,rpizw_pcb_h]);
        translate([0,0,-0.1])
        {    
            translate([3.5,3.5]) cylinder(d=2.75,h=4);
            translate([rpizw_pcb_l-3.5,3.5]) cylinder(d=2.75,h=4);
            translate([rpizw_pcb_l-3.5,rpizw_pcb_w-3.5]) cylinder(d=2.75,h=4);
            translate([3.5,rpizw_pcb_w-3.5]) cylinder(d=2.75,h=4);
        }
    }
translate([-3,rpizw_pcb_w-usbusb_offset-usb_length/2-tol,rpizw_pcb_h-0.2]) cube([10,usb_length+2*tol,usb_h+2*tol]);
translate([-3,rpizw_pcb_w-usbpower_offset-usb_length/2-tol,rpizw_pcb_h-0.2]) cube([10,usb_length+2*tol,usb_h+2*tol]);
translate([-3,rpizw_pcb_w-hdmi_offset-hdmi_length/2,rpizw_pcb_h-0.2]) cube([10,hdmi_length,hdmi_h+2*tol]);
}

module pizw_holder()
{
    dia = 2;
    translate([-rpizw_pcb_w/2,0,-30/2])
    {
        translate([0,-dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=rpizw_pcb_w);
        translate([0,rpizw_pcb_h+dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=rpizw_pcb_w);
    }
    translate([-rpizw_pcb_w/2,0,30/2])
    {
        translate([0,-dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=19);
        translate([36,-dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=29);
        // translate([21,rpizw_pcb_h+dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=5);
        translate([rpizw_pcb_w-5,rpizw_pcb_h+dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=5);
        translate([0,rpizw_pcb_h+dia/2],0) rotate([90,0,90]) roundcylinder(d=dia,h=5);
    }
    
    // translate([pcb_l,0,dia/2+pcb_h]) rotate([270,0,0]) cylinder(d=2,h=pcb_w + wall);
    // translate([0,0,dia/2+pcb_h]) rotate([270,0,0]) cylinder(d=2,h=pcb_w + wall);

}


module all()
{
    rpizw_down = 2;
    difference()
    {
        union()
        {
            assembly();
            translate([0,-box_h-rpizw_down,0])    pizw_holder();
        }
    translate([0,-box_h-rpizw_down,0])
    {
        translate([rpizw_pcb_w/2,0,rpizw_pcb_l/2])rotate([0,90,90]) color("red") pizw();
    }
}

}


difference()
{
    all();
//    translate([-50,-23,-60])cube([100,200,100]);
}

// pizw();