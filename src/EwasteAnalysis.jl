using DataFrames
using CSV
using BenchmarkTools
using Statistics
using DataStructures
using Plots

#Read the csv file and loading it into a data frame - M
data = CSV.read("D:\\workspace\\github\\ewaste\\data\\data.csv",DataFrame, header = true);
data=dropmissing(data)

#Ewaste by time graph and weight generated info
data_weight = CSV.read("D:\\workspace\\github\\ewaste\\data\\data_weight.csv",DataFrame, header = true);
data_weight = dropmissing(data_weight)

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

#Adding columns to the dataframe to store all the data pertaining to the products
function addcolumns!(list_volume)
    local volume = 0
    local total_weight = 0
    local temp_variable = []
    local temparray_lifespan = []
    local temp_array = []
    local years = 0
    local counter = 1
    local temp = 0 
    local anothertemp = 0
    local lowercase_temp = 0
    local array_intermediate = []

    for count in 1:length(list_volume[:,1])
        temp = split(string(list_volume[count,1]),".")
        anothertemp = temp[length(temp)]
        lowercase_temp = (uppercase(anothertemp[1])*anothertemp[2:end])
        list_volume[count,1] = lowercase_temp
    end
  

    for i in unique(list_volume[:,1])
        if counter < length(list_volume[:,1])+1
            array_intermediate = data_weight[data_weight[!,Symbol("Item")] .== i ,:]
            if size(array_intermediate) == (1,4) 
                list_volume[counter,1] = string(array_intermediate[1,2])
            end
            counter = counter +1
        end
    end
   

    volume = "volume"
    data_weight[!,volume] = zeros(34)
    temp = 0 

    for i in data_weight[:,2]
        temp = temp+1
        counter = 0
        for g in list_volume[:,1]
            counter = counter + 1
            if i == g
                data_weight.volume[temp] = list_volume[counter,2]
            end
        end
    end
    
    for i in 1:length(data_weight[:,1])

        temp_variable = data_weight[i,3]*data_weight[i,5]/1000
        total_weight = "total weight in kg"
        push!(temp_array,temp_variable)
        years = data_weight[i,4]
        push!(temparray_lifespan,years/12)    
    
    end

    volume = "lifespan in years"
    data_weight[!,total_weight] = temp_array
    data_weight[!,volume] = temparray_lifespan
    println(data_weight)
end    


#Function taking cummalative ewaste generated every 3 months
function populatetotalwaste!(dataframe)
    local array_intermediate = []

    for i in sort(unique(data_weight[:,7]))
        array_intermediate = data_weight[data_weight[!,Symbol("lifespan in years")] .== i ,:]
        push!(dataframe.totalweight,sum(array_intermediate[:,6]))
        push!(dataframe.lifespan,i)
    end

    for i in 2:9
        dataframe[i,1] = floor(dataframe[i-1,1] + dataframe[i,1])
    end

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
    local names_fordisplay_weight = []
    local arraybig_itemvalue = []
    local arraybig_itemvolume = []
    local arraybig_brandvolume = []
    local arraybig_weight = []
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
    weight = DataFrame(totalweight = [], lifespan = [])
    
    
    #Call the function make the data frame - M
    makedataframe(products,productsfull,dataframe,totalpriceitems)
    
    #Call the function for percentage calculation - M
    calculatepercentage!(totalpriceitems,names_fordisplay_product,2,"total_value",dataframe,arraybig_itemvalue)

    #Pie chart showing largest categories by value - M
    pie_largestcat_value=gui(pie(names_fordisplay_product,arraybig_itemvalue, title = "Largest Categories by Value"))
    png("D:\\workspace\\workingdirectory\\pie_largestcat_value")
    
    #Calling the function (Percentagecalc) - M
    calculatepercentage!(bvolume[:,2],names_fordisplay_brand,2,"volume",bvolume,arraybig_brandvolume)
    #Pie chart showing largest brand by volume - M
    pie_largestbrand_volume= gui(pie(names_fordisplay_brand,arraybig_brandvolume, title = "Largest Brands by Volume Sold"))
    png("D:\\workspace\\workingdirectory\\pie_largestbrand_volume")

    #Calling the function (Percentagecalc) - M
    calculatepercentage!(pvolume[:,2],names_fordisplay_itemvolume,2,"volume",pvolume,arraybig_itemvolume)
    
    #Pie chart showing largest categories by volume - M
    pie_largestcat_volume = gui(pie(names_fordisplay_itemvolume,arraybig_itemvolume, title = "Largest Categories by Volume"))
    png("D:\\workspace\\workingdirectory\\pie_largestcat_volume")

    #Calling the function (Percentagecalc)
    #calculatepercentage!(data_weight[:,5],names_fordisplay_weight,2,"total weight in Kg",data_weight,arraybig_weight)

    #Pie chart showing products contributing most in terms of waste generated

    
    #Calling addcolumns
    addcolumns!(pvolume)
    
    populatetotalwaste!(weight)

    #Graph indicating total ewaste generated over time
    plot_waste = plot(weight[:,2],weight[:,1]/1000,label = false,xlabel = "Time in years",ylabel = "Cumulative weight in tonnes",title = "Total Ewaste Generated Over Time",linewidth = 3)
    png("D:\\workspace\\workingdirectory\\plot_waste")
    
end
# Calls the main function
main()

