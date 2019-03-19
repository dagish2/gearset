/* Created by krishana Tupe on 22 Nov 2017
* This class used to test Now class.
*/
@isTest
public class NowTest {
    public testmethod static void verifyNow(){
        Now.setGMT(2017,11,10,10,10,10);
        Now.set(2017,11,10,10,10,10);
        Datetime dt=Now.dt();
        debug.log('dt==>'+dt);
        Date todayDate=Now.date();
        debug.log('todayDate==>'+todayDate);
        Time nowTime=Now.time();
        debug.log('nowTime==>'+nowTime);
    }
}