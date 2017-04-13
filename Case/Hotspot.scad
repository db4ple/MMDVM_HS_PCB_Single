// the rounded cube module comes from
// https://gist.github.com/groovenectar/92174cb1c98c1089347e

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

// end roundedcube contribution


// actual case starts here
// $fn=100;
tol = 0.3;
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
box_h=30 + 2* tol;
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
// assembly();

// translate([(pcb_l-2*tol)/2+tol,(box_h-2*tol)/2+tol,-4.7]) rotate ([90,0,0]) assembly_base();


// This part of the file is a slightly modified version of
// http://www.thingiverse.com/thing:1549028/#files
// Thanks for licensing the design under CC-A 
//Pi Zero parametric box design with camera support
//R.J.Tidey 17th May 2016

// General parameters
//build 1=base, 2=lid, 3=both
build = 2;
//camera 0=none, 1=internal, 2=external
camera = 2;
//GPIO 0=no cut_out, 1=top cut_out, 2 side cut out
gpio = 1;
wall = 1.6;
hdmi_recess = 1;
corner = 3.0;
ecorner = 2.0;
tol = 0.3;
$fn=20;


//Base parameters
//inner dimensions
base_width = 30;
//65 for original pizero with no camera connector
//67 for pizero with camera connector
//70  to give more radius for bending cable back internally
base_length = camera==2 ? 90.84 - 2*tol : 67.0;
hole2hole_l = 58;
hole2hole_w = 23;

hdmi_recess_w = 17.5;
hdmi_recess_h = 3.75;

support_offset = 3.5;
support_height = 1.0;
support_radius = 1.4;
support_size = 7.0;
usbpower_offset = 54.0;
usbusb_offset = 41.4;
usb_length = 9.25;
hdmi_offset = 12.4;
hdmi_length = 13.75;
cutout_height_offset = 1.0;
sd_offset = 16.7;
sd_width = 13.0;

//Lid parameters
//1.5 for no camera shallow
//6 for camera
lid_height = camera==1 ? 6.0 : 1.5;
board_thick = 1.35;
connector_thick = 3.2;
screw_depth = 8.0;
screw_radius = 1.3;
gpio_centre_x = 32.5;
gpio_centre_y = 3.5;
gpio_length = 51.5;
gpio_width = 6;
gpio_recess_h = 1.2;
corner_size = 2.4;

//Camera parameters,
camera_hole = 10;
camera_x = 20.0;
camera_screw_centre_offset = 0.0;
camera_screw_x = 12.5;
camera_screw_y = 21.0;
camera_screw_r = 1.5;
camera_cable_y = 20.0;
camera_cable_h = 1.0;

//calculate required base_height
base_height = support_height + board_thick + connector_thick + tol;
echo("base_height = ",base_height);
echo("base_length = ",base_length);
echo("lid_height = ",lid_height);

module round_cube(start,length,width,height,z_offset,cor) {
    hull() {
        translate([start,start,z_offset])
            cylinder(height+wall,r=cor);
        translate([start+length,start,z_offset])
            cylinder(height+wall,r=cor);
        translate([start+length,start+width,z_offset])
            cylinder(height+wall,r=cor);
        translate([start,start+width,z_offset])
            cylinder(height+wall,r=cor);
    }
}

module screwhole() {
    cylinder(wall+support_height+tol,r=support_radius);
    cylinder(wall*0.75,2*support_radius,support_radius);
}

module corner_support() {
    difference() {
        union() {
            round_cube(corner-2*tol,corner_size,corner_size,lid_height,0,corner);
            translate([support_offset,support_offset,wall-0.1])
                cylinder(lid_height+connector_thick+0.1,4,3);
        }
        translate([support_offset,support_offset,wall+lid_height+connector_thick-screw_depth])
            cylinder(screw_depth+1,r=screw_radius);
    }
}

module cut_outs(height) {
    translate([tol+hdmi_offset-0.5*hdmi_length,-wall-0.1,height])
        cube([hdmi_length, wall+ 1.0,base_height]);
    translate([tol+usbusb_offset-0.5*usb_length,-wall-0.1,height])
        cube([usb_length, wall+ 1.0,base_height]);
    translate([tol+usbpower_offset-0.5*usb_length,-wall-0.1,height])
        cube([usb_length, wall+ 1.0,base_height]);
    translate([-wall-0.1,tol+sd_offset-0.5*sd_width,height])
        cube([wall+ 1.0,sd_width,base_height]);
    if(hdmi_recess==1) {
        translate([tol+hdmi_offset-0.5*hdmi_recess_w,-wall-0.1,wall])
            cube([hdmi_recess_w, wall+ 0.1,base_height]);
    }
    if(camera==2) {
        translate([base_length - 2* wall,tol+0.5*(base_width-camera_cable_y),height])
            cube([4*wall,camera_cable_y,camera_cable_h]);
    }
    if(gpio==2) {
        translate([tol + gpio_centre_x - gpio_length*0.5,tol+base_width-wall,height])
            cube([gpio_length,4*wall,base_height]);
    }
}

