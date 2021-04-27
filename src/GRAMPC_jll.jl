# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule GRAMPC_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("GRAMPC")
JLLWrappers.@generate_main_file("GRAMPC", UUID("d34e300a-2cc9-5961-b927-8807a6583580"))
end  # module GRAMPC_jll
