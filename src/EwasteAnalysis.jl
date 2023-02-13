using DataFrames
using CSV
using BenchmarkTools
using Statistics
using DataStructures
using Plots

#Read the csv file and loading it into a data frame - M
data = CSV.read("C:\\Users\\Dell\\Downloads\\data.csv",DataFrame, header = true);
data=dropmissing(data)

#Functions

#Filter out electronic items sold 
function populatefilterdata!(arraystored)
    for a in unique(data.category_code)
        if occursin("electronics",a)
            push!(arraystored,a)
        elseif occursin("computers",a)
            push!(arraystored,a)
        end
    end
end

#Get rows which have necessary products
function populaterows!(arrayout,column,list)
    local vari
    for check in list
        vari = 0
        for counter in column
            vari = vari +1
            if check == counter
                push!(arrayout,vari)
            end
        end
    end
end

#Get total value per item 
function populatetotalvalue!(arrayout,list,x)
    local indiprices = 0
    for counter in list
        test = data[data[!,Symbol(x)] .== counter,:]
        indiprices = sum(test.price)
        push!(arrayout,indiprices)
        indiprices = 0
    end
end

#Function to get total volume
function gettotalvolume!(list,arrayb,column)
    local indivolume = 0
    for counter in list
        test = data[data[!,Symbol(column)] .== counter,:]
        indivolume = nrow(test)
        push!(arrayb,indivolume)
    end
end

#Dataframe with products,volume and total value
function makedataframe(list,listwithallproducts,dataframe,pricelist)
    for i in 1:length(list)
        local numberproducts
        numberproducts = counter(listwithallproducts)
        push!(dataframe.product,list[i])
        push!(dataframe.volume,numberproducts[list[i]])
        push!(dataframe.total_value,pricelist[i])
    end
end

#Calculate % contribution of products by value and get significant data
function calculatepercentage!(value,arrayout,smallest,x,frame,valuesfordisplay)

    local array_insignificantvalues = []
    local arraylargestcontributors = []
    local arrayrequired = []
    local temp = 0
    local anothertemp = 0
    local lowercase_temp = 0
    local arrayvalues = []
    local baseval = 0   


    baseval = sum(value)
    value = (value*100)/baseval 
    arrayvalues = frame[frame[!,Symbol(x)] .>=(baseval*smallest/100) ,:]
    for i in value
        if i<smallest
            push!(array_insignificantvalues,i)
        else
            push!(valuesfordisplay,i)
            push!(arraylargestcontributors,i*baseval/100)
        end
    end
    push!(arrayrequired,arrayvalues[:,1])
    while length(arrayrequired) == 1
        arrayrequired = arrayrequired[1]
    end
    for count in 1:length(arrayrequired)
        temp = split(string(arrayrequired[count]),".")
        anothertemp = temp[length(temp)]
        lowercase_temp = (uppercase(anothertemp[1])*anothertemp[2:end])
        push!(arrayout,(lowercase_temp*string(" - ")*string(floor(valuesfordisplay[count]))string("%")))
    end
    push!(arrayout,("Others"*string(" - ")*string(floor(sum(array_insignificantvalues)))*string("%")))
    push!(valuesfordisplay,sum(array_insignificantvalues))
end

#Main Function 
function main()

#Local Variables
    local products = []
    local dates = []
    local rows = []
    local totalpriceitems = []
    local totalvolumebrands = []
    local totalvolumeproducts = []
    local names_fordisplay_brand = []
    local names_fordisplay_product = []
    local names_fordisplay_itemvolume = []
    local arraybig_itemvalue = []
    local arraybig_itemvolume = []
    local arraybig_brandvolume = []
    local productsfull = []
    local brands = []
    local dates = []
    local prices = []
    local uniquebrand = 0
    local uniqueproduct = 0

    #Arrays containing columnwise data
    productcolumn = data[:,5]
    brandcolumn = data[:,6]
    pricecolumn = data[:,7]
    datecolumn = data[:,1]
    
    #Call the filter function - M
    populatefilterdata!(products)

    #Call the function to get rows - M
    populaterows!(rows,productcolumn,products)

    #Calling function to get all columns of rows containing electronic items - M
    #getnecessarycolumns!(productcolumn,brandcolumn,pricecolumn,datecolumn)
    productsfull = productcolumn[rows]
    brands = brandcolumn[rows]
    prices = pricecolumn[rows]
    dates = datecolumn[rows]

    #Unique items (Put in a function) - M
    uniquebrand = unique(brands)
    uniqueproduct = unique(productsfull)

    #Call the function to get total value - M
    populatetotalvalue!(totalpriceitems,products,"category_code")

    #Calling the function - M
    gettotalvolume!(uniquebrand,totalvolumebrands,"brand")
    gettotalvolume!(uniqueproduct,totalvolumeproducts,"category_code")
    
    #Dataframes - M 
    dataframe = DataFrame(product=[],volume=[],total_value=[])
    pvolume = DataFrame(product = uniqueproduct,volume = totalvolumeproducts)
    bvolume = DataFrame(brand = uniquebrand,volume = totalvolumebrands)

    #Call the function make the data frame - M
    makedataframe(products,productsfull,dataframe,totalpriceitems)
    
    #Call the function for percentage calculation - M
    calculatepercentage!(totalpriceitems,names_fordisplay_product,2,"total_value",dataframe,arraybig_itemvalue)

    #Pie chart showing largest categories by value - M
    pie_largestcat_value=gui(pie(names_fordisplay_product,arraybig_itemvalue, title = "Largest Categories by Value"))
    png("D:\\workspace\\workingdirectory\\pie_largestcat_value")
    
    #Calling the function (Percentagecalc) - M
    calculatepercentage!(bvolume[:,2],names_fordisplay_brand,2,"volume",bvolume,arraybig_brandvolume)
    #!Pie chart showing largest brand by volume - M
    pie_largestbrand_volume= gui(pie(names_fordisplay_brand,arraybig_brandvolume, title = "Largest Brands by Volume Sold"))
    png("D:\\workspace\\workingdirectory\\pie_largestbrand_volume")
    

    #Calling the function (Percentagecalc) - M
    calculatepercentage!(pvolume[:,2],names_fordisplay_itemvolume,2,"volume",pvolume,arraybig_itemvolume)
    
    #Pie chart showing largest categories by volume - M
    pie_largestcat_volume = gui(pie(names_fordisplay_itemvolume,arraybig_itemvolume, title = "Largest Categories by Volume"))
    png("D:\\workspace\\workingdirectory\\pie_largestcat_volume")
    
end

# Calls the main function
main()
