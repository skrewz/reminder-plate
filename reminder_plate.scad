// skrewz@20180811: a date/month display with a slot for labels
//
// Intention is to use as "due date reminders". I.e. something you set to
// remind you about something needing to be done at least by that date.

// Control which part is being rendered:
render_part="explosion_view";

// Dimensions as while lying down
plate_width=60;
plate_depth=70;
// Total thickness
plate_thickness=3;


base_colour="white";
contrast_colour="black";

font_padding_factor = 0.6;
date_font_height=plate_width/14;
date_font="DejaVu Sans Mono:style=Bold";
month_font_height=plate_width/14;
month_font="DejaVu Sans Mono:style=Bold";
description_font_height=plate_width/14;
description_font="DejaVu Sans Mono:style=Bold";

// Dymo labels are 12mm wide:
label_slot_height = 15;


month_labels=["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
date_labels=["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"];
description_labels=["This is to ", "be done at", "least by:"];

////////////////////////////////////////////////////////
//            less-tinkerable parameters:             //
////////////////////////////////////////////////////////

peg_diam=5;
peg_diam_extra_clearance=1.2; // added as radius

label_margin=3;
layer_thickness=plate_thickness/5;
wheel_thickness=1.5*layer_thickness;

peg_height=layer_thickness;
peg_height_holeside_factor=1.5;

// for tack that attaches under bottom_plate to e.g. a wall
tack_diam=peg_diam;
tack_hole_height=2*layer_thickness;

font_height_proportion=0.4; // how much of a font module is font height vs base height

////////////////////////////////////////////////////////
//            derived, tinker with caution:           //
////////////////////////////////////////////////////////
datewheel_diam=plate_width+2;
datewheel_extra_clearance=1; // radius application
monthwheel_extra_clearance=1; // radius application

echo ("datewheel_diam:",datewheel_diam,
    "> plate_width:", plate_width,
    "> monthwheel_spacing_outer_diam:", monthwheel_spacing_outer_diam,
    "> monthwheel_spacing_inner_diam:", monthwheel_spacing_inner_diam,
    "> monthwheel_diam:", monthwheel_diam
    );

_p_i = plate_width/10;
peg_pos = [
  [_p_i,_p_i,0],
  [plate_width-_p_i,_p_i,0],
  [_p_i,plate_depth-_p_i,0],
  [plate_width-_p_i,plate_depth-_p_i,0],
];
// Merely reuse these; tend to sit the right places:
tack_pos = peg_pos;

base_plate_height=3*layer_thickness;

monthwheel_spacing_outer_diam=datewheel_diam-month_font_height*4;
monthwheel_spacing_inner_diam=monthwheel_spacing_outer_diam-plate_width/10;

monthwheel_diam=monthwheel_spacing_inner_diam-2*monthwheel_extra_clearance;
monthwheel_grip_diam=monthwheel_diam/3;

module base_plate()
{
  // the plate that mounts onto things
  // Expectedly printed lying flat (mount side on build surface)
  //
  // (Has contours for wheels and top_plate mount mechanisms)

  color(base_colour) {
    difference() {
      cube ([plate_width,plate_depth,base_plate_height]);
      union()
      {
        translate([plate_width/2,datewheel_diam/2+2*datewheel_extra_clearance,layer_thickness])
          cylinder(r=datewheel_diam/2+datewheel_extra_clearance,h=plate_thickness,$fa=5);
        // Place tack holes:
        translate([0,0,-0.01*layer_thickness])
          for (pos = tack_pos) {
            translate(pos)
              cylinder(r=tack_diam/2,h=tack_hole_height,$fs=0.5);
          }
      }
    }
    // Place pegs:
    translate([0,0,base_plate_height])
      for (pos = peg_pos) {
        translate(pos)
          cylinder(r=peg_diam/2,h=peg_height,$fs=0.5);
      }

    translate([plate_width/2,datewheel_diam/2+2*datewheel_extra_clearance,0])
    {
      difference() {
        cylinder(r=monthwheel_spacing_outer_diam/2,h=base_plate_height,$fa=5);
        translate([0,0,-base_plate_height])
          cylinder(r=monthwheel_spacing_inner_diam/2,h=3*base_plate_height,$fa=5);
      }
    }
  }
}
// the plate that has slots in it, that mounts to the base plate
module top_plate()
{
  top_plate_height=2*layer_thickness;

  // measurements as lying down
  date_slot_width = plate_width/2-monthwheel_spacing_outer_diam/2;
  date_slot_depth = 2*date_font_height;

  // Overlaps with circle for grip points:
  month_slot_width = monthwheel_spacing_inner_diam/2;
  month_slot_depth = 2*month_font_height;

  grip_slot_diam = 1.3*monthwheel_grip_diam;
  grip_slot_upper_diam = 1.2*grip_slot_diam;
  difference() {
    union()
    {
      color(base_colour) {
        cube ([plate_width,plate_depth,top_plate_height]);
      }
      color(contrast_colour) {
        translate([
            plate_width/2,
            datewheel_diam/2+2*datewheel_extra_clearance+grip_slot_upper_diam/2+font_padding_factor*description_font_height,
            top_plate_height
        ]) {
          for (i = [0:len(description_labels)])
          {
            translate([0,(len(description_labels)-i-1)*(1+font_padding_factor)*description_font_height,0])
            {
              linear_extrude(height=font_height_proportion*wheel_thickness)
                text(description_labels[i],size=description_font_height,font=description_font, halign="center",$fn=10);
            }
          }
        }
      }
    }
    union()
    {
      color(base_colour) {
        translate([
            0,
            datewheel_diam/2+2*datewheel_extra_clearance-date_slot_depth/2,
            -top_plate_height])
          cube([date_slot_width,date_slot_depth,3*top_plate_height]);
        translate([
            plate_width/2-month_slot_width,
            datewheel_diam/2+2*datewheel_extra_clearance-month_slot_depth/2,
            -top_plate_height])
          cube([month_slot_width,month_slot_depth,3*top_plate_height]);

        translate([
            plate_width/2,
            datewheel_diam/2+2*datewheel_extra_clearance,
            -0.1*top_plate_height])
          cylinder(r1=grip_slot_diam/2,r2=grip_slot_upper_diam/2,h=1.2*top_plate_height,$fa=5);
      }

      // Place pegs:
      translate([0,0,-0.01])
        for (pos = peg_pos) {
          translate(pos)
            cylinder(r=peg_diam/2+peg_diam_extra_clearance,h=peg_height_holeside_factor*peg_height,$fs=0.5);
        }
    }
  }
}

// rotary two-colour print that displays date_labels
module date_wheel()
{
  num_grip_points=floor(0.2*3.14*datewheel_diam);
  color(base_colour) {
    difference() {
      cylinder(r=datewheel_diam/2,h=(1-font_height_proportion)*wheel_thickness,$fa=5);
      translate([0,0,-0.1*wheel_thickness])
        cylinder(r=monthwheel_spacing_outer_diam/2+datewheel_extra_clearance,h=1.2*wheel_thickness,$fa=5);
      // Indent some grip points along the periphery:
      for (i = [0 : 1 : num_grip_points]){

        rotate([0,0,i*360/num_grip_points])
          translate([datewheel_diam/2-1,0,-0.1*wheel_thickness])
          cube([1,2,1.2*wheel_thickness]);
      }
    }
  }
  color(contrast_colour) {
    for (i = [0 : 1 : len(date_labels)]){
      rotate([0,0,i*360/len(date_labels)]) {
        translate([
            -(monthwheel_spacing_outer_diam/2+monthwheel_extra_clearance),
            -date_font_height/2,
            (1-font_height_proportion)*wheel_thickness])
        {
          // Keep slightly lower than wheel_thickness (might snag on top_plate)
          linear_extrude(height=font_height_proportion*wheel_thickness)
            text(date_labels[i],size=date_font_height,font=date_font, halign="right",$fn=10);
        }
      }
    }
  }

}
module month_wheel()
{
  // rotary two-colour print that displays month_labels
  color(base_colour)
    cylinder(r=monthwheel_diam/2,h=(1-font_height_proportion)*wheel_thickness,$fa=5);

  color(contrast_colour) {
    for (i = [0 : 1 : len(month_labels)]){
      rotate([0,0,i*360/len(month_labels)]) {
        translate([
            -(monthwheel_diam/2-month_font_height/4),
            -month_font_height/2,
            (1-font_height_proportion)*wheel_thickness])
        {
          // Keep slightly lower than wheel_thickness (might snag on top_plate)
          linear_extrude(height=font_height_proportion*wheel_thickness)
            text(month_labels[i],size=month_font_height,font=month_font, halign="left",$fn=10);
        }
      }
    }
  }

  num_grip_points=6;
  for (i = [0 : 1 : num_grip_points]){
    rotate([0,0,i*360/num_grip_points])
      //translate([monthwheel_grip_diam/2,0,0])
      translate([0,-0.5,0.01])
      color(contrast_colour)
      cube([monthwheel_grip_diam/2,1,3*layer_thickness]);
  }
}


module render_composition ()
{
  base_plate();
  translate([0,0,base_plate_height])
    top_plate();
  translate([
      plate_width/2,
      datewheel_diam/2+2*datewheel_extra_clearance,
      plate_thickness/3])
  {
    month_wheel();
    date_wheel();
  }
}

module render_explosion_view ()
{
  base_plate();
  translate([0,0,20*base_plate_height])
    //translate([0,0,base_plate_height])
    top_plate();
  translate([
      plate_width/2,
      datewheel_diam/2+2*datewheel_extra_clearance,
      0])
  {
    translate([0,0,6*base_plate_height])
      date_wheel();
    translate([0,0,12*base_plate_height])
      month_wheel();
  }
}

if ("composition" == render_part) {
  render_composition();
} else if ("explosion_view" == render_part) {
  render_explosion_view();
} else if ("base_plate" == render_part) {
  base_plate();
} else if ("top_plate" == render_part) {
  top_plate();
} else if ("date_wheel" == render_part) {
  date_wheel();
} else if ("month_wheel" == render_part) {
  month_wheel();
}


// vim: ft=openscad fdm=marker fml=1
