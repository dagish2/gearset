({
    calculateDiscount : function(price,discount) {
        return (price*(100-discount)/100).toFixed(2);        
    },
    setData:function(component,onsuccess,onerror){
        var helper = this;
        var capacity = component.get("v.capacity");
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,A12M__c,A24M__c,A6M__c,C12M__c,C24M__c,C6M__c,Location__c,Location_UUID__c,Max_Desks__c,Min_Desks__c,SA12M__c,SA24M__c,SA6M__c,SKU__c From Suggested_Discounts__c Where (Location_UUID__c='"+component.get('v.uuid')+"' AND ((Min_Desks__c <="+capacity+" OR Min_Desks__c=NULL) AND (Max_Desks__c >="+capacity+" OR Max_Desks__c=NULL))) LIMIT 1"},function(result){
            if(result.length>0){                
                var discount = result[0];
                console.log(discount);
                var records = [];
                var price = component.get("v.price");
                records.push({"term":"6 Months","conservative":helper.calculateDiscount(price,discount.C6M__c)+" ("+discount.C6M__c+"%)","agressive":helper.calculateDiscount(price,discount.A6M__c)+" ("+discount.A6M__c+"%)","super_aggresive":helper.calculateDiscount(price,discount.SA6M__c)+" ("+discount.SA6M__c+"%)"});
                records.push({"term":"12 Months","conservative":helper.calculateDiscount(price,discount.C12M__c)+" ("+discount.C12M__c+"%)","agressive":helper.calculateDiscount(price,discount.A12M__c)+" ("+discount.A12M__c+"%)","super_aggresive":helper.calculateDiscount(price,discount.SA12M__c)+" ("+discount.SA12M__c+"%)"});
                records.push({"term":"24 Months","conservative":helper.calculateDiscount(price,discount.C24M__c)+" ("+discount.C24M__c+"%)","agressive":helper.calculateDiscount(price,discount.A24M__c)+" ("+discount.A24M__c+"%)","super_aggresive":helper.calculateDiscount(price,discount.SA24M__c)+" ("+discount.SA24M__c+"%)"});
                component.set("v.records",records);
                onsuccess();                
            }else{
                onerror();
            }
        },function(error){
            onerror(error);
        })
    }
})