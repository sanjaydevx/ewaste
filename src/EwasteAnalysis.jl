using DelimitedFiles
using DataFrames
using CSV
using BenchmarkTools
using Statistics

H = readdlm("C:\\Users\\Dell\\Downloads\\Trade.csv",',',header=true);
Ca = CSV.read("C:\\Users\\Dell\\Downloads\\Data.csv",DataFrame, header = true);
C=dropmissing(Ca)
println(C)