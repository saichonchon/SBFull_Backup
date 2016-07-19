/**
 * BatchContactEmailChangeForSandbox
 * Author: Bala Rajagopal
 * Purpose: Modifies all the Lead Email in the Sandbox by appending ".test" to it to prevent accidental emails going out to prospects from the sandbox
 * Ticket: BAP-3907
 * 
 */
Public class BatchLeadEmailChangeForSandbox implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //Identify if the current instance is a sandbox
        //return results to process only if it's a sandbox
        Boolean sandbox;
        for(Organization o:[Select isSandbox from Organization limit 1]){
            sandbox = o.isSandbox;
        }
        if(Sandbox == TRUE){
            //exclude all leads without email and emails that are already converted
        	return Database.getQueryLocator([select id, Email from Lead where Email!=null AND (NOT Email LIKE '%.test')]);
        } else {
            return null;
        }
    }

    Public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Lead> listLead = (List<Lead>)scope;
        List<Lead> ListToUpdate = new List<Lead>();
        if(scope!=null){
            for(Lead l:listLead){
                //process only email values that fit the email format
                if(Utilities.checkEmail(l.Email)){
                    l.Email = l.Email+'.test';
                    ListToUpdate.add(l);
                }
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Leads that can be updated
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
        
    }
}