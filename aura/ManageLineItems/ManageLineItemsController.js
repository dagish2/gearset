({
    doInit : function(component, event, helper) {
        component.set("v.utils", component.find("utils"));
        component.get("v.utils").showProcessing();
        component.get("v.utils").setTitle("Manage Products");
        component.get("v.utils").execute("c.getManageProducts",{"oppId":component.get("v.recordId")},function(response){
            var oppResponse = JSON.parse(response);
            if(oppResponse != null){
                if(JSON.parse(component.get("v.isFromCreateOpp"))){
                    oppResponse.isValidForManageProduct = JSON.parse(oppResponse.isValidForManageProduct).Success;
                }
                component.set("v.allowManageProduct", JSON.parse(oppResponse.isValidForManageProduct).Success);
                if(oppResponse.isValidForManageProduct){
                    helper.setDataFields(component, oppResponse.oppRec, function(){
                        var activeFamilies = [];
                        var mapRelatedData = {"relatedProducts":{},"productCategories":{}};
                        var mapOfUnitPrices = {};
                        var lstproduct2s = helper.checkNullUndefineOrBlank(oppResponse.lstproduct2s) ? oppResponse.lstproduct2s : [];
                        if(oppResponse.lstCurrencies.length > 0){
                            component.set("v.availableCurrencies", helper.getCurrencyPicklist(component, oppResponse.lstCurrencies));
                        }
                        helper.getProductDetails(component, lstproduct2s, activeFamilies, mapRelatedData, mapOfUnitPrices, function(){
                            component.set("v.activeFamilies", activeFamilies); 
                            component.set("v.relatedCategories", mapRelatedData.productCategories);
                            component.set("v.relatedProducts", mapRelatedData.relatedProducts);
                            component.set("v.opportunity", oppResponse.oppRec);                    
                            component.set("v.opportunityCurrency", oppResponse.oppRec.CurrencyIsoCode);
                            component.set("v.mapUnitPrice", mapOfUnitPrices);
                            
                            if(oppResponse.oppRec && oppResponse.oppRec.hasOwnProperty("attributes")){
                                delete oppResponse.oppRec["attributes"];
                            }
                            var lstOppLineItems = helper.checkNullUndefineOrBlank(oppResponse.oppRec.OpportunityLineItems)? oppResponse.oppRec.OpportunityLineItems.records :[];
                            var index = 0;
                            var defaultValues = {};
                            if(lstOppLineItems && lstOppLineItems.length){
                                lstOppLineItems.forEach(function(opportunityLineItem) {
                                    var productsForCategory =[];
                                    if(opportunityLineItem && opportunityLineItem.hasOwnProperty("attributes")){
                                        delete opportunityLineItem["attributes"];
                                    }
                                    if(mapRelatedData.relatedProducts.hasOwnProperty(opportunityLineItem.Product2.Family)){
                                        mapRelatedData.relatedProducts[opportunityLineItem.Product2.Family].forEach(function(productForCategory) {
                                            if(productForCategory.Product_Category__c == opportunityLineItem.Product_Category__c)
                                                productsForCategory.push(productForCategory);
                                        });
                                        opportunityLineItem.relatedProducts = productsForCategory;
                                    }
                                    if(mapRelatedData.productCategories.hasOwnProperty(opportunityLineItem.Product2.Family)){
                                        opportunityLineItem.productCategories = mapRelatedData.productCategories[opportunityLineItem.Product2.Family];
                                    }
                                    opportunityLineItem.Desired_Term_Length__c ? opportunityLineItem.Desired_Term_Length__c : opportunityLineItem.Desired_Term_Length__c = 1;
                                    opportunityLineItem.defaultValue = {
                                        "Building__c": helper.checkNullUndefineOrBlank(opportunityLineItem.Building__c)  ? opportunityLineItem.Building__c : "",
                                        "Geography__c": helper.checkNullUndefineOrBlank(opportunityLineItem.Geography__c) ? opportunityLineItem.Geography__c : ""                       
                                    };
                                    opportunityLineItem.option = [{"label":"Building", "value":"Building","disabled":false},{"label":"Geography", "value":"Geography","disabled":false}];
                                    opportunityLineItem = helper.changeInProductFamily(opportunityLineItem);
                                });
                                lstOppLineItems[lstOppLineItems.length-1].isLast = true;
                                component.set("v.products", lstOppLineItems);
                                component.set("v.productsCount", lstOppLineItems.length);
                                if(component.get("v.opportunity.Confirm_Products__c") != 'Confirmed')
                                {component.set("v.showConfirmProduct", true);}
                            }else{
                                if(helper.checkNullUndefineOrBlank(component.get("v.opportunity.Type__c")) && helper.checkNullUndefineOrBlank(mapRelatedData.productCategories[component.get("v.opportunity.Type__c")]) && mapRelatedData.productCategories[component.get("v.opportunity.Type__c")].length == 1){
                                    var productsForCategory =[];
                                    var mapConvrates = component.get("v.mapConversionRates");
                                    if(mapRelatedData.relatedProducts.hasOwnProperty(component.get("v.opportunity.Type__c"))){
                                        mapRelatedData.relatedProducts[component.get("v.opportunity.Type__c")].forEach(function(productForCategory) {
                                            if(productForCategory.Product_Category__c == mapRelatedData.productCategories[component.get("v.opportunity.Type__c")][0])
                                                productsForCategory.push(productForCategory);
                                        });
                                    }
                                }
                                var opportunityLineItem = {"CurrencyIsoCode":helper.checkNullUndefineOrBlank(component.get("v.opportunity.CurrencyIsoCode")) ? component.get("v.opportunity.CurrencyIsoCode") : "USD",
                                                             "Building__c":helper.checkNullUndefineOrBlank(component.get("v.opportunity.Building__c")) ? component.get("v.opportunity.Building__c") : "",
                                                             "Geography__c":helper.checkNullUndefineOrBlank(component.get("v.opportunity.Geography__c")) ? component.get("v.opportunity.Geography__c") : "",
                                                             "isLast":true,
                                                             "defaultValue":{
                                                                 "Building__c": helper.checkNullUndefineOrBlank(component.get("v.opportunity.Building__c")) ? component.get("v.opportunity.Building__c") : "",
                                                                 "Geography__c": helper.checkNullUndefineOrBlank(component.get("v.opportunity.Geography__c")) ? component.get("v.opportunity.Geography__c") : ""                                                 
                                                             },
                                                             "Is_Primary_Product__c":true,
                                                             "option":[{"label":"Building", "value":"Building","disabled":false},{"label":"Geography", "value":"Geography","disabled":false}],
                                                             "selectedBuildingOption":"Building",
                                                             "Desired_Term_Length__c": helper.checkNullUndefineOrBlank(component.get("v.opportunity.Desired_Term_Length_in_months__c")) ? component.get("v.opportunity.Desired_Term_Length_in_months__c") : 1,
                                                             "productCategories":helper.checkNullUndefineOrBlank(mapRelatedData.productCategories[component.get("v.opportunity.Type__c")]) ? mapRelatedData.productCategories[component.get("v.opportunity.Type__c")] : [],
                                                             "Family__c":(helper.checkNullUndefineOrBlank(component.get("v.opportunity.Type__c")) && helper.checkNullUndefineOrBlank(mapRelatedData.productCategories[component.get("v.opportunity.Type__c")]) )? component.get("v.opportunity.Type__c") : "",
                                                             "Quantity":helper.checkNullUndefineOrBlank(component.get("v.opportunity.Requirement_Quantity__c")) ? component.get("v.opportunity.Requirement_Quantity__c") : "",
                                                             "Product_Category__c":helper.checkNullUndefineOrBlank(mapRelatedData.productCategories[component.get("v.opportunity.Type__c")]) ? (mapRelatedData.productCategories[component.get("v.opportunity.Type__c")].length == 1) ? mapRelatedData.productCategories[component.get("v.opportunity.Type__c")][0] : "" : "",
                                                             "relatedProducts": helper.checkNullUndefineOrBlank(productsForCategory) ? productsForCategory : [] ,
                                                             "Product2Id" : helper.checkNullUndefineOrBlank(productsForCategory) ? productsForCategory.length == 1 ? productsForCategory[0].Id : "" : "",
                                                             "QuantityUnitOfMeasure__c" : helper.checkNullUndefineOrBlank(productsForCategory) ? productsForCategory.length == 1 ? productsForCategory[0].QuantityUnitOfMeasure : "" : "",
                                                             "UnitPrice" : helper.checkNullUndefineOrBlank(productsForCategory) ? productsForCategory.length == 1 ? mapConvrates[component.get("v.opportunityCurrency")] *productsForCategory[0].PricebookEntries.records[0].UnitPrice : "" : ""
                                                            }
                                opportunityLineItem = helper.changeInProductFamily(opportunityLineItem);
                                component.set("v.products", [opportunityLineItem]);
                                component.set("v.productsCount", 1);
                            }
                            $A.enqueueAction(component.get('c.changePrimaryProduct'));
                            component.get("v.utils").hideProcessing();
                        });
                    });
                }
            }
        },function(error){
            component.get("v.utils").hideProcessing();
            component.get("v.utils").showError(error);
        },component);
        if(!component.get("v.globalAccessBuilding")){
            helper.getBuilding(component,"WeWork Global Access",function(globalAccessBuilding){
                component.set("v.globalAccessBuilding",globalAccessBuilding);
            });
        }
    },
    confirmProduct:function(component, event, helper){
        component.callManageProduct(true);
    },
    checkUnitPrice:function(component, event, helper){
        let products = component.get("v.products"); 
        component.set("v.isValidUnitPrice", false);
        for(let index in products){
            let unitPrice = products[index].UnitPrice ? parseFloat(products[index].UnitPrice) : 0;
            if(!unitPrice || unitPrice < 0.1){
                component.set("v.isValidUnitPrice", true);
                break;
            }
        } 
    },
    addProduct:function(component, event, helper){
        var products = component.get("v.products");
        products.push({"CurrencyIsoCode":helper.checkNullUndefineOrBlank(component.get("v.opportunity.CurrencyIsoCode"))?component.get("v.opportunity.CurrencyIsoCode"):'USD',
                       "option":[{"label":"Building", "value":"Building","disabled":false},{"label":"Geography", "value":"Geography","disabled":false}],
                       "selectedBuildingOption":"Building","Desired_Term_Length__c":1,"productCategories":[], "relatedProducts":[]
                      });
        var isLastfound = false;
        for(var i=products.length-1;i>=0;i--){
            delete products[i].isLast;
            if(!isLastfound && products[i].removed!=true){
                products[i].isLast = true;
                isLastfound = true;
            }
        }
        component.set("v.products", products);
        component.set("v.productsCount",component.get("v.productsCount")+1);
        helper.scrollDown(component);
    },
    removeProduct:function(component, event, helper){
        var products = component.get("v.products");
        var index = parseInt(event.currentTarget.id.split(":")[1]);
        if(!products[index].Is_Primary_Product__c){
            products[index].removed = true;
            var isLastfound = false;
            for(var i=products.length-1;i>=0;i--){
                delete products[i].isLast;
                if(!isLastfound && products[i].removed!=true){
                    products[i].isLast = true;
                    isLastfound = true;
                }
            }
            component.set("v.products",products);
            var errors = JSON.parse(JSON.stringify(component.get("v.errors")));
            for(var i in errors.mapComponents){
                if(i.endsWith(index)){
                    console.log(i);
                    delete errors.mapComponents[i];
                    delete errors.mapValidations[i];
                    console.log('errors:::'+errors);
                }
            }
            component.set("v.productsCount",component.get("v.productsCount")-1);
            component.set("v.errors",errors);
            component.get("v.utils").hideProcessing();
        }else{
            component.get("v.utils").showError("Primary Product can not be removed");
        }
    },
    manageProducts:function(component, event, helper){
        var isPrimaryProduct = false;
        var ismoreThanOnePrimaryProduct = false;
        var confirmProduct = false;
        var products = component.get("v.products");
        if(event.target == undefined ){
        var params = event.getParam('arguments');
        if (params) {
           confirmProduct = params.confirmProduct;
        }
        }
        for(var index in products){
            if(products[index].Is_Primary_Product__c){
                if(isPrimaryProduct){
                    isPrimaryProduct = false;
                    ismoreThanOnePrimaryProduct = true;
                    component.get("v.utils").showError("You can't select more than one Primary product.");
                    break;
                }
                isPrimaryProduct = true;
            }
        }
        if(isPrimaryProduct){
            component.get("v.utils").showConfirm("Are you sure you want to save the products?",function(){
            component.get("v.utils").showProcessing();
            var products = component.get("v.products");
            var isGlobalAccess = false;
            for(var p in products){
                if(products[p].Family__c == 'Global Access'){
                    isGlobalAccess = true;
                    break;
                }
            }
            if(isGlobalAccess){
                if(component.get("v.globalAccessBuilding")){
                    helper.saveOpportunityProducts(component, event, helper, confirmProduct);
                }else{
                    helper.getBuilding(component,"WeWork Global Access",function(globalAccessBuilding){
                        component.set("v.globalAccessBuilding",globalAccessBuilding);
                        helper.saveOpportunityProducts(component, event, helper, confirmProduct);
                    });
                }
            }else{
                helper.saveOpportunityProducts(component,event,helper, confirmProduct) 
            }
        })
        }else if(!ismoreThanOnePrimaryProduct){
            component.get("v.utils").showError("Please select Primary Product");
        }
    },
    close : function(component, event, helper){
        helper.close(component, event, helper);
    },
    getProductCategoryChange:function(component,event,helper){
        helper.getProductCategoryChange(component, event, helper, event.target.value)
    },
    getProductFamilyChange :function(component,event,helper){
        var index = parseInt(event.target.id.split(":")[1]);
        var opportunityLineItem = component.get("v.products["+index+"]");
        opportunityLineItem.Product2Id = null;
        opportunityLineItem.Product_Category__c = undefined;
        opportunityLineItem.productCategories = [];
        opportunityLineItem.relatedProducts = [];
        opportunityLineItem.Quantity = null;
        opportunityLineItem.QuantityUnitOfMeasure__c = "";
        opportunityLineItem.UnitPrice = undefined;
        opportunityLineItem.Family__c = event.target.value;
        component.set("v.products["+index+"].family",opportunityLineItem.Family__c);
        component.set("v.products["+index+"].UnitPrice", "");
        if(opportunityLineItem.Family__c){
            opportunityLineItem = helper.changeInProductFamily(opportunityLineItem);
            component.set("v.products["+index+"]",opportunityLineItem); 
            var categories = component.get("v.relatedCategories");
                var arrProductcategories = [];
                helper.checkNullUndefineOrBlank(categories[opportunityLineItem.Family__c]) ? arrProductcategories = (categories[opportunityLineItem.Family__c]) : [];
                if(arrProductcategories.length == 1){
                    component.set("v.products["+index+"].Product_Category__c", arrProductcategories[0]);
                    helper.getProductCategoryChange(component, event, helper, arrProductcategories[0]);
                }
                component.set("v.products["+index+"].productCategories", arrProductcategories); 
        }else{
            component.set("v.products["+index+"].productCategories", []);
            component.set("v.products["+index+"].QuantityUnitOfMeasure__c", undefined);
            component.set("v.products["+index+"].UnitPrice", undefined);
        }
    }, 
    getProductChange:function(component,event,helper){
        var index = parseInt(event.target.id.split(":")[1]);
        var prouctId = event.target.value;
        var mapConvrates = component.get("v.mapConversionRates");
        var mapUnitprice = component.get("v.mapUnitPrice");
        component.set("v.products["+index+"].invalidProduct",false);
        component.set("v.products["+index+"].Product2Id", prouctId);
        if(prouctId){
               var products =  component.get("v.relatedProducts")[component.get("v.products["+index+"].Family__c")];
               var product = {};
               products.forEach(function(productForCategory) {
                   if(productForCategory.Id == prouctId){
                      product = productForCategory;
                   }
               });
                component.set("v.products["+index+"].QuantityUnitOfMeasure__c", product.QuantityUnitOfMeasure);
                if(product.PricebookEntries && product.PricebookEntries.records.length > 0 && product.PricebookEntries.records[0].UnitPrice){
                    component.set("v.products["+index+"].UnitPrice", mapConvrates[component.get("v.opportunityCurrency")]*mapUnitprice[prouctId]);
                }
                if(!(product.PricebookEntries) || product.PricebookEntries.records.length==0){
                    component.set("v.products["+index+"].invalidProduct", true);
                }else{
                    component.set("v.products["+index+"].invalidProduct", false);
                }
        }else{
            component.set("v.products["+index+"].Product2Id", '');
            component.set("v.products["+index+"].QuantityUnitOfMeasure__c", undefined);
            component.set("v.products["+index+"].UnitPrice", undefined);
        }
    },     
    changeBuildingOption : function(component, event, helper) { 
        var index = parseInt(event.target.id.split(":")[1]);
        if(event.target.value=="Building"){
            component.set("v.products["+index+"].Building__c",component.get("v.products["+index+"].defaultValue.Building__c"));
            component.set("v.products["+index+"].Geography__c",undefined);
        } else{
            component.set("v.products["+index+"].Building__c",undefined);
            component.set("v.products["+index+"].Geography__c",component.get("v.products["+index+"].defaultValue.Geography__c"));
        }
    },
    getPriceAccordingToConversion: function(component, event, helper) { 
        helper.getPriceAccordingToConversion(component, event, helper);
    },
    changePrimaryProduct : function(component, event, helper) {
        var index = parseInt(event.target.id.split(":")[1]);
        var products = component.get("v.products");
        for(var itr in products){
            if(index != itr && products[itr].Is_Primary_Product__c){
                products[itr].Is_Primary_Product__c = false;
            }
        }
        component.set("v.products",products);
    }
})