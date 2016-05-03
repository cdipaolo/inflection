using DataFrames

# Accuracy holds classification accuracy info
# which can be used to compute precision, recall, etc.
type Accuracy
   predictions::Int
   correct::Int
   incorrect::Int
   prediction::Array{Int}
   classes::Int

   Accuracy(classes) = new(0,0,0,round(Int,zeros(classes,classes)), classes)
end

# predict! adds a prediction to the accuracy
# type
function predict!(acc::Accuracy, predicted::Int, actual::Int)
    @assert predicted <= acc.classes
    @assert predicted > 0
    @assert actual <= acc.classes
    @assert actual > 0
    acc.predictions += 1
    if predicted == actual
        acc.correct += 1
    else
        acc.incorrect += 1
    end
    acc.prediction[actual,predicted] += 1
end

# accuracy prints and returns mean accuracy
function accuracy(acc::Accuracy)
    println("==> Mean Accuracy:  $(acc.correct/acc.predictions)")
    return acc.correct/acc.predictions
end

# precision returns and prints individual
# class precision and prints mean precision
function precision(acc::Accuracy)
    prec = diag(acc.prediction)./sum(acc.prediction,1)'
    println("==> Mean Precision:  $(mean(prec))")
    println("==> Class Precision: $(prec')")
    return prec
end

# recall returns and prints individual
# class recall and prints mean recall
function recall(acc::Accuracy)
    rec = diag(acc.prediction)./sum(acc.prediction,2)
    println("==> Mean Recall:  $(mean(rec))")
    println("==> Class Recall: $(rec')")
    return rec
end
