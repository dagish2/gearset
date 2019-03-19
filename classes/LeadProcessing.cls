/*****************************************************************************************************************************
  Yet to do
  1. Modularize the code into multiple method calls.
  2. Put comments for each method call to establish references.
  3. Get it reviewed from the peer team.
******************************************************************************************************************************
    Author      :  Krishana Tupe  
    Description :  This class contains the business logic related to Lead Routing and Conversion
    History     :  -- 
    
    ----------------------------------------------------------------------------------------------------------------------------------
    VERSION                 DATE            ISSUE       AUTHOR                          DETAIL
    1                       29 Nov 2018      -     		Krishana Tupe                   Initial Developement    
******************************************************************************************************************************/
public class LeadProcessing {
       
/************************************************************************************************************************************
        Author              :   Krishana Tupe
        Description         :   This method is called from Process Builder to Process Leads from Hold-Back to Lead Assignment
								after unomy and Lead Score updation(enrichment)
      	Created Date  		:   27 Nov 2018        
 *************************************************************************************************************************************/
    @InvocableMethod
    public static void routeLeadsToHoldBack(List<Lead> lstLeadsToRoute){
        if(lstLeadsToRoute != null && lstLeadsToRoute.size() > 0){
            LeadConverterHelper.isInsert = false;
            LeadConverterHelper.manageLead(lstLeadsToRoute); 
        }
    }
}