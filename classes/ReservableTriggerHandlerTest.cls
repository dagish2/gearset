/************************************************************************************************************************************
    Author 		: Anant Kumar
    Description : ---
    History		: --

----------------------------------------------------------------------------------------------------------------------------------
	VERSION	 	DATE	        	AUTHOR       	DETAIL
	1	     	01, Mar 2016		Anant Kumar  	Initial Developement
**************************************************************************************************************************************/
@isTest
private class ReservableTriggerHandlerTest {
	/**************************************************************************************************************************
    Author 				: Anant Kumar
    Issue No 			:
    Description 		: 
    Created Date 		: 01, Mar 2016
    Last Modified Date	: 02, Feb 2018
    Last Modified By	: Shivprasad Patil
******************************************************************************************************************************/
    static testMethod void testUpdateSpaceBasedOnSpaceUUID(){
        
        Triggers__c triggers = new Triggers__c(Name= 'Triggers');
        triggers.Update_Space_BasedOn_SpaceUUID__c= true;
        insert triggers;
        
        
        Building__c building = new Building__c();
        building.Name = 'Test Square';
        building.City__c = 'Newyork City';
        TestingUtility.insertWithAssert(building);
        
        Reservable__c residentialUnit1 = new Reservable__c();
        residentialUnit1.Building__c = building.Id;
        residentialUnit1.Name = 'Residential Unit-101';
        residentialUnit1.Monthly_Price__c = 50;
        residentialUnit1.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d6';
        TestingUtility.insertWithAssert(residentialUnit1);
        System.debug(logginglevel.ERROR, 'Test : Scenario 1');
        
        // Scenario 1 :- When Space_UUID__c is available but Space__c is blank
        List<Reservable__c> scenario1ReservableList = new List<Reservable__c>();
        Reservable__c bed1 = new Reservable__c();
        bed1.Building__c = building.Id;
        bed1.Name = 'Bed 1';
        bed1.Monthly_Price__c = 50;
        bed1.Space_UUID__c = residentialUnit1.UUID__c;
        //TestingUtility.insertWithAssert(bed1);
        scenario1ReservableList.add(bed1);
        
        Reservable__c bed2 = new Reservable__c();
        bed2.Building__c = building.Id;
        bed2.Name = 'Bed 2';
        bed2.Monthly_Price__c = 50;
        bed2.Space_UUID__c = residentialUnit1.UUID__c;
        //TestingUtility.insertWithAssert(bed2);
        scenario1ReservableList.add(bed2);
        TestingUtility.insertListWithAssert(scenario1ReservableList);
        
        System.assertEquals(residentialUnit1.Id, [SELECT Space__c FROM Reservable__c Where Id=:bed1.Id].Space__c);
        System.assertEquals(residentialUnit1.Id, [SELECT Space__c FROM Reservable__c Where Id=:bed2.Id].Space__c);
        
        Reservable__c residentialUnit2 = new Reservable__c();
        residentialUnit2.Building__c = building.Id;
        residentialUnit2.Name = 'Residential Unit-102';
        residentialUnit2.Monthly_Price__c = 50;
        residentialUnit2.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d7';
        TestingUtility.insertWithAssert(residentialUnit2);
        
        System.debug(logginglevel.ERROR, 'Test : Scenario 2');
        // Scenario 2 :- When Space__c is available but Space_UUID__c is blank
        List<Reservable__c> scenario2ReservableList = new List<Reservable__c>();
        Reservable__c bed3 = new Reservable__c();
        bed3.Building__c = building.Id;
        bed3.Name = 'Bed 3';
        bed3.Monthly_Price__c = 50;
        bed3.Space__c = residentialUnit2.Id;
        //TestingUtility.insertWithAssert(bed3);
        scenario2ReservableList.add(bed3);
        
        Reservable__c bed4 = new Reservable__c();
        bed4.Building__c = building.Id;
        bed4.Name = 'Bed 4';
        bed4.Monthly_Price__c = 50;
        bed4.Space__c = residentialUnit2.Id;
        //TestingUtility.insertWithAssert(bed4);
        scenario2ReservableList.add(bed4);
        
        TestingUtility.insertListWithAssert(scenario2ReservableList);
        System.assertEquals(residentialUnit2.UUID__c, [SELECT Space_UUID__c FROM Reservable__c Where Id=:bed3.Id].Space_UUID__c);
        System.assertEquals(residentialUnit2.UUID__c, [SELECT Space_UUID__c FROM Reservable__c Where Id=:bed4.Id].Space_UUID__c);
        
        Reservable__c residentialUnit3 = new Reservable__c();
        residentialUnit3.Building__c = building.Id;
        residentialUnit3.Name = 'Residential Unit-103';
        residentialUnit3.Monthly_Price__c = 50;
        residentialUnit3.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d8';
        TestingUtility.insertWithAssert(residentialUnit3);
        
        System.debug(logginglevel.ERROR, 'Test : Scenario 3');
        // Scenario 3 :- When Space__c and Space_UUID__c both are available
        Reservable__c bed5 = new Reservable__c();
        bed5.Building__c = building.Id;
        bed5.Name = 'Bed 5';
        bed5.Monthly_Price__c = 50;
        bed5.Space__c = residentialUnit3.Id;
        bed5.Space_UUID__c = residentialUnit3.UUID__c;
        TestingUtility.insertWithAssert(bed5);
        
        Reservable__c bed6 = new Reservable__c();
        bed6.Building__c = building.Id;
        bed6.Name = 'Bed 6';
        bed6.Monthly_Price__c = 50;
        bed6.Space__c = residentialUnit3.Id;
        bed6.Space_UUID__c = residentialUnit3.UUID__c;
        TestingUtility.insertWithAssert(bed6);
        
        Reservable__c reservableRec = [SELECT Id, Space__c, Space_UUID__c FROM Reservable__c WHERE Id=:bed6.Id];
        System.assertEquals(residentialUnit3.UUID__c, reservableRec.Space_UUID__c);
        System.assertEquals(residentialUnit3.Id, reservableRec.Space__c);
        
        System.debug(logginglevel.ERROR, 'Test : Scenario 4.0');
        // Scenario 4 :- When Bed is created first and then residential unit with bulk insertion
        List<Reservable__c> reservableList = new List<Reservable__c>();
        Reservable__c bed7 = new Reservable__c();
        bed7.Building__c = building.Id;
        bed7.Name = 'Bed 7';
        bed7.Monthly_Price__c = 50;
        bed7.Space_UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d9';
        reservableList.add(bed7);
        
        Reservable__c bed8 = new Reservable__c();
        bed8.Building__c = building.Id;
        bed8.Name = 'Bed 8';
        bed8.Monthly_Price__c = 50;
        bed8.Space_UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d9';
        reservableList.add(bed8);
        
        Reservable__c residentialUnit4 = new Reservable__c();
        residentialUnit4.Building__c = building.Id;
        residentialUnit4.Name = 'Residential Unit-104';
        residentialUnit4.Monthly_Price__c = 50;
        residentialUnit4.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247d9';
        reservableList.add(residentialUnit4);
        TestingUtility.insertListWithAssert(reservableList);
        Map<Id, Reservable__c> scenario4ReservableMap = new Map<Id, Reservable__c>([SELECT Id, Space__c, Space_UUID__c, UUID__c FROM Reservable__c WHERE Id in:(new Map<Id,SObject>(reservableList)).keySet()]);
        System.assertEquals(scenario4ReservableMap.get(bed7.Id).Space__c, residentialUnit4.Id);
        System.assertEquals(scenario4ReservableMap.get(bed8.Id).Space__c, residentialUnit4.Id);
        
        System.debug(logginglevel.ERROR, 'Test : Scenario 4.1');
        // Scenario 4 :- When Bed is created first and then residential unit with separate insertion
        Reservable__c bed9 = new Reservable__c();
        bed9.Building__c = building.Id;
        bed9.Name = 'Bed 9';
        bed9.Monthly_Price__c = 50;
        bed9.Space_UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247e1';
        reservableList.add(bed9);
        TestingUtility.insertWithAssert(bed9);
        
        Reservable__c residentialUnit5 = new Reservable__c();
        residentialUnit5.Building__c = building.Id;
        residentialUnit5.Name = 'Residential Unit-105';
        residentialUnit5.Monthly_Price__c = 50;
        residentialUnit5.UUID__c = '4f65bbe3-3997-4f9b-b3b6-54535f8247e1';
        TestingUtility.insertWithAssert(residentialUnit5);
        
        System.assertEquals(residentialUnit5.Id, [SELECT Space__c FROM Reservable__c Where Id=:bed9.Id].Space__c);
    }
}