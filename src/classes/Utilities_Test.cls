/**
 * Utilities
 * Author: Bala Rajagopal
 * Purpose: Test Class for the Utilities Class
 * Ticket: BAP-3907
 * 
 */
@isTest
public class Utilities_Test {
    @isTest
    static void testEmailFormat() {
        String goodEmail = 'good@email.com';
        String badEmail = '<$bad@email.com>';
        test.startTest();
            system.assertEquals(TRUE, Utilities.checkEmail(goodEmail));
            system.assertNotEquals(TRUE, Utilities.checkEmail(badEmail));
        test.stopTest();
	}
}