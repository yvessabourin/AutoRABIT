@isTest(SeeAllData=true)
global class shareCompetitorVisitTest{

private static testMethod void doTest() {

list <shareCompetitorVisit.myeventId> mycmpr = new list<shareCompetitorVisit.myeventId>();

shareCompetitorVisit.myeventId cmpr = new shareCompetitorVisit.myeventId();

        
        Village__c village = new Village__c();
        village.Name = 'TestVillage1';     
        village.Village_Code__c = 'AA';
		village.CertSales_CertPeriod_Cut_Off_Days__c = 1;
		village.CertSales_Report_Sales_Grace_Period_Days__c = 1; 
        insert village;

        Competitor_Site__c cs = new Competitor_Site__c();
        cs.name = 'test Site';
        cs.Competitor_to_Village__c = village.id;
        
        event me = new event();
        me.Event_Department__c = 'Leasing/Commercialisation';
        me.Event_Status__c = 'Meeting Completed';
        me.StartDateTime = Date.Today();
        me.EndDateTime = Date.Today()+1;
        insert me;
        
        FeedItem post = new FeedItem();
            post.Title = 'Dan Childs created a competitor Site visit';
            post.body = 'Competitor Site Report' + '\n' +
            'Department :' + 'TESTS' + '\n' +
            'Village :' + 'Village' +  '\n' +
            'Meeting Notes :' + 'Motes';
             post.LinkUrl = '/'+ me.id ;
            post.ParentId = me.id;
            insert post;
        
        cmpr.eventIds = me.id;
        cmpr.eventName = 'TEST';
        cmpr.body = 'test body';
        cmpr.postid = post.id;
        system.debug(cmpr);
 
                
        mycmpr.add(cmpr);
        
        
    
        Test.startTest();
       
        shareCompetitorVisit.Id(mycmpr);
       
        
        Test.stopTest();

    }
}