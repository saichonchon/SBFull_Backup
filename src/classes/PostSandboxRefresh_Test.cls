/**
 * PostSandboxRefresh_Test
 * Author: Bala Rajagopal
 * Purpose: Test Class for PostSandboxRefresh class
 * Ticket: BAP-3907
 * 
 */
@isTest
class PostSandboxRefresh_Test{
    @isTest
    static void testSandboxPostCopyScript() {
        List<Lead> leads = TestDataFactory.createTestLeads(1, false, TestDataFactory.LeadRecordType.Client_Prospect);
		List<Account> accounts = TestDataFactory.createTestAccounts(1, false, TestDataFactory.AccountRecordType.Client_Record_Type);
		List<Contact> contacts = TestDataFactory.createTestContacts(1, accounts);
        string sandboxname = 'sandbox';
        if(userinfo.getUserName().substringAfterLast('.')!=null){
            sandboxname = userinfo.getUserName().substringAfterLast('.');
        }
        List<Organization> org = ([select id from Organization limit 1]);
        PostSandboxRefresh PSR = new PostSandboxRefresh();
        test.startTest();
        Test.testSandboxPostCopyScript(PSR, org[0].Id, org[0].Id, sandboxname);
        test.stopTest();
        Contact c = [Select email from Contact limit 1];
        Lead l = [Select email from Lead limit 1];
        System.assertEquals('test',c.Email.substringAfterLast('.'));
        System.assertEquals('test',l.Email.substringAfterLast('.'));
    }
}