#run build();

OUTPUT_DIR :: "generated/linux"; // we don't give a shit about windows or mac

build :: () {
  set_build_options_dc(.{do_output=false});

  ok := make_directory_if_it_does_not_exist(OUTPUT_DIR, recursive = true);

  assert(ok);

  generate_bindings();
}



general_binding_opts :: (opts: *Generate_Bindings_Options, lib_name: string) -> string {
  using opts;
  #if OS != .LINUX {
    assert(false);
  }
  output_filename := sprint("%/%.jai", OUTPUT_DIR, lib_name); // we do not care about leaking memory
  array_add(*system_library_paths, ".",  "/usr/lib");
  return output_filename;
}

generate_bindings :: () -> bool {

  output_filename: string;
  opts: Generate_Bindings_Options;
  using opts;
  // avcodec
  {
    generate_compile_time_struct_checks = false;
    output_filename = general_binding_opts(*opts, "avcodec");
    array_add(*system_library_names, "libavcodec.so");
    array_add(*include_paths, "/usr/include/libavcodec");

    array_add(*path_fragments_to_treat_as_non_system_paths,  
      "/usr/include/libavcodec/codec_id.h",
      "/usr/include/libavcodec/codec_par.h",
      "/usr/include/libavutil/channel_layout.h",
      "/usr/include/libavutil/samplefmt.h.h",
      "/usr/include/libavutil/hw_context.h",
    );
    array_add(*source_files, 
      "/usr/include/libavcodec/codec.h",
    );
    array_add(*system_types_to_include, "AVHWDeviceType");
    ok := generate_bindings(opts, output_filename);
    if !ok return false;
  }
  opts = .{};
  // avformat
  {
    generate_compile_time_struct_checks = false;
    output_filename = general_binding_opts(*opts, "avformat");
    array_add(*system_library_names, "libavformat.so");
    array_add(*include_paths, "/usr/include/libavformat");

    array_add(*path_fragments_to_treat_as_non_system_paths,  
      // "/usr/include/libavcodec/codec_id.h",
      "/usr/include/libavcodec/codec_par.h",
      "/usr/include/libavutil/dict.h",
      "/usr/include/libavutil/frame.h",
      "/usr/include/libavutil/buffer.h",
      "/usr/include/libavcodec/defs.h",
      "/usr/include/libavcodec/packet.h",
    );

    array_add(*system_types_to_include, "AVSampleFormat");
    array_add(*source_files, "/usr/include/libavformat/avformat.h");
    footer = "FILE :: *void;";
    ok := generate_bindings(opts, output_filename);
    if !ok return false;
  }

  opts = .{};
  // avutil
  {
    generate_compile_time_struct_checks = false;
    output_filename = general_binding_opts(*opts, "avutil");
    array_add(*include_paths, "/usr/include/libavutil");
    array_add(*system_library_names, "libavutil.so");

    array_add(*path_fragments_to_treat_as_non_system_paths, "/usr/include/bits/types/struct_tm.h");
    array_add(*system_types_to_include, "tm");

    array_add(*source_files, "/usr/include/libavutil/avutil.h");
    ok := generate_bindings(opts, output_filename);
    if !ok return false;
  }
  return true;
}

#scope_file

#import "Basic";
#import "Compiler";
#import "Check";
#import "Bindings_Generator";
#import "File";
#import "File_Utilities";
#import "String";
