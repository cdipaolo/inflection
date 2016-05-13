#===================================
se_kernel.jl

Defines the Squared Exponential Kernel
type, SEKernel. This Mercer Kernel is defined
with

    k(x,x') = σ^2exp(-(x-x')'*Λ^{-1}*(x-x')),

and is infinitely differentiable.
===================================#
