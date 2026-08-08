# convert efinix '.f' inclusion file (plain list of files)
# into a tcl list of normalized filenames.

proc efxf2TclList {f_file_name} {
  set dir_name [file dirname ${f_file_name}]
  set f_handle [open ${f_file_name}]
  set result_list {}
  while { [gets ${f_handle} line] >= 0 } {
    # filter comments
    if { [regexp {^[ \t]*[#]} "${line}" ] == 0 } {
      lappend result_list [file normalize "${dir_name}/${line}"]
    }
  }
  close ${f_handle}
  return ${result_list}
}
