/* Created by @dipak.pawar@enzigma.in on 12 May 2016
* This class should contain all the methods related to Date
*/

public class DateUtilities {	
	
	/*
   Comment   : This method used for check the day is weekend or not.
   Issue     : 
   Author    : Dipak Pawar 
   Date      : 13 May 2016 */
	public static Boolean isWeekendDay (Date dateParam) 
	{
      try 
      {
      	boolean result    = false;
	    Date startOfWeek  = dateParam.toStartOfWeek();
	    integer dayOfWeek = dateParam.day() - startOfWeek.day();
	    result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
	    return result;
      }
      catch(Exception ex) 
      {
      	Debug.log(ex.getMessage());
      	return null;
      }      
   }
   
   /*
   Comment   : This method used for check the day of week.
   Issue     : 
   Author    : Dipak Pawar 
   Date      : 17 May 2016 */
	public static Integer dayOfWeek(Date dateParam) 
	{
        try 
        {
        	Integer day = 0;
	        Date startOfWeek  = dateParam.toStartOfWeek();
			day = dateParam.day() - startOfWeek.day();
			
            //Changes made by Amol
            if(day < 0)
			{
			   day = ( startOfWeek.day() - (startOfWeek.day() - dateParam.day()));
			}
			
			Debug.log('day::'+day);
	        return day;
        }
        catch (Exception ex) 
        {
        	Debug.log(ex.getMessage());
        	return null;
        }
    }
	
	/*
   Comment   : This method used for add business days into date provided as givenDate.
   Issue     : ST-293
   Author    : Dipak Pawar 
   Date      : 13 May 2016
   Modified By  : Krishana Tupe. When Day is Saturday.
*/
	public static Date addBusinessDays (Date today, Integer days) 
	{
		/*try 
		{
			if (daysToAdd < 0) 
			{
        		Debug.log('days cannot be negative');
    		}
    		Debug.log('Test : givenDate ::: ' + givenDate);
    		if (daysToAdd == 0) 
    		{
        		return givenDate;
    		}
    		
    		Integer dayOfWeek = dayOfWeek(givenDate);
    		Debug.log('Test : dayOfWeek ::: ' + dayOfWeek);     
    		if (dayOfWeek == 6)	
    		{
        		givenDate = givenDate.addDays(2);
        		daysToAdd -= 1;
    		}
		    else if (dayOfWeek == 0)
		    {
		        givenDate = givenDate.addDays(1);
		        daysToAdd -= 1;
		    }
		    Debug.log('Test : givenDate 2::: ' + givenDate);
		    givenDate = givenDate.addDays(daysToAdd / 5 * 7);		       
		    Integer extraDays = Math.mod(daysToAdd , 5);
	
		    if (Integer.valueOf(dayOfWeek(givenDate) + extraDays) > 5) 
		    {
		        extraDays += 2;
		    }
            Debug.log('Test : givenDate 3::: ' + givenDate);
            Debug.log('Test : givenDate.addDays(extraDays) ::: ' + givenDate.addDays(extraDays));
    		return givenDate.addDays(extraDays);
		}
		catch (Exception ex) 
		{
				Debug.log(ex.getMessage());
				return null;
		}*/
        try{
            Date result;
            if(days == 0){
                result = today;
                Debug.Log('Today==>'+result);
            } else if(days > 0){
                Date stamp = Date.newInstance(1900, 1, 7);
                Integer diff = stamp.daysBetween(today);
                Integer modVal = Math.mod(diff, 7);                
                if(modVal == 0){
                    result = today + days + Integer.valueOf(Math.floor((days - 1) / 5) * 2); 
                } else if(modVal == 1){    
                    result = today + days + Integer.valueOf(Math.floor(days  / 5) * 2);
                } else if(modVal == 2){
                    result = today + days + Integer.valueOf(Math.floor((days + 1)  / 5) * 2);
                } else if(modVal == 3){
                    result = today + days + Integer.valueOf(Math.floor((days + 2)  / 5) * 2);
                } else if(modVal == 4){
                    result = today + days + Integer.valueOf(Math.floor((days + 3)  / 5)) * 2;
                } else if(modVal == 5){
                    result = today + days + Integer.valueOf(Math.floor((days + 4)  / 5)) * 2;
                } else if(modVal == 6){
                    //result = today - ((days > 0) ? 1 : 0) + days + Integer.valueOf(Math.ceil(days / 5) * 2);
                    result = today + ((days <= 4) ? 1 :Integer.valueOf(Math.floor(days / 5) * 2) + 1)+ days ;
                }                
            }
            return result;
        } catch(Exception exc){
            Debug.Log('exc :: '+exc);
            return null;
        }
	}
	
    /*
   Comment   : This method used for find next business days from date provided as givenDate.
   Issue     : ST-294
   Author    : Dipak Pawar 
   Date      : 13 May 2016 */
	public static Date getNextBusinessDay (Date givenDate) 
	{
		try 
		{
			Date getNextBusinessDate;
			//if given day is weekend day then returns the same date.
			if(isWeekendDay(givenDate)) 
			{	
                Debug.log('givenDate ::'+givenDate);
				getNextBusinessDate = givenDate;
			}
			//if given day is business day then returns the next business day.
			else 
			{
                getNextBusinessDate = addBusinessDays (givenDate, 1);
			}
			return getNextBusinessDate;
		}
		catch (Exception ex) 
		{
			Debug.log(ex.getMessage());
			return null;
		}
	}
	/*
   Comment   : This method used for find next business days from date provided as givenDate.
   Issue     : CSI-411
   Author    : Samadhan Kadam
   Date      : 16 Jan 2018 */
	 public static String getDateTime (DateTime dt,String formatString,String TimeZone) {
        String signedOn =  DateTime.valueOf(dt).format(formatString,TimeZone);
        system.debug('Converted signedOn Date Instring==> '+signedOn);
        signedOn = signedOn.replace('/', '-');
        return signedOn;
    }
}