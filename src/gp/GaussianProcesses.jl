module GaussianProcesses
    export GP, SEKernel, Kernel, Plot
    include("kernel.jl")
    include("se_kernel.jl")
    include("newton.jl")
    include("optimize.jl")
end
