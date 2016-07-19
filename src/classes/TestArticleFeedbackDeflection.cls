/**
 * TestArticleFeedbackDeflection
 * Author: Maria Huemmer
 * Purpose: Test Class for ArticleFeedbackDeflection trigger 
 * Ticket: BAP-3927
 *
 * Updates:
 * *********
 * 
 */
public with sharing class TestArticleFeedbackDeflection {
	
	//Create a Test Article and bring it in to the test class
	
	//Instantiate a Public Article
	Public__kav article=new Public__kav(Title='Unit Test');
	
	
	
	//Create a User to Set as the Author
	
	//Test Article with an Author
	
	Public__kav testArticle = new Public__kav(title = 'TestArticle', Summary = 'Article summary');
	//testArticle.Author = [SELECT Id FROM User LIMIT 1];
	//insert testArticle;
	
	//Test Article without an Author
	Public__kav testArticle2 = new Public__kav(title = 'TestArticle 2', Summary = 'Article summary 2');
	//insert testArticle2;
	
	//Create an Article Feedback Deflection record and test 
	
	// Get the KnowledgeArticleId
	Public__kav insertedTestArticle = [Select KnowledgeArticleId from Public__kav where ID = :testArticle.Id];
	
	//Publish Article
	//KbManagement.PublishingService.publishArticle(insertedTestArticle.KnowledgeArticleId,true);
	
	//PKB_Article_Feedback_Deflection__c af = new PKB_Article_Feedback_Deflection__c;
	
    
}