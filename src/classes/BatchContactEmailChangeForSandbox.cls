/**
 * BatchContactEmailChangeForSandbox
 * Author: Bala Rajagopal
 * Purpose: Modifies all the Contact Email in the Sandbox by appending ".test" to it to prevent accidental email notifications going out to clients from the sandbox
 * Ticket: BAP-3907
 * 
 */
Public class BatchContactEmailChangeForSandbox implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //Identify if the current instance is a sandbox
        //return results to process only if it's a sandbox
        Boolean sandbox;
        for(Organization o:[Select isSandbox from Organization limit 1]){
            sandbox = o.isSandbox;
        }
        if(Sandbox == TRUE){
            //exclude all contacts without email, emails that are already converted and Contacts without Accounts
        	return Database.getQueryLocator([select id, Email from Contact where Email!=null AND Accountid != null 
                                             AND (NOT Email LIKE '%.test')]);
        } else {
            return null;
        }
    }

    Public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Contact> listContact = (List<Contact>)scope;
        List<Contact> ListToUpdate = new List<Contact>();
        if(scope!=null){
            for(Contact c:listContact){
                //process only email values that fit the email format
                if(Utilities.checkEmail(c.Email)){
                    c.Email = c.Email+'.test';
                    ListToUpdate.add(c);                    
                }
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Contacts that can be updated
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
        //Start the Lead Email Change for Sandbox process
        BatchLeadEmailChangeForSandbox BECFS = new BatchLeadEmailChangeForSandbox();
        database.executebatch(BECFS);
    }
}