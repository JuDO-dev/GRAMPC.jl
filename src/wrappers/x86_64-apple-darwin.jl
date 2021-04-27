# Autogenerated wrapper script for GRAMPC_jll for x86_64-apple-darwin
export libgrampc_julia

JLLWrappers.@generate_wrapper_header("GRAMPC")
JLLWrappers.@declare_library_product(libgrampc_julia, "@rpath/libgrampc_julia.dylib")
function __init__()
    JLLWrappers.@generate_init_header()
    JLLWrappers.@init_library_product(
        libgrampc_julia,
        "lib/libgrampc_julia.dylib",
        RTLD_LAZY | RTLD_DEEPBIND,
    )

    JLLWrappers.@generate_init_footer()
end  # __init__()
