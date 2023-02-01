using DataFrames
using CSV
using BenchmarkTools
using Statistics
using DataStructures
using Plots

ca = CSV.read("C:\\Users\\Dell\\Downloads\\data.csv",DataFrame, header = true);
c=dropmissing(ca)

#Initial Variables and Arrays Declared
bcolumn = c[:,6]
pcolumn = c[:,5]
prcolumn = c[:,7]
dcolumn = c[:,1]
#Getting unique values of items
productsold = unique(c.category_code)
products = []
price = []
dates = []
var = 0
vari = 0
rows = []
#Filtering out necessary products
function filtering(name1,name2,arraystored,arraydata)
    for a in arraydata
        if occursin(name1,a)
            push!(arraystored,a)
        elseif occursin(name2,a)
            push!(arraystored,a)
        end
    end
end
#Calling the function
filtering("electronics","computer",products,productsold)
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
#Getting total value per item 
ubrand = unique(brands)
totalpriceitems = []
function totalvalue(arrayout,list,x)
    for counter in list
        test = c[c[!,Symbol(x)] .== counter,:]
        indiprices = sum(test.price)
        push!(arrayout,indiprices)
        indiprices = 0
    end
end
totalvalue(totalpriceitems,products,"category_code")
#Dataframe with products,volume and total value
numberproducts = counter(productsfull)
dataframe = DataFrame(product=[],volume=[],total_value=[])
for i in 1:length(products)
    push!(dataframe.product,products[i])
    push!(dataframe.volume,numberproducts[products[i]])
    push!(dataframe.total_value,totalpriceitems[i])
end
#Calculate % contribution of products by value and get significant data
arraymiscb = []
arraybig = []
arraylargest = []
namesforchart = []
temp = []
newtemp = []
names_final = []
tempe = 0 
function percentagecalc(value,baseval,arrayreq,temp,arrayout,arrayvalues,smallest,x,frame,arraymain)
    value = (value*100)/baseval 
    arrayvalues = frame[frame[!,Symbol(x)] .>=(sum(arraymain)*smallest/100) ,:]
    for i in value
        if i<smallest
            push!(arraymiscb,i)
        else
            push!(arraybig,i)
            push!(arraylargest,i*baseval/100)
        end
    end
    push!(arrayreq,arrayvalues[:,1])
    while length(arrayreq) == 1
        arrayreq = arrayreq[1]
    end
    for count in 1:length(arrayreq)
        temp = split(string(arrayreq[count]),".")
        tempe = temp[length(temp)]
        newtemp = (uppercase(tempe[1])*tempe[2:end])
        push!(arrayout,(newtemp*string(" - ")*string(floor(arraybig[count]))string("%")))
    end
    push!(arrayout,("Others"*string(" - ")*string(floor(sum(arraymiscb)))*string("%")))
    push!(arraybig,sum(arraymiscb))
end
#Define Arrays
valuefilter_items = []
volumefilter_product = []
volumefilter_brand = []
#Calling Percentagecalc
percentagecalc(totalpriceitems,sum(totalpriceitems),namesforchart,temp,names_final,valuefilter_items,2,"total_value",dataframe,totalpriceitems)
totalvolumebrands = []
totalvolumeproducts = []
uproduct = unique(productsfull)
function totalvolume(list,arrayb,column)
    for counter in list
        test = c[c[!,Symbol(column)] .== counter,:]
        indivolume = nrow(test)
        push!(arrayb,indivolume)
    end
end
#Pie chart showing largest categories by value
pie_largestcat_value=gui(pie(names_final,arraybig, title = "Largest Categories by Value"))
png("D:\\workspace\\github\\charts\\pie_largestcat_value")
totalvolume(ubrand,totalvolumebrands,"brand")
totalvolume(uproduct,totalvolumeproducts,"category_code")
pvolume = DataFrame(product = uproduct,volume = totalvolumeproducts)
bvolume = DataFrame(brand = ubrand,volume = totalvolumebrands)
arraymiscb = []
arraybig = []
arraylargest = []
newtemp = []
names_final2 = []
namesforchart2 = []
namesforchart3 = []
names_final3 = []
percentagecalc(bvolume[:,2],sum(bvolume[:,2]),namesforchart2,temp,names_final2,volumefilter_brand,2,"volume",bvolume,bvolume[:,2])
#Pie chart showing largest brand by volume
pie_largestbrand_volume= gui(pie(names_final2,arraybig, title = "Largest Brands by Volume Sold"))
png("D:\\workspace\\github\\charts\\pie_largestbrand_volume")
arraybig = []
percentagecalc(pvolume[:,2],sum(pvolume[:,2]),namesforchart3,temp,names_final3,volumefilter_product,2,"volume",pvolume,pvolume[:,2])
#Pie chart showing largest categories by volume
pie_largestcat_volume = gui(pie(names_final3,arraybig, title = "Largest Categories by Volume"))
png("D:\\workspace\\github\\charts\\pie_largestcat_volume")
