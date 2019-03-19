public class LocationHelper {
    public static Map<String,Id> mapCountries;
    public static Map<String,Id> mapStates;
    public static Map<String,Id> mapCities;
    
    public class LocationHelperException extends Exception{}
    
    public static Id getMarketByCountry(String country){
        try{
            if(mapCountries==null){
                mapCountries = new Map<String,Id>();
                for(Country__c c:[Select Id,Name,Portfolio__c From Country__c]){
                    if(c.Name != null){
                        mapCountries.put(c.Name.toLowerCase(),c.Portfolio__c);  
                    }                  
                }
            }
            Debug.log('mapCountries====='+mapCountries);
            return mapCountries.get(country); 
        } catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LocationHelper','getMarketByCountry','country : '+country,pEx)
            );
            throw new LocationHelperException(pEx.getMessage());
            return null;
        }        
    }
    public static Id getMarketByState(String state){
        try{
            if(mapStates==null){
                mapStates = new Map<String,Id>();
                for(State__c s:[Select Id,Name,Portfolio__c From State__c]){
                    if(s.Name != null){
                        mapStates.put(s.Name.toLowerCase(),s.Portfolio__c);                        
                    }
                }
            }
            return mapStates.get(state);  
        }catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LocationHelper','getMarketByState','state : '+state,pEx)
            );
            throw new LocationHelperException(pEx.getMessage());
            return null;
        }
    }
    public static Id getMarketByCity(String city){
        try{
            if(mapCities==null){
                mapCities = new Map<String,Id>();
                for(City__c c:[Select Id,Name,Portfolio__c From City__c]){
                    if(c.Name != null){
                        mapCities.put(c.Name.toLowerCase(),c.Portfolio__c);
                    }
                }
            }
            return mapCities.get(city);  
        }catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LocationHelper','getMarketByCity','city : '+city,pEx)
            );
            throw new LocationHelperException(pEx.getMessage());
            return null;
        } 
    }
    public static Id getMarketByHQ(Account acc){
        try{
            Debug.log('acc====='+acc);
            if(acc.BillingCountry!=null && getMarketByCountry(String.valueOf(acc.BillingCountry).toLowerCase())!=null){
                return getMarketByCountry(String.valueOf(acc.BillingCountry).toLowerCase());
            }else if(acc.BillingState !=null && getMarketByState(String.valueOf(acc.BillingState).toLowerCase())!=null){
                return getMarketByState(String.valueOf(acc.BillingState).toLowerCase());
            }else if(acc.BillingCity!=null && getMarketByCity(String.valueOf(acc.BillingCity).toLowerCase())!=null){
                return getMarketByCity(String.valueOf(acc.BillingCity).toLowerCase());
            }else if(acc.Unomy_Location_Country__c!=null && getMarketByCountry(String.valueOf(acc.Unomy_Location_Country__c).toLowerCase()) !=null){
                return getMarketByCountry(String.valueOf(acc.Unomy_Location_Country__c).toLowerCase());
            }else if(acc.Unomy_Location_State__c!=null && getMarketByState(String.valueOf(acc.Unomy_Location_State__c).toLowercase()) !=null){
                return getMarketByState(String.valueOf(acc.Unomy_Location_State__c).toLowercase());
            }else if(acc.Unomy_Location_City__c!=null && getMarketByCity(String.valueOf(acc.Unomy_Location_City__c).toLOwerCase()) !=null){
                return getMarketByCity(String.valueOf(acc.Unomy_Location_City__c).toLOwerCase());
            }else{
                return null;
            }  
        }catch(Exception pEx) {          
            new ApexDebugLog().createLog( 
                new ApexDebugLog.Error('LocationHelper','getMarketByHQ','acc : '+JSON.serialize(acc),pEx)
            );
            throw new LocationHelperException(pEx.getMessage());
            return null;
        } 
    }
}