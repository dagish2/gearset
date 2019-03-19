({
    getLeadInfo:function(component,onsuccess){
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Salutation,Company,Email,Phone,Cleansed_Company_Name__c,Account__c From Lead Where Id='"+component.get("v.leadId")+"'"},function(response){
            component.set("v.entity",{"name":response[0].Name,"email":response[0].Email,"company":response[0].Company,"phone":response[0].Phone,"cleansedCompany":response[0].Cleansed_Company_Name__c,"parentAccountId":response[0].Account__c});
            onsuccess();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    getContactInfo:function(component,onsuccess){
        component.find("utils").execute("c.getQueryData",{"query":"Select Id,Name,Salutation,Email,Phone,Account.Name,Account.Cleansed_Account_Name__c,Account.Cleansed_Unomy_Company_Name__c From Contact Where Id='"+component.get("v.contactId")+"'"},function(response){
            component.set("v.entity",{"title":response[0].Salutation,"email":response[0].Email,"company":response[0].Account?response[0].Account.Name:undefined,"phone":response[0].Phone,"cleansedCompany":response[0].Account?response[0].Account.Cleansed_Account_Name__c:undefined,"cleansedUnomyCompany":response[0].Account?response[0].Account.Cleansed_Unomy_Company_Name__c:undefined});
            onsuccess();
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    
    getPotentialRecords: function (companyNames,email,records,parentId) {
        var potentialRecords = [];
        for(var r in records){
            var record = {};
            record.Id = records[r].Id;
            if(records[r].RecordType){
                record.Segment = records[r].RecordType.Name;
            }
            record.Account = records[r].Name;
            record.AccountType = records[r].Account_Type__c;
            record.AccountId = records[r].Id;
            record.Owner = records[r].Owner.Name;
            record.OwnerId = records[r].Owner.Id;
            record.IdStatus = records[r].ID_Status2__c;
            record.CreatedDate = records[r].CreatedDate;
            //record.NumberOfFullTimeEmployees = records[r].Number_of_Full_Time_Employees__c;
            if(records[r].Primary_Member__r){
                record.PrimaryMember = records[r].Primary_Member__r.Name;
                record.PrimaryMemberId = records[r].Primary_Member__r.Id;
                record.Email = records[r].Primary_Member__r.Email;
            }
            else{
                record.PrimaryMember = '';
                record.PrimaryMemberId = '';
                record.Email = '';
            }
            record.Country = records[r].BillingCountry?records[r].BillingCountry:records[r].Unomy_Location_Country__c;
            record.State = records[r].BillingState?records[r].BillingState:records[r].Unomy_Location_State__c;
            record.City = records[r].BillingCity?records[r].BillingCity:records[r].Unomy_Location_City__c;
            if(records[r].ParentId && records[r].ParentId==parentId){
                record.Source = "Parent Account";
            }else if(records[r].Cleansed_Account_Name__c && companyNames.includes(records[r].Cleansed_Account_Name__c)){
                record.Source = "Company Name";
            }else if(records[r].Cleansed_Unomy_Company_Name__c && companyNames.includes(records[r].Cleansed_Unomy_Company_Name__c)){
                    record.Source = "Unomy Company Name";
            }else if(email && records[r].Website && records[r].Website.includes(email.split("@")[1])){
                        record.Source = "Website";
            }else if(email && records[r].Primary_Member__r && records[r].Primary_Member__r.Email && records[r].Primary_Member__r.Email.includes("@"+(email.split("@")[1]))){
                            record.Source = "Primary Member Email Domain";
            }           
            potentialRecords.push(record);
        }
        return potentialRecords;
    },
    getAccounts:function(component,companyNames,email,parentId,onsuccess){
        var helper = this;
        var companies = [];
        for(var c in companyNames){
            if(companyNames[c]){
                companies.push("'"+ component.find("utils").addSlashes(companyNames[c]) +"'");
            }
        }
        var helper = this;
        var domain;
        if(email){
            domain = email.split("@")[1];
        }
        var settingQuery = "Select Id,Data__c from Setting__c Where Name='PublicDomainSettings'";
        component.find("utils").execute("c.getQueryData",{"query":settingQuery},function(response){           
            var excludeDomains = "";
            if(response && response[0] && response[0].hasOwnProperty("Data__c")){
                var lstExcludeDomains = JSON.parse(response[0].Data__c);
                if(lstExcludeDomains && lstExcludeDomains.length >0){
                    excludeDomains ="NOT (";
                    lstExcludeDomains.forEach(function(domain){
                        excludeDomains+=" Primary_Member__r.Email LIKE '%@"+helper.addSlashes(domain)+"%' OR"
                    })
                    excludeDomains=excludeDomains.slice(0,-3);
                    excludeDomains+=")";
                }
                
            }
            var query = "Select Id,Name,Owner.Id,CreatedDate,Owner.Name,ID_Status2__c,Account_Type__c,RecordType.Name,Primary_Member__r.Name,Primary_Member__r.Email,BillingCountry,BillingState,BillingCity,Unomy_Location_Country__c,Unomy_Location_State__c,Unomy_Location_City__c,Cleansed_Account_Name__c,Cleansed_Unomy_Company_Name__c,Website,ParentId From Account";
            if(companies.length>0 || domain){
                query += " WHERE ";
                if(component.get("v.entity").hasOwnProperty("parentAccountId") && component.get("v.entity.parentAccountId")!=undefined){
                    query += "( ParentId='"+component.get("v.entity.parentAccountId")+"' AND (Account_Type__c=\'Bill\' OR Account_Type__c=\'\') ) OR (";
                }
                query +="(Account_Type__c=\'Bill\' OR Account_Type__c = \'\') AND ( ID_Status2__c = \'inactive\' ) AND (";
            }
            if(companies.length>0){
                query += " Cleansed_Account_Name__c IN ("+companies.join(",")+")";
                query += " OR Cleansed_Unomy_Company_Name__c IN ("+companies.join(",")+")";
            }
            if(companies.length>0 && domain){
                query += ' OR'
            }
            if(domain){
                query += " Website like '%"+helper.addSlashes(domain)+"%'";
                query += " OR Primary_Member__r.Email like '%@"+helper.addSlashes(domain)+"%'";
            }
            if(excludeDomains!=""){
                query += ") AND ("+excludeDomains+")";
            }
            if(component.get("v.entity").hasOwnProperty("parentAccountId") && component.get("v.entity.parentAccountId")!=undefined){
                query += " )";
            }
            console.log("query:" + query);
            component.find("utils").execute("c.getQueryData",{"query":query},function(response){
                var records = component.get("v.records");                
                records = helper.getPotentialRecords(companyNames,email,response,parentId);
                var potentialRecords = [];
                for(var r in records){
                    if(records[r].Source=='Parent Account' && records[r].AccountType=='Bill'){
                        potentialRecords.push(records[r]);
                    }
                }
                for(var r in records){
                    if(records[r].Source=='Parent Account' && !records[r].AccountType){
                        potentialRecords.push(records[r]);
                    }
                }
                for(var r in records){
                    if(records[r].Source!='Parent Account'){
                        potentialRecords.push(records[r]);
                    }
                }
                onsuccess(potentialRecords);
            },function(error){
                component.find("utils").hideProcessing();
                component.find("utils").showError(error);
            })
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        }) 
    },
    getUserProfileInfo:function(component,helper,onsuccess){
        var showPage = false;
        component.find("utils").execute("c.getUserProfileInfo",{},function(response){
            var info = JSON.parse(response)[0];
            helper.getAccountSelectorSetting(component,function(profiles){
                if(profiles && profiles.length > 0 && info && profiles.map(r => r.toLowerCase()).indexOf(info.Name.toLowerCase()) == -1)
                    showPage =true;
                onsuccess(showPage);
            })
            
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    getAccountSelectorSetting:function(component,onsuccess){
        var query = "SELECT Name,Data__c FROM Setting__c WHERE Name='AccountSelectorSettings'";
        component.find("utils").execute("c.getQueryData",{"query":query},function(response){
            var profiles = JSON.parse(response[0].Data__c).Profiles;
            onsuccess(profiles);
        },function(error){
            component.find("utils").hideProcessing();
            component.find("utils").showError(error);
        })
    },
    addSlashes:function(str){
        str = str.split("'").join("");
        str = str.split('"').join("");
        str = str.split("\\").join("");
        return str;
    }
})