/* Created by @dipak.pawar@enzigma.in on 12 May 2016
* This class should contain all the test methods related to Date 
*/

@isTest
private class DateUtilitiesTest
{
    @isTest
    public static void addBusinessDaysTest() 
    {
        //For add 0 business day into date
        Date dateParam0 = Date.newInstance(2016, 5, 14);
        System.assertEquals(Date.newInstance(2016, 5, 14), DateUtilities.addBusinessDays(dateParam0, 0));
        
        //For add 1 business day into date
        //Date dateParam = Date.newInstance(2016, 5, 14);
        //System.assertEquals(Date.newInstance(2016, 5, 16), DateUtilities.addBusinessDays(dateParam, 1));
        
        //For add 1 business day into date
        Date dateParam1 = Date.newInstance(2016, 5, 15);
        System.assertEquals(Date.newInstance(2016, 5, 16), DateUtilities.addBusinessDays(dateParam1, 1));
        
        //For add 2 business days into date
        Date dateParam2 = Date.newInstance(2016, 5, 13);
        System.assertEquals(Date.newInstance(2016, 5, 17), DateUtilities.addBusinessDays(dateParam2, 2));
        
        //For add 3 business days into date
        Date dateParam3 = Date.newInstance(2016, 5, 13);
        System.assertEquals(Date.newInstance(2016, 5, 18), DateUtilities.addBusinessDays(dateParam3, 3));
        
        //For add 4 business days into date
        Date dateParam4 = Date.newInstance(2016, 5, 17);
        System.assertEquals(Date.newInstance(2016, 5, 23), DateUtilities.addBusinessDays(dateParam4, 4));
        
        //For add 10 business day into date
        Date dateParam5 = Date.newInstance(2016, 5, 17);
        System.assertEquals(Date.newInstance(2016, 5, 31), DateUtilities.addBusinessDays(dateParam5, 10));
        
        //For add 20 business day into date
        Date dateParam6 = Date.newInstance(2016, 5, 17);
        System.assertEquals(Date.newInstance(2016, 6, 14), DateUtilities.addBusinessDays(dateParam6, 20));
        
        //For add 40 business day into date
        Date dateParam7 = Date.newInstance(2016, 5, 17);
        System.assertEquals(Date.newInstance(2016, 7, 12), DateUtilities.addBusinessDays(dateParam7, 40));
        
        System.assertEquals(null, DateUtilities.addBusinessDays(null, null));        
    }
    
    
    @isTest
    public static void getNextBusinessDayTest() 
    {
        //For next working day.
        Date dateParam1 = Date.newInstance(2016, 5, 16);
        System.assertEquals(Date.newInstance(2016, 5, 17), DateUtilities.getNextBusinessDay(dateParam1));
        
        //For next business day in upcoming week.
        Date dateParam2 = Date.newInstance(2016, 5, 13);
        System.assertEquals(Date.newInstance(2016, 5, 16), DateUtilities.getNextBusinessDay(dateParam2));
        
        //For weekend day returns same day.
        Date dateParam3 = Date.newInstance(2016, 5, 14);
        System.assertEquals(Date.newInstance(2016, 5, 14), DateUtilities.getNextBusinessDay(dateParam3));
        
        System.assertEquals(null, DateUtilities.getNextBusinessDay(null));
    }
    
     @isTest
    public static void dayOfWeekTest() 
    {
        System.assertEquals(null,DateUtilities.dayOfWeek(null));
    }
    
    @isTest
    public static void testGetDateTime(){
        DateTime dt =   datetime.newInstance(2014, 9, 15, 12, 30, 0);
        String timeformat = 'yyyy/MM/dd HH:mm:ss';
        string timezone = 'Asia/Mumbai';
        String ExpectedDate = DateUtilities.getDateTime(dt,timeformat,timezone);
        debug.log('ExpectedDate-->'+ExpectedDate);
        System.assertNotEquals(null,ExpectedDate);        
    }
}