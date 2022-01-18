global without sharing class obfuscationClass implements Database.Batchable<sObject> {


  Private map<String, list<String>> thesObjectAndFields {get;set;}
  Private List<string> fieldNames {get;set;}
  Private list<string> rtid {get;set;}

  global obfuscationClass(map<String, list<String>> objectsAndFields, list<string> recid) {
    rtid = recid;
    thesObjectAndFields = objectsAndFields;
    for(string str : thesObjectAndFields.keyset()){
      fieldNames = thesObjectAndFields.get(str);
    }
  }



    global Database.QueryLocator start(Database.BatchableContext bc) {

      if(rtid == null){
    
          String sql = 'SELECT ';

          for(string obj : thesObjectAndFields.keyset()){
            for(string fld : thesObjectAndFields.get(obj)){
              sql += fld + ',';
            }

            sql = sql.removeEnd(',');
            sql += ' FROM ' + obj;
            
          }
          system.debug('no rec types sql :' + sql);
          Database.QueryLocator DQL = Database.getQueryLocator(sql); 
          return DQL;
      }
      else{

        string theIds = '(';
        for(string str : rtid){
          theIds += '\''+str+'\',';
        }
        theIds = theIds.removeEnd(',');
        theIds += ')';

        String sql = 'SELECT ';

          for(string obj : thesObjectAndFields.keyset()){
            for(string fld : thesObjectAndFields.get(obj)){
              sql += fld + ',';
            }

            sql = sql.removeEnd(',');
            sql += ' FROM ' + obj;
            sql += ' WHERE recordtypeid IN '+theIds;
            
            if(thesObjectAndFields.containsKey('Account')){
              sql += ' AND FirstName != \'del\' AND FirstName != \'Deleted\'';
            }
            
          }
          system.debug('Rec types sql :' + sql);
          Database.QueryLocator DQL = Database.getQueryLocator(sql); 
          return DQL;


      }
    
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

      string batchResults = '';
      list<sObject> obs = new list<sObject>();
      Set<String> objectSet = new Set<String>();
      set<sObject> typeSet = new set<sObject> ();

      string objectType = scope.getSObjectType().getDescribe().getName();
      map<String, Schema.SObjectField> theMap = Schema.getGlobalDescribe().get( objectType ).getDescribe().fields.getMap();

      for(sObject item : scope){
        string objectName = item.getSobjectType().getDescribe().getname();
        objectSet.add(objectName);
      }

      if(objectSet.contains('EmailMessage')){
        for(sObject item : scope){
          obs.add(item);      
        }
        delete obs;
      }


    for(sObject item : scope){

      integer fieldsUpdated = 0;

      for(string theField : fieldNames){

        if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'STRING'){
          if(item.get(theField) != 'Deleted' && item.get(theField) != 'del'){
            item.put(theField,'Deleted');  
            fieldsUpdated += 1;
          }
        }
        else if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'TEXTAREA'){
          if(item.get(theField) != 'Deleted' && item.get(theField) != 'del'){
            item.put(theField,'Deleted');  
            fieldsUpdated += 1;
          }
        }
        else if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'PHONE'){
          if(item.get(theField) != '1234567890' && item.get(theField) != 'del'){
            item.put(theField,'1234567890');
            fieldsUpdated += 1;
          }  
        }
        else if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'REFERENCE'){
          if(item.get(theField) != NULL){
            item.put(theField,NULL);
            fieldsUpdated += 1;  
          }
        }
        else if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'EMAIL'){
          if(item.get(theField) != NULL){
            item.put(theField,NULL);  
            fieldsUpdated += 1;
          }
        }
        else if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'DATE'){
          if(item.get(theField) != NULL){
            item.put(theField,NULL);  
            fieldsUpdated += 1;
          }
        }
        else if(String.valueOf(theMap.get(theField).getDescribe().gettype().name()) == 'BOOLEAN'){
          if(item.get(theField) != False){
            item.put(theField,False);  
            fieldsUpdated += 1;
          }
        }
        else{
          if(item.get(theField) != NULL && item.get(theField) != 'Null')
          item.put(theField,'NULL');  
          fieldsUpdated += 1;
        }    
      }

      system.debug('fieldsUpdated : ' + fieldsUpdated);

      if(fieldsUpdated > 0){
      obs.add(item);      
      }  
    }

    try{
      system.debug('obs size : ' + obs.size());
      if(obs != NULL && obs.size() != 0){
        system.debug('obs size : ' + obs.size());
          update obs;
          }
      }
    catch (exception e){
      batchResults += '@@@@@@ bulkupdate failed ' + e + ' ------ ';
      } 

    }
    


    
    global void finish(Database.BatchableContext BC) {
        
    }


}