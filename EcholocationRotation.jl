# using Makie
# using CairoMakie
# using GLMakie
using CSV
using DataFrames
# using WebIO
# using MeshIO
using Plots
using LinearAlgebra
using StaticArrays
# using PlotlyJS
using Statistics
using Rotations

# windowed function
movF(fs,x,window) = [fs(x[Int(maximum([1,round((g-window)/2)])):Int(minimum([length(x),round((g+window)/2)]))]) for g in 1:length(x)]
# peakstroughs
function PeakTrough(x::Vector{Float64})
    Peaks = zeros(Int64,0)
    Troughs = zeros(Int64,0)
    for b = 2:length(x)-1
        if x[b-1] > x[b] && x[b+1] >= x[b]
            append!(Troughs, b)
        elseif x[b-1] <= x[b] && x[b+1] < x[b]
            append!(Peaks,b)
        end
    end
    return Peaks, Troughs
end
# calculate echolocation distance
function echDist(ICI::Float64,pT::Float64=0)
    dist = (343*ICI) - pT;
    if dist < pT
    throw(ArgumentError("Processing time exceeds half the ICI"))
    end
end
# read in the data
Dat = CSV.File("D++.txt",delim = '\t') |> DataFrame;
rename!(Dat,[:Depth,:Pitch,:Roll,:Speed,:Heading]);
new = Dat[:,2:3]
new = new[1:16:nrow(Dat),:]
new = new[1:sum(ismissing.(Dat.Heading) .== false),:]
dat = DataFrame(Depth = Dat.Depth[1:sum(ismissing.(Dat.Heading) .== false)], Pitch = new[:,1], Roll = new[:,2], Speed = Dat.Speed[1:sum(ismissing.(Dat.Heading) .== false)], Head = Dat.Heading[sum(ismissing.(Dat.Heading) .== false)])

bleurgh = @layout [a ; b]

Plots.plot(dat.Pitch)

Plots.plot(accumulate(+, dat.Speed.*dat.Pitch))

Plots.plot(accumulate(+, sin.(dat.Pitch)))

Plots.plot(dat.Pitch)
Plots.plot!(dat.Depth)


Plots.plot(accumulate(+,dat.Speed.*sin.(dat.Pitch)),accumulate(+, dat.Speed.*cos.(dat.Roll)),accumulate(+, dat.Speed.*cos.(dat.Head)))

Plots.plot(accumulate(+,dat.Speed.*sin.(dat.Pitch)))

Plots.plot(dat.Depth,yflip=true)

plotlyjs()
Plots.plot(dat.Depth,yflip=true)
pk,tr = PeakTrough(identity.(dat.Depth));
Plots.scatter!(tr,dat.Depth[tr])
Plots.plot!(dat.Pitch,mirror=true,ylims=(minimum(dat.Pitch),maximum(dat.Pitch)))


Plots.scatter([1,1,1], [0,0,0], [0,0,0])
Plots.plot([0,0],[0,1],[0,0])


Plots.plot([0,0],[0,0],[0,1],arrow=2)