using DelimitedFiles
using DataFrames
using CSV
using BenchmarkTools
using Statistics

H = readdlm("C:\\Users\\Dell\\Downloads\\Trade.csv",',',header=true);
Ca = CSV.read("C:\\Users\\Dell\\Downloads\\Data.csv",DataFrame, header = true);
C=dropmissing(Ca)
bcolumn = C[:,6]
pcolumn = C[:,5]
prcolumn = C[:,7]
dcolumn = C[:,1]
#Getting unique values of items
productsold = unique(C.category_code)
products = []
price = []
dates = []
var = 0
vari = 0
rows = []
#Filtering out necessary products
function filter(name1,name2,arraystored,arraydata)
    for a in arraydata
        if occursin(name1,a)
            push!(arraystored,a)
        elseif occursin(name2,a)
            push!(arraystored,a)
        end
    end
end


filter("electronics","computer",products,productsold)
#Get rows which have necessary products
function getrows(arraydata2,productcolumn,arrayout)
    for check in arraydata2
        vari = 0
        for counter in productcolumn
            vari = vari +1
            if check == counter
                push!(arrayout,vari)
            end
        end
    end
end
#Get other information of necessary products
getrows(products,pcolumn,rows)
productsfull = pcolumn[rows]
brands = bcolumn[rows]
prices = prcolumn[rows]
dates = dcolumn[rows]
using DataStructures
numberprice = []
numberprice = counter(prices)
numberbrands = counter(brands)
numberitem = counter(dates)
numberproducts = counter(productsfull)
