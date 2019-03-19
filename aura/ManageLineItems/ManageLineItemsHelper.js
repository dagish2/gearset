({
    setDataFields : function(component, opportunity, onSuccess){        
        var dataFields = [];
        dataFields.push({"label": "Opportunity Name", "value": opportunity.Name, "url": opportunity.Id});
        dataFields.push({"label": "Primary Member", "value": opportunity.Primary_Member_Name__c, "url": opportunity.Primary_Member_Id__c});
        dataFields.push({"label": "Closed Date", "value": opportunity.CloseDate});
        dataFields.push({"label": "Deal Type", "value": opportunity.Deal_Type__c});
        dataFields.push({"label": "Opportunity Owner", "value": opportunity.Owner.Name, "url": opportunity.OwnerId});
        component.set("v.dataFields", dataFields);
        onSuccess();
    },
    getProductDetails : function(component, lstproduct2s, activeFamilies, mapRelatedData, mapOfUnitPrices, onSuccess){
        lstproduct2s.forEach(function(product){
            if(!activeFamilies.includes(product.Family) && product.Family != null){
                activeFamilies.push(product.Family);
            }
            if(!mapRelatedData.relatedProducts.hasOwnProperty(product.Family) && product.Family != null){
                mapRelatedData.relatedProducts[product.Family] = [];
                mapRelatedData.productCategories[product.Family] = [];
            }
            if(product.Family != null){
                mapRelatedData.relatedProducts[product.Family].push(product);
                if(product.Product_Category__c.includes(';')){
                    product.Product_Category__c.split(';').forEach(function(categories){
                        if(!mapRelatedData.productCategories[product.Family].includes(categories))
                            mapRelatedData.productCategories[product.Family].push(categories);  
                    })
                }
                else if(product.Product_Category__c && !mapRelatedData.productCategories[product.Family].includes(product.Product_Category__c)){
                    mapRelatedData.productCategories[product.Family].push(product.Product_Category__c);
                } 
            }
            if(product.PricebookEntries){
                mapOfUnitPrices [product.PricebookEntries.records[0].Product2Id] = product.PricebookEntries.records[0].UnitPrice;
            }
        })
         onSuccess();
    },
	saveProducts : function(component, event, helper, confirmProduct, onsuccess, onerror) {
        component.get("v.utils").execute("c.getQueryResultForLabel",{"label":'PriceBookEntry', "filters": {"CurrencyIsoCode": (component.get("v.opportunity.CurrencyIsoCode")?component.get("v.opportunity.CurrencyIsoCode"):'USD')}},function(response){
            var mapProduct = {};
            for(var r in response.data){
                mapProduct[response.data[r].Product2Id] = response.data[r].Id;
            }
            var products = component.get("v.products");
            var productsToSave = [];
            for(var p in products){
                if(products[p].removed!=true){
                    products[p].sobjectType = 'OpportunityLineItem';
                    products[p].OpportunityId = component.get("v.recordId");
                    products[p].PricebookEntryId = mapProduct[products[p].Product2Id];
                    if(products[p].selectedBuildingOption == "Building"){
                        if(products[p].defaultValue && products[p].defaultValue.Geography__c && products[p].Building__c == products[p].defaultValue.Building__c){
                            products[p].Geography__c = products[p].defaultValue.Geography__c;
                        }else{
                            products[p].Geography__c = undefined;
                        }
                    }else{
                        if(products[p].defaultValue && products[p].defaultValue.Building__c && products[p].Geography__c == products[p].defaultValue.Geography__c){
                            products[p].Building__c = products[p].defaultValue.Building__c;
                        }else{
                            products[p].Building__c = undefined;
                        }
                    }
                    if(products[p].Family__c == 'Global Access' && !(products[p].Geography__c != undefined && products[p].Geography__c != "")){
                        products[p].Building__c = component.get("v.globalAccessBuilding") ? component.get("v.globalAccessBuilding").Id : '';
                    }
                    if(component.get("v.opportunity.CurrencyIsoCode").trim() == component.get("v.opportunityCurrency").trim()){
                        delete products[p].Product2Id;
                    }
                    delete products[p].Product2;
                    delete products[p].Id;
                    delete products[p].relatedProducts;
                    delete products[p].productCategories;
                    delete products[p].defaultValue;
                    delete products[p].option;
                    delete products[p].selectedBuildingOption;
                    productsToSave.push(products[p]);
                }
            }
            component.get("v.utils").execute("c.saveOpportunityProducts",{"opportunityId":component.get("v.recordId"),"lstProducts":productsToSave,"currencyCode":component.get("v.opportunityCurrency"), "confirmProduct":confirmProduct},function(response){
                component.find("utils").showSuccess('Products have been saved.');
                onsuccess();                
            },function(error){
                onerror(error);
            },component);
        },function(error){
            onerror(error);
        },component)
	},
    checkNullUndefineOrBlank : function(entity) {
        if(entity){
            if(entity != undefined && entity != null && entity != '')
                return true;
            else
                return false;
        } else
            return false;
	},
    saveOpportunityProducts : function(component, event, helper, confirmProduct ){
        helper.saveProducts(component, event, helper, confirmProduct, function(){
            helper.closeSaveProducts(component, event, helper);
            component.get("v.utils").hideProcessing();
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error, true, 20000);
        });
    },
    getBuilding : function(component,buildingName,onsuccess){
        component.get("v.utils").execute("c.getQueryResultForLabel",{"label":'Building', "filters": {"Name": buildingName}},function(building){
            if(building.data && building.data.length > 0){
                onsuccess(building.data[0]);
            }else{
                onsuccess(null);
            }
        },function(error){
            component.get("v.utils").showError(error);
        },component);
    },
    changeInProductFamily : function(opportunityLineItem){
        if(opportunityLineItem.Family__c=="Global Access"){
            opportunityLineItem.Building__c = undefined;
            opportunityLineItem.selectedBuildingOption="Geography";
            opportunityLineItem.option[0].disabled = true;
            opportunityLineItem.option[0].checked = false;
            opportunityLineItem.option[1].disabled = true;
            opportunityLineItem.option[1].checked = true;
            
        }else if(opportunityLineItem.Family__c=="PxWe"){
            opportunityLineItem.Building__c = undefined;
            opportunityLineItem.selectedBuildingOption="Geography";
            opportunityLineItem.option[0].disabled = true;
            opportunityLineItem.option[0].checked = false;
            opportunityLineItem.option[1].disabled = false;
            opportunityLineItem.option[1].checked = true;
            opportunityLineItem.Geography__c = opportunityLineItem.defaultValue && opportunityLineItem.defaultValue.Geography__c ? opportunityLineItem.defaultValue.Geography__c : null;
        }else{
            this.checkNullUndefineOrBlank(opportunityLineItem.Building__c) ? (opportunityLineItem.selectedBuildingOption = "Building", opportunityLineItem.Geography__c = undefined) : this.checkNullUndefineOrBlank(opportunityLineItem.Geography__c) ? (opportunityLineItem.selectedBuildingOption="Geography", opportunityLineItem.Building__c = undefined) : opportunityLineItem.selectedBuildingOption = "Building";
            opportunityLineItem.option[0].disabled = false;
            opportunityLineItem.option[0].checked = false;
            opportunityLineItem.option[1].disabled = false;
            opportunityLineItem.option[1].checked = false;
            opportunityLineItem.Building__c = opportunityLineItem.defaultValue && opportunityLineItem.defaultValue.Building__c ? opportunityLineItem.defaultValue.Building__c : null;
            opportunityLineItem.Geography__c = opportunityLineItem.defaultValue && opportunityLineItem.defaultValue.Geography__c ? opportunityLineItem.defaultValue.Geography__c : null;
        }
        return opportunityLineItem;
    },
    close : function(component, helper, event){
        component.get("v.utils").showConfirm("Are you sure you want to close the page?",function(){
        component.get("v.utils").closeTab();
        component.get("v.utils").redirectToUrl("/"+component.get("v.recordId"), "", true, false);
        });
    },
    closeSaveProducts : function(component, helper, event){
        component.get("v.utils").closeTab();
        component.get("v.utils").redirectToUrl("/"+component.get("v.recordId"), "", true, false);        
    },
    getProductCategoryChange:function(component, event, helper, category){
        var index = parseInt(event.target.id.split(":")[1]);
        var ProductCategory = category;
        var opportunityLineItem = component.get("v.products["+index+"]");
        opportunityLineItem.Product2Id = undefined;
        if(ProductCategory){
            var arrProducts = [];
            var productsForCategory = [];
            var products =  component.get("v.relatedProducts");
            var mapConvrates = component.get("v.mapConversionRates");
            (products[opportunityLineItem.Family__c] != null) ? arrProducts = (products[opportunityLineItem.Family__c]) : [];
            if(arrProducts.length){
            arrProducts.forEach(function(productForCategory) {
                                            if(productForCategory.Product_Category__c == category)
                                                productsForCategory.push(productForCategory);
                                        });
            }
            component.set("v.products["+index+"].Product_Category__c", category);
            if(productsForCategory.length == 1){
                component.set("v.products["+index+"].Product2Id", productsForCategory[0].Id);
                component.set("v.products["+index+"].QuantityUnitOfMeasure__c", productsForCategory[0].QuantityUnitOfMeasure);
                if(productsForCategory[0].PricebookEntries.records && productsForCategory[0].PricebookEntries.records.length > 0 && productsForCategory[0].PricebookEntries.records[0].UnitPrice){
                    component.set("v.products["+index+"].UnitPrice", mapConvrates[component.get("v.opportunityCurrency")] * productsForCategory[0].PricebookEntries.records[0].UnitPrice);
                }
            }
                component.set("v.products["+index+"].relatedProducts", productsForCategory);
            if(!(arrProducts[0].PricebookEntries.records) || arrProducts[0].PricebookEntries.records.length == 0){
                component.set("v.products["+index+"].invalidProduct", true);
            }else{
                component.set("v.products["+index+"].invalidProduct", false);
            } 
        }else{
            component.set("v.products["+index+"].relatedProducts", '');
            component.set("v.products["+index+"].Product_Category__c", '');
        }
    },
    getCurrencyPicklist : function(component, lstCurrency){
       if(lstCurrency && lstCurrency.length){
            let lstCurrencies = [];
            var mapCurrency = {};
            lstCurrency.forEach(function(currency){
                lstCurrencies.push({"label": currency["IsoCode"], "value": currency["IsoCode"].split("-")[0].trim()});
                mapCurrency[currency["IsoCode"].split("-")[0].trim()] = (currency["ConversionRate"]);
            });
           component.set("v.mapConversionRates", mapCurrency)
            return lstCurrencies;
        }
    },
    getPriceAccordingToConversion:function(component, event, helper) { 
        var products = component.get("v.products");
        var currency = event.target.value;
        var mapConvrates = component.get("v.mapConversionRates");
        var mapUnitprice = component.get("v.mapUnitPrice");
        for(var itr in products){
           var opportunityLineItem = component.get("v.products["+itr+"]");
           component.set("v.products["+itr+"].UnitPrice", mapConvrates[currency]*mapUnitprice[opportunityLineItem.Product2Id]);
        } 
    },
    scrollDown:function(component){
        setTimeout(function(){ 
            let element = document.getElementById("product-focus");
            element.scrollIntoView({
                behavior: "smooth"
            });
        }, 300);  
    }
})