@isTest
public class DownloadAdbuilderTest {
    
    @isTest
    static   void TestDownloadAdbuilder(){
        Adbuilder__c adb = new Adbuilder__c (Name ='Test');
        insert adb;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(adb);
        DownloadAdbuilderController con = new DownloadAdbuilderController(sc);
        
        system.debug('*******con.xlsHeader********'+con.xlsHeader);
        
    }

    @isTest
    static void testgetLink1(){
        Adbuilder__c adb = new Adbuilder__c (Name ='Test', Format__c = null);
        insert adb;
        
        String url = DownloadAdbuilderController.getLink(adb.Id);
        system.assertEquals(null, url);
    }
    
    @isTest
    static void testgetLink2(){
        Id recordypeId = Schema.getGlobalDescribe().get('Adbuilder__c').getDescribe().getRecordTypeInfosByName().get('Instagram Story').getRecordTypeId();
        Adbuilder__c adb = new Adbuilder__c (Name ='Test', RecordTypeID = recordypeId, Format__c = 'Instagram Story');
        insert adb;
        
        String url = DownloadAdbuilderController.getLink(adb.Id);
        system.assert(url != null);
    }
    
    @isTest
    static void testgetLinkAll(){
        Map<String,Schema.RecordTypeInfo> recordypeInfoByName = Schema.getGlobalDescribe().get('Adbuilder__c').getDescribe().getRecordTypeInfosByName();
        Map<String, String> recTypeNameToFormat = new Map<String, String>();
        recTypeNameToFormat.put('Facebook Canvas', 'Facebook Canvas');
        recTypeNameToFormat.put('Facebook Carousel', 'Facebook Carousel');
     	recTypeNameToFormat.put('Instagram Carousel', 'Instagram Carousel');
        recTypeNameToFormat.put('Instagram Story', 'Instagram Story');
        recTypeNameToFormat.put('Facebook Image Link Ad', 'Facebook Image Link Ad');
        recTypeNameToFormat.put('Video Link Ad', 'Video Link Ad');
        recTypeNameToFormat.put('Video Post Page', 'Video Post Page');
                    
        List<Adbuilder__c> adBuilderList = new List<Adbuilder__c>(); 
        for(String recTypeName: recTypeNameToFormat.keySet()){
            Id recTypeID = recordypeInfoByName.get(recTypeName).getRecordTypeId();
            String format = recTypeNameToFormat.get(recTypeName);
            adBuilderList.add(new Adbuilder__c (Name ='Test', RecordTypeID = recTypeID, Format__c = format));
        }
        insert adBuilderList;
        
        for(Adbuilder__c adb: adBuilderList){
            String url = DownloadAdbuilderController.getLink(adb.Id);
            system.assert(url != null);
        }
    }
    
}