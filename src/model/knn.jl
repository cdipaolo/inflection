#============================================
    knn.jl
    
    Runs k-nearest-neighbors on review data
    to predict the average reviews of a business
    from it's location alone

    Haversine distance is used as the distance
    metric.
============================================#
using DataFrames
using ProgressMeter
include("confusion.jl")

#============================================
    Define the actual model and distance
    metrics
============================================#

"Haversin function"
@inline hsin(θ::Number) = sin(θ/2)^2

"""distance
computes the Haversin distance, or
the great circle approximation of distance on
earth
"""
@inline function distance(p1, p2)
    # convert to radians
    la1 = p1[1] * π/180
    lo1 = p1[2] * π/180
    la2 = p2[1] * π/180
    lo2 = p2[2] * π/180

    # Earth radius in METERS
    r = 6378100

    h = hsin(la2-la1) + cos(la1)*cos(la2)*hsin(lo2-lo1)

    return 2*r*asin(sqrt(h))
end

"""knn
runs knn on the dataset X with
labels y⃗, returning the prediction
for point x. The rows of X are datapoints
corresponding to the labels in the
rows of y⃗. x is a column vector.

This performs _classification_, so it
takes the _mode_ of the nearest k
points as the prediction, not the mean.
"""
function knn(x::Array, X::Array, y⃗::Array, k::Integer)
    @assert k < size(X)[1]
    @assert size(X)[1] == size(y⃗)[1]
    @assert size(x)[2] == size(X)[2]
    # create data matrix to sort
    A = [X y⃗]

    # create comparator to sort by the distance
    # to the point x
    lt = (x′,x′′) -> distance(x,x′[1:end-1]) < distance(x,x′′[1:end-1])

    # get initial neighbors by pulling from the top
    neighbors = sortrows(A[1:k,:], lt=lt)

    for i=(k+1):size(X)[1]
        for j=k:-1:1
            if lt(A[i,:],neighbors[j,:])
                # insert the new x into the array
                neighbors[end,:] = A[i,:]
                neighbors = sortrows(neighbors, lt=lt)
            else
                break
            end
        end
    end

    # predict the (rounded) mean of the nearest
    # neighbors' labels.
    return round(Integer,mean(neighbors[:,end]))
end

#============================================
    Run knn at different values of K on
    the actual data
============================================#

println("==> Loading business review data")
df = readtable("../stars.csv", separator='|')
X = Array(df[:,[:latitude,:longitude]])
y⃗ = round(Int,Array(df[:,:stars]*2)) #scale to range from 1-10

ks = [3]

println("==> Running knn for k=$(ks)")
acc = Accuracy(10)

log = open("knn.log","a")
write(log,"""
-----------------------------------
--        $(now())
-----------------------------------
""")

for k in ks
    log = open("knn.log", "a")
    start = now()
    @showprogress 1 "==> k=$(k)" for i in 1:size(X)[1]
        # remove the datapoint we're predicting on
        pred = knn(X[i,:], X[1:end .!=i,:], y⃗[1:end .!=i], k)
        predict!(acc, pred, y⃗[i])
    end
    println("==> Done with k=$(k)!\n")

    # write results to the file
    write(log, """
-----------------------------------
k=$(k)
elapsed:   $(now()-start)
mean iter: $(convert(Int,now()-start)/size(X)[1])
accuracy:  $(accuracy(acc))
precision: $(precision(acc))
recall:    $(recall(acc))\n
confusion: 
$(acc.prediction)\n\n""")
    close(log)
end