module base_shell() {
    difference() {
        round_cube(ecorner-wall,base_length+2*tol+2*wall-2*ecorner,base_width+2*tol+2*wall-2*ecorner,base_height,0,ecorner);
        round_cube(corner-tol,base_length+4*tol-2*corner,base_width+4*tol-2*corner,base_height,wall,corner);
    }
    translate([-tol,-tol,0])
        cube([support_size,support_size,support_height+wall]);
    translate([hole2hole_l+tol,-tol,0])
        cube([support_size,support_size,support_height+wall]);
    translate([hole2hole_l+tol,hole2hole_w+tol,0])
        cube([support_size,support_size+2*tol,support_height+wall]);
    translate([-tol,hole2hole_w+tol,0])
        cube([support_size,support_size+2*tol,support_height+wall]);
 }

module base() {
    difference() {
        base_shell();
        translate([tol+support_offset,tol+support_offset,-0.1]) screwhole();
        translate([tol+support_offset+hole2hole_l,tol+support_offset,-0.1]) screwhole();
        translate([tol+support_offset+hole2hole_l,tol+support_offset+hole2hole_w,-0.1]) screwhole();
        translate([tol+support_offset,tol+support_offset+hole2hole_w,-0.1]) screwhole();
        cut_outs(wall+support_height+board_thick-tol);
    }
}


module lid_shell() {
    difference() {
        union () {
        translate([(pcb_l-2*tol)/2+tol,(box_h-2*tol)/2+tol,-3.7]) rotate ([90,0,0]) assembly_base();
        round_cube(corner-wall,base_length+2*tol+2*wall-2*corner,base_width+2*tol+2*wall-2*corner,lid_height,0,corner);
        }
        round_cube(corner-tol,base_length+4*tol-2*corner,base_width+4*tol-2*corner,lid_height,wall,corner);
        if(gpio==1) {
            translate([tol+gpio_centre_x-0.5*gpio_length,tol+gpio_centre_y-0.5*gpio_width,-10.5])
                cube([gpio_length,gpio_width,wall+50.0]);
        }
        if(camera==1) {
            translate([tol+camera_x,tol+0.5*(base_width-camera_hole),-0.5])
                cube([camera_hole,camera_hole,wall+1.0]);
            translate([tol+camera_x+0.5*camera_hole+camera_screw_centre_offset,tol+0.5*base_width,-0.5]){
                translate([0,-0.5*camera_screw_y,0]) cylinder(wall+1.0,camera_screw_r,camera_screw_r);
                translate([0,0.5*camera_screw_y,0]) cylinder(wall+1.0,camera_screw_r,camera_screw_r);
                translate([-camera_screw_x,-0.5*camera_screw_y,0]) cylinder(wall+1.0,camera_screw_r,camera_screw_r);
                translate([-camera_screw_x,0.5*camera_screw_y,0]) cylinder(wall+1.0,camera_screw_r,camera_screw_r);
            }
        }
    }
}

module lid() {
    difference() {
        union() {
            lid_shell();
            translate([0,0,0]) corner_support();
            translate([hole2hole_l,0,0]) corner_support();
            translate([hole2hole_l,hole2hole_w,0]) corner_support();
            translate([0,hole2hole_w,0]) corner_support();
        }
        if(hdmi_recess==1) {
            translate([tol+hdmi_offset-0.5*hdmi_recess_w,base_width+tol+0.1,lid_height+wall-hdmi_recess_h])
                cube([hdmi_recess_w, 2*wall,hdmi_recess_h+1]);
        }
        if(gpio==2) {
            translate([tol + gpio_centre_x - gpio_length*0.5,-wall,lid_height+wall-gpio_recess_h])
                cube([gpio_length,4*wall,gpio_recess_h+1]);
        }
    }
}

if (build == 1 || build == 3) {
    base();
}
if (build == 3) {
    translate([0,base_width+4*wall,0]) lid();
}
if(build == 2){
    lid();
}