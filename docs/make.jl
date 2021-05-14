using GRAMPC
using Documenter

DocMeta.setdocmeta!(GRAMPC, :DocTestSetup, :(using GRAMPC); recursive=true)

makedocs(;
    modules=[GRAMPC],
    authors="Ian McInerney and contributors",
    repo="https://github.com/imciner2/GRAMPC.jl/blob/{commit}{path}#{line}",
    sitename="GRAMPC.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://imciner2.github.io/GRAMPC.jl",
        assets=String[],
    ),
    pages=
    [
        "Home" => "index.md",
        "Usage" =>
        [
            "Solver Options" => "options.md"
        ],
        "Internals" =>
        [
            "Error Handling" => "error_handling.md",
            "Problem Functions" => "problem_functions.md"
        ]
    ],
)

#deploydocs(;
#    repo="github.com/imciner2/GRAMPC.jl",
#)
