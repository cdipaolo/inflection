#=======================
kernel.jl

Defines the abstract Kernel type
along with functions for computing
the Gram Matrix (as well as 1st, 2nd,
and 3rd derivatives thereof)

Every Kernel subtype must implement any of
    kern(k::MyKernel, x::AbstractArray, x_::AbstractArray)    # kernel function
    d_kern(k::MyKernel, x::AbstractArray, x_::AbstractArray)  # first derivative wrt. x
    d2_kern(k::MyKernel, x::AbstractArray, x_::AbstractArray) # second derivative wrt. x
    d3_kern(k::MyKernel, x::AbstractArray, x_::AbstractArray) # third derivative wrt. x
=======================#

abstract Kernel

#==========================================================
K(kernel::Kernel, X::AbstractArray, X_::AbstractArray)

Returns the Kernel matrix between a matrix of datapoints
X (columns are points) and another matrix of points
X_ of the same structure but not necessarily the same size.
If X∈R^{m,n} and X_∈R^{p,n}, K(., X, X_)∈R^{m,p}. The same
structure goes for the later kernel derivatives d_K, d2_K,
etc.
==========================================================#
function K(kernel::Kernel, X::AbstractArray,X_::AbstractArray)
    K_ = zeros(size(X)[1], size(X_)[1])
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = kern(kernel, X[i,:], X_[j,:])
        end
    end
    return K_
end

# K! replaces K with the newly computed matrix
function K!(kernel::Kernel, K_::AbstractArray, X::AbstractArray,X_::AbstractArray)
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = kern(kernel, X[i,:], X_[j,:])
        end
    end
end

# K(kernel::Kernel, X::AbstractArray) computes the kernel between
# X and X. This is the Gram Matrix, and for any valid Mercer
# Kernel this matrix is positive definite.
#
# This functionality is also separate because we can be more efficient
# in computation by only computing the upper triangular component and
# then just copying the upper component to the lower triangular section.
function K(kernel::Kernel, X::AbstractArray)
    K_ = zeros(size(X)[1], size(X_)[1])
    for i=1:size(K_)[1]
        for j=(i+1):size(K_)[2]
            @inbounds K_[i,j] = kern(kernel, X[i,:], X[j,:])
        end
    end
    K_ = K_ + K_'
    for i=1:size(K_)[1]
        @inbounds K_[i,i] = kern(kernel, X[i,:], X[i,:])
    end
    return K_
end

# K! replaces K with the newly computed matrix. Same functionality
# as above.
function K!(kernel::Kernel, K_::AbstractArray, X::AbstractArray)
    fill!(K_,0.0)
    for i=1:size(K_)[1]
        for j=(i+1):size(K_)[2]
            @inbounds K_[i,j] = kern(kernel, X[i,:], X[j,:])
        end
    end
    K_ = K_ + K_'
    for i=1:size(K_)[1]
        @inbounds K_[i,i] = kern(kernel, X[i,:], X[i,:])
    end
end




#==========================================================
d_K(kernel::Kernel, X::AbstractArray, X_::AbstractArray)

Returns ∂Kernel/∂x_ matrix between a matrix of datapoints
X (columns are points) and another matrix of points
X_ of the same structure but not necessarily the same size.
==========================================================#
function d_K(kernel::Kernel, X::AbstractArray,X_::AbstractArray)
    K_ = zeros(size(X)[1], size(X_)[1])
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = -d_kern(kernel, X[i,:], X_[j,:])
        end
    end
    return K_
end

# d_K! replaces K with the newly computed matrix
function d_K!(kernel::Kernel, K_::AbstractArray, X::AbstractArray,X_::AbstractArray)
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = -d_kern(kernel, X[i,:], X_[j,:])
        end
    end
end



#==========================================================
d2_K(kernel::Kernel, X::AbstractArray, X_::AbstractArray)

Returns ∂^2Kernel/∂x_^2 matrix between a matrix of datapoints
X (columns are points) and another matrix of points
X_ of the same structure but not necessarily the same size.
==========================================================#
function d2_K(kernel::Kernel, X::AbstractArray,X_::AbstractArray)
    K_ = zeros(size(X)[1], size(X_)[1])
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = d2_kern(kernel, X[i,:], X_[j,:])
        end
    end
    return K_
end

# d2_K! replaces K with the newly computed matrix
function d2_K!(kernel::Kernel, K_::AbstractArray, X::AbstractArray,X_::AbstractArray)
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = d2_kern(kernel, X[i,:], X_[j,:])
        end
    end
end



#==========================================================
d3_K(kernel::Kernel, X::AbstractArray, X_::AbstractArray)

Returns ∂^3Kernel/∂x_^3 matrix between a matrix of datapoints
X (columns are points) and another matrix of points
X_ of the same structure but not necessarily the same size.
==========================================================#
function d3_K(kernel::Kernel, X::AbstractArray,X_::AbstractArray)
    K_ = zeros(size(X)[1], size(X_)[1])
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = -d3_kern(kernel, X[i,:], X_[j,:])
        end
    end
    return K_
end

# d2_K! replaces K with the newly computed matrix
function d3_K!(kernel::Kernel, K_::AbstractArray, X::AbstractArray,X_::AbstractArray)
    for i=1:size(K_)[1]
        for j=1:size(K_)[2]
            @inbounds K_[i,j] = -d3_kern(kernel, X[i,:], X_[j,:])
        end
    end
end
