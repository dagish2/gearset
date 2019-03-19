/**
 * Common methods
 * 
 * @author 	Ivan Tadic
 * @date  	06/09/2013
 */
public with sharing class Common {

	/**
	 * Split Separated string to list
	 * 
	 * @author 	Ivan Tadic
	 * @date  	06/09/2013
	 * 
	 * @param   Input String
	 * @param   Separator
	 */
	public static List<string> splitStringToList(string InputString, string Separator){
		List<string> result = new List<string>();
		if(string.isBlank(InputString)) return result;
		String[] sArray = InputString.split(Separator, -1);
		for(integer i = 0; i < sArray.size(); i++){
			result.add(sArray[i].trim());
		}
		return result;
	}
	
	/**
	 * Split Separated string to set
	 * 
	 * @author 	Ivan Tadic
	 * @date  	06/09/2013
	 * 
	 * @param   Input String
	 * @param   Separator
	 */
	public static Set<string> splitStringToSet(string InputString, string Separator){
		Set<string> result = new Set<string>();
		if(string.isBlank(InputString))  return result;
		List<string> sList = splitStringToList(InputString, Separator);
		for(string s : sList){
			result.add(s);
		}
		return result;
	}
	
	/**
	 * Gets comma separated list of SObject fields
	 *
	 * @author 	Ivan Tadic
	 * @date  	06/09/2013
	 * 
	 * @param   SObject name
	 */
	public static String getSobjectFields(String so)
	{
		String fieldString;

		SObjectType sot = Schema.getGlobalDescribe().get(so);
		if (sot == null) return null;

		List<Schema.SObjectField> fields = sot.getDescribe().fields.getMap().values();

		fieldString = fields[0].getDescribe().LocalName;
		for (Integer i = 1; i < fields.size(); i++)
		{
			fieldString += ',' + fields[i].getDescribe().LocalName;
		}
		return fieldString;
	}
	
	
	

}