trigger MBA_Staging_Contact_Trigger on MBA_Staging_Contact__c (before insert, before update, after insert, after update) 
{

	if (Trigger.isBefore)
	{
		for (MBA_Staging_Contact__c mbc : trigger.new)
    	{
        	system.debug('*** incoming City' +mbc.City__c);
        	mbc.City__c = DataUtility.truncateString(mbc.City__c, 40);
	        mbc.State__c = DataUtility.truncateString(mbc.State__c, 20);
	        mbc.Country__c = DataUtility.truncateString(mbc.Country__c, 40);
	        mbc.FirstName__c = DataUtility.truncateString(mbc.FirstName__c, 40);
	        if (mbc.LastName__c == null)
	        {
	        		mbc.LastName__c = 'Trial';
	        }
        	else mbc.LastName__c = DataUtility.truncateString(mbc.LastName__c, 80);
    	}	
	}


  if (Trigger.isAfter)
  {

	string soqlWHERE_MBAConIDs = '';  
		
	Contact objContact;
	
	// Set to hold MBA Contact Ids
	set<string> stMBAConId = new set<string>();

    // Set to hold MBA Account Ids
    set<string> stMBAOrigAcctId = new set<string>();
	
	// Set to hold MBA Account Ids
	set<string> stMBAAccId = new set<string>();
	
	// Used to store the updated list of Contacts with Accounts that have Id's
	list<MBA_Staging_Contact__c> stgContactList = new List<MBA_Staging_Contact__c>();    
		
	// Map to hold existing Contact Records by MBA Contact Id
	map<string, Contact> mpCon = new map<string, Contact>();
	set<string> stContId = new set<string>();
	set<string> stContOrigId = new set<string>();
	
	// Account Map - To Store the Account links for the Contact records
	map<string, Id> mpMBAAcctIdToAcctId = new map<string, Id>();
	set<string> stAcctId = new Set<String>();
	
	//List of Staging Contact Records for looping and manipulate to get the ID 
	
	// Map to hold the Staging Record to the Existing Record
	map<SObject, SObject> mpStagingToExisting = new map<SObject, SObject>();
	
    ///////////////////////////////////////////////////////////////////////////
    // First try and match to existing Contacts
    ///////////////////////////////////////////////////////////////////////////
    // Loop through all staging records
    for (MBA_Staging_Contact__c mba : trigger.new)
    {
        // Grab all the MBA Contact Ids
        if (mba.MBAClientID__c != null)
        {
        	if (stMBAConId.add(mba.MBAClientID__c))
        	{
        		soqlWHERE_MBAConIDs += (soqlWHERE_MBAConIDs.length() == 0 ? '' : ', ') + '\'' + mba.MBAClientID__c + '\'';
        	}
        }
        
        // Grab the list of MBA Account Ids
        if (mba.MBAAccountID__c != null)
        {
        	stAcctId.add(mba.MBAAccountID__c);
        }

    }

    string soql_Sub = SObjectUtils.ContactSelect + ' WHERE MBAClientID__c IN (' + soqlWHERE_MBAConIDs + ')';

	// Grab all the subscriptions that match the Client id
    for (Contact c : database.query(soql_Sub))
	{
		mpCon.put(c.MBAClientID__c, c);
	}
	
	// Create Map of Account and non Salesforce defined keys to help link Contacts with Accounts
	for (Account accLoop : [SELECT MBAAccountID__c, Id 
							FROM Account 
							WHERE MBAAccountID__c IN :stAcctId
                               or MBAAccountID__c IN :stContOrigId])
	{
		mpMBAAcctIdToAcctId.put(accLoop.MBAAccountID__c, accLoop.Id);
	}
    
    system.debug('***** mpMBAAcctIdToAcctId ***** : ' + mpMBAAcctIdToAcctId);
	
	///////////////////////////////////////////////////////////////////////////
	// Find all the Contacts being inserted/updated
    ///////////////////////////////////////////////////////////////////////////
    for (MBA_Staging_Contact__c mba : trigger.new)
    {
        // only create the contact if they are primary.
        // MBA will never send anything but a primary contact, and BMP will often duplicate the primary and send it as a billing contact.
        // Since the vast majority of contacts coming from BMP are duplicates, we will mimic the behavior that already existed in MBA and ignmore any non-primary contacts
        if ((mba.Source__c == 'BMP' && mba.Type__c.toUpperCase().StartsWith('PRIMARY')) || mba.Source__c != 'BMP')
        {
        	//system.debug('***** trigger.new : '+trigger.new);
            // Check if a Contact record exists already
            if (mpCon.containsKey(mba.MBAClientID__c))
            {
            	// Ensure the contact is pointing to the correct account record
            	objContact = mpCon.get(mba.MBAClientID__c);
                if (mpMBAAcctIdToAcctId.containsKey(mba.MBAAccountID__c))
                {
                	objContact.AccountId = mpMBAAcctIdToAcctId.get(mba.MBAAccountID__c);
                }
            	
            	// Add to the map of the staging record to the existing Account
            	mpStagingToExisting.put(mba, objContact);
            	
            	system.debug('***** mpStagingToExisting for Existing: ' + mpStagingToExisting);
            }
            // If it is not found then create a new one
            else if(!mpCon.containsKey(mba.MBAClientID__c) && (mba.IsPaid__c || mpMBAAcctIdToAcctId.containsKey(mba.MBAAccountID__c)))
            { 
                if (mpMBAAcctIdToAcctId.containsKey(mba.MBAAccountID__c))
                {
                    objContact = new Contact(AccountId = mpMBAAcctIdToAcctId.get(mba.MBAAccountID__c));
                    mpStagingToExisting.put(mba, objContact);
                    system.debug('***** mpStagingToExisting for New: ' + mpStagingToExisting);
                }
            }
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Create/Update Subscription records from the staging records -- This updates and syncs the selected records from the MBA Accounts to Accounts object 
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    database.Dmloptions dml = new database.Dmloptions();
	dml.assignmentRuleHeader.useDefaultRule = false;
	dml.emailHeader.triggerUserEmail = false;
	dml.optAllOrNone = Subscription_Utility.blnAllOrNone;
	
    SObjectUtils.SyncObjects('MBA_Staging_Contact__c', 'Contact', mpStagingToExisting, dml);
    
 
  }
}