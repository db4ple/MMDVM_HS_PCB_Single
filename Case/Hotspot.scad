$fs = 0.15;

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

// $fn=100;
pcb_h = 1.6;
pcb_t = 5;
pcb_w = 48.260;
//pcb_l = 87.860;
pcb_l = 90.86;

stm_h = 11.35;
stm_w = 22.860;
stm_l = 53.430;

usb_w = 14;
usb_h = 9;    
rf_w = 27;    

wall = 1.6;
box_h=30;
down=-13.5;

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
    translate([stm_l-2,(stm_w-usb_w)/2 ,stm_h-usb_h/2+2.5]) cube([20,usb_w,usb_h]);   
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
extend_h = 5;

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
    roundedcube([pcb_l, pcb_w+wall/2+extend_h, box_h], true, 2, "y");
    translate([-pcb_l/2,-pcb_w/2+extend_h/2,down]) 
    {
        hotspot();    
    }
        
    //    translate([0,-10,0]) cube([pcb_l-2,pcb_w+10,box_h-wall]);
    }
}
}


assembly();