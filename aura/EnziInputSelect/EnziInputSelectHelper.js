({
	sortRecords:function(records,sortBy,sortOrder){
        records.sort(function(a,b){
            var dataA,dataB;
            if(sortBy.includes(".")){
                dataA = a;
                dataB = b;
                sortBy.split(".").forEach(function(f){
                    if(dataA){
                        dataA = dataA[f];
                    }
                    if(dataB){
                        dataB = dataB[f];
                    }
                })
            }else{
                dataA = a[sortBy];
                dataB = b[sortBy];
            }
            var t1 = dataA == dataB, t2 = dataA < dataB;
            return t1? 0: (sortOrder=="asc"?-1:1)*(t2?1:-1);
        })
        return records;
    }
})