/**********************************************************************
Name:  ArticleFeedbackDeflection 
======================================================
 Purpose: Perform action on updates.
======================================================
 
History:   
                                                      
VERSION AUTHOR   		DATE       	DETAIL     
 
1.0 Maggie Frederick 	6/5/2015  	Initial development
1.1 Steve O'Neal		6/24/2016	Adding "Author" from Article Type of Public
 
***********************************************************************/
trigger ArticleFeedbackDeflection on PKB_Article_Feedback_Deflection__c (before insert, before update) 
{
       
    Set<id> artids = new Set<Id>();
    Set<String> artNums = new Set<String>();
    
    List<KnowledgeArticleVersion> kavs = new List<KnowledgeArticleVersion>();
    List<KnowledgeArticle> kas = new List<KnowledgeArticle>();
    
    for(PKB_Article_Feedback_Deflection__c af:Trigger.new)
	 {
	 	if ( af.Article_ID__c <> null && af.Article_Number__c <> 'ARTTTTNUM')
	 	{
		 	artIds.add(af.Article_ID__c);
		 	artNums.add(af.Article_Number__c);
	 	}
	 }
	 
	 Map<String, KnowledgeArticle> mpArtKa = new Map<String, KnowledgeArticle>();
	 
	 Map<String, KnowledgeArticleVersion> mpArtKav = new Map<String, KnowledgeArticleVersion>();
	 kavs = [Select k.LastPublishedDate, k.LastModifiedDate, k.LastModifiedById, k.KnowledgeArticleId, k.IsVisibleInPkb, k.IsVisibleInCsp, k.IsVisibleInApp, k.FirstPublishedDate, k.CreatedDate, k.CreatedById, k.ArticleNumber 
	 										From KnowledgeArticleVersion k 
	 										where PublishStatus = 'Online' and Language ='en_US' 
	 										and articleNumber in :artNums];
	 
	 for (KnowledgeArticleVersion kav :kavs)	
	 {
	 	mpArtKav.put(kav.articleNumber, kav);
	 }	
	 
	 kas = [Select k.LastPublishedDate, k.LastModifiedDate, k.FirstPublishedDate, k.CreatedDate, k.CreatedById, k.CaseAssociationCount, k.ArticleNumber From KnowledgeArticle k where Id in :artIds];
	 for (KnowledgeArticle ka :kas)	
	 {
	 	mpArtKa.put(ka.ArticleNumber, ka);
	 }


	/**
	 * Collect the public article type data to get the Author at the time of the deflection
	 * @author Steve O'Neal
	 * @date   2016-06-24
	 * @ticket link       https://jira.bigcommerce.com/browse/BAP-3870
	 */
	 Map<String, Public__kav> publicArticleTypeMap = new Map<String, Public__kav>();
	 List<Public__kav> publicArticleTypes = 	[Select ID, ArticleNumber, Author__c, Author__r.FirstName, Author__r.LastName 
	 											 from   Public__kav 
	 											 where  PublishStatus = 'Online' 
	 											   and  Language = 'en_US'
	 											   and  ArticleNumber in :artNums];
	 
	 for (Public__kav publicArticleType : publicArticleTypes)
	 {
	 	publicArticleTypeMap.put(publicArticleType.ArticleNumber, publicArticleType);
	 }

	 
	 for(PKB_Article_Feedback_Deflection__c af:Trigger.new)
	 {
	 	if (af.article_Number__c != null && af.Article_Number__c <> 'ARTTTTNUM')
	 	{
		 	KnowledgeArticleVersion kav = mpArtKav.get(af.article_Number__c);
			if (kav <> null)
			{
				af.Last_Published_Date__c = kav.LastPublishedDate;
				af.VisibleInPublicKnowledgebase__c = kav.IsVisibleInPkb;
				af.VisibleInInternalApp__c = kav.IsVisibleInApp;
				af.ArticleLastModifiedBy__c = kav.LastModifiedById;
				af.ArticleCreatedBy__c = kav.CreatedById;
				KnowledgeArticle ka = mpArtKa.get(af.article_Number__c);
		 		af.Case_Association_Count__c = ka.CaseAssociationCount;
		 	}

			/**
			 * Add the Public "author" field to the Article Feedback Deflection object
			 * @author Steve O'Neal
			 * @date   2016-06-24
			 * @ticket link       https://jira.bigcommerce.com/browse/BAP-3870
			 */
			if (publicArticleTypeMap.ContainsKey(af.article_Number__c))
			{
				if (publicArticleTypeMap.get(af.article_Number__c).Author__c != null)
				{
					af.Author__c = publicArticleTypeMap.get(af.article_Number__c).Author__r.FirstName + ' ' + publicArticleTypeMap.get(af.article_Number__c).Author__r.LastName;
				}
				else
				{
					af.Author__c = 'No Author';
				}
			}

	 	}
	 }								
}