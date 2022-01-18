@IsTest(SeeAllData=true)
public class CompetitorSiteExtensionTest{

        public date startdate {get;set;}
        public time starttime {get;set;}
        public time endtime {get;set;}
        public List<Event> myevents {get;set;} 
        public id myeventid {get;set;}
        public transient List<ContentVersion> myattachments {get;set;}
        public string crossoverbrands {get;set;}
        public string experience {get;set;}
        public string shopfits {get;set;}
        public string FoodandBeverage {get;set;}
        public string Hospitality {get;set;}
        public string Accesability {get;set;}
        public string GuestProfile {get;set;}
        public id neweventid {get;set;}
        public transient Competitor_site__c compsite;
        public string compsiteid {get;set;}
        public string compsitename {get;set;}
        public string compsitevillage {get;set;}       
        public id getmyeventid(){return myevents[0].id;} 
        public transient blob file { get; set; }
        public String fn{ get; set; }
        public transient feedItem Fi { get; set; }  
        
        public void startdate(date startdate)
        {
        this.startdate = System.today();
        }

        @IsTest(SeeAllData=true)
        public static void TestControllerExtension(){
        
        
        Village__c village = [SELECT Id FROM Village__c WHERE Name = 'Bicester'];
              
        
        Competitor_Site__c compesite = new Competitor_Site__c();
        compesite.competitor_to_village__c = village.id;
        insert compesite;
        
        
        
        /*        
        Collaborationgroup cg = new Collaborationgroup(); 
        cg.name = 'Competitor Site Visits';
        cg.CollaborationType = 'Public';
        insert cg;
        */
        
        ApexPages.StandardController sc = new ApexPages.StandardController(compesite);  
        CompetitorSiteExtension cse = new CompetitorSiteExtension(sc);
        
        cse.startdate = System.today();
        cse.starttime = Time.newInstance(1, 2, 3, 4);
        cse.endtime = Time.newInstance(4, 2, 3, 4);
        cse.crossoverbrands = 'COB';
        cse.experience = 'Ex';
        cse.shopfits = 'SF';
        cse.FoodandBeverage = 'FB';
        cse.Hospitality = 'Hosp';
        cse.Accesability = 'Access';
        cse.GuestProfile = 'GP';
        cse.compsitename = compesite.name;
        cse.compsiteid = compesite.id;
        
        CSE.addAttachements();
        System.Assert([SELECT id from EVENT WHERE id =: cse.myevents[0].id].size() == 1);  
        
        CSE.share();
        System.Assert([SELECT id from FeedItem WHERE ParentId =: cse.myevents[0].id].size() == 1);  
        
        CSE.finish();
        System.Assert([SELECT id from FeedItem WHERE ParentId =: cse.myevents[0].id].size() == 2);  
        
        cse.go();
        System.Assert(cse.mylist.size() == 0);  
       
        }

}