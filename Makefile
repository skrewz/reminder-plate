# Simple Makefile for reminder_plate project. Simply run `make` to build the
# default target of "all_parts". Tested only an a GNU/Linux system.

.PHONY: all_parts clean

all_parts: reminder_plate-part-month_wheel.stl \
  reminder_plate-part-waste_block.stl \
  reminder_plate-part-date_wheel.stl \
  reminder_plate-part-base_plate.stl \
  reminder_plate-part-top_plate.stl

%.stl: reminder_plate.scad
	@# http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment
	openscad $(shell  echo "$@" | sed -re "s/.*-part-([^-.]+).*/ -D'render_part=\"\1\"'/") -o $@ $<

clean:
	@rm -f *.stl
