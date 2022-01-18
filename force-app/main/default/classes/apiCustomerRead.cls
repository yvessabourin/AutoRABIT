/*
    Customer Read items definition class
    
    Created : 21/01/2016
    Author: Constantine Chimonides

*/
global with sharing class apiCustomerRead {
    
    public class cls_CustomerReadItem {
        

        public map<string, string> attributes {get; set;}
        public string displayLabel {get; set;}
        public boolean tableDisplay {get; set;}
        public string section {get; set;}
        public string name {get; set;}
        public list<string> itemList {get; set;} // dynamic keyed property items to display
        
        public cls_CustomerReadItem(){
            this.attributes  = new map<string, string>();
            this.displayLabel = '';
            this.tableDisplay = false;
            this.section = '';
            this.name = '';
            this.itemList = new list<string>();
        }
    }

   // Method to deserialize XML string into an apiCustomerRead object
    public static list<apiCustomerRead.cls_CustomerReadItem> parseXML(String xmlCustomerRead, string section){
       
        list<apiCustomerRead.cls_CustomerReadItem> returnList = new list<apiCustomerRead.cls_CustomerReadItem>();
        apiCustomerRead.cls_CustomerReadItem dummyItem = new apiCustomerRead.cls_CustomerReadItem();
        dummyItem = getItemProperties(section);
        TG_XmlNode root = null;
        TG_XmlDom dom = new TG_XmlDom(xmlCustomerRead);
        root = dom.root;
      
        if(root!= null){
            List<TG_XmlNode> childNodes = new list<TG_XmlNode>();

            childNodes = root.getElementsByTagName(section);

            for(TG_XmlNode node :childNodes){
                apiCustomerRead.cls_CustomerReadItem item = new apiCustomerRead.cls_CustomerReadItem();
                if(node.nodeType == 1){ //element
                    
                    if(section == 'CustomerStatus'){
                        // something different here, where we read items based on the sub list
                        // read the item list for something special to do here
                        List<String> modifiedItems = dummyItem.itemList;
                        List<string> removalItems = new List<string>();
                        List<string> addingItems = new List<string>();
                        map<string, string> returnattributes = new map<string, string>();
                        for(String moditem :modifiedItems){
                            // another split into what needs to happen with each thing
                            List<String> modsplit = moditem.split(':'); // somthing like 0:CustomerStatus.DateCreated
                            String Action = modsplit[0]; // to give us the 0 / 1 for remove of add
                            if(modsplit[0] == '0'){
                                removalItems.add(modsplit[1]);
                            }
                            else{
                                addingItems.add(modsplit[1]);
                            }                            
                        }
                        // now we have items to remove, and items to add
                        for(String attribItem :node.attributes.keyset()){
                            Boolean itemfound = false;
                            for(String remitem :removalItems){                               
                                List<String> remparts = remitem.split('\\.');                            
                                if(remparts[1] == attribItem)
                                {
                                    itemfound = true;
                                    break;
                                }
                            }
                            if(!itemfound){
                                returnattributes.put(attribItem ,node.attributes.get(attribItem));
                            }
                        }
                        // thats the removals handled, but we need to also get the additional items
                        for(String adds :addingItems){
                            List<String> addssplit = adds.split('\\.');
                            String addsection = addssplit[0];
                            String itemattrib = addssplit[1];
                            List<TG_XmlNode> subchildNodes = new list<TG_XmlNode>();
                            subchildNodes = root.getElementsByTagName(addsection);
                              for(TG_XmlNode subnode :subchildNodes){
                                 if(subnode.nodeType == 1){ //element
                                     for(String attribItem :subnode.attributes.keyset()){                                                                           
                                        if(itemattrib == attribItem){
                                            returnattributes.put(attribItem ,subnode.attributes.get(attribItem));
                                        }
                                    }
                                 }
                              }
                        }

                        item.attributes = returnattributes;
                        item.displayLabel = dummyItem.displayLabel;
                        item.tableDisplay = dummyItem.tableDisplay;
                        item.name = dummyItem.Name;
                        item.section = section;
                        system.debug(' @@@ ADDING ITEM ' + item);   
                        returnList.add(item);
                    }  
                    else{ 

                        if (section == 'Item'){
                            item.attributes = getAllChildNodeValues(childNodes, dummyItem.itemList);
                            item.displayLabel = dummyItem.displayLabel;
                            item.tableDisplay = dummyItem.tableDisplay;
                            item.name = dummyItem.Name;
                            item.section = section;
                            returnList.add(item);
                            system.debug(' @@@ ADDING ITEM ' + item);   
                            break;                        
                        } 
                        else {    
                            item.attributes = node.attributes;
                        }                                           
                        item.displayLabel = dummyItem.displayLabel;
                        item.tableDisplay = dummyItem.tableDisplay;
                        item.name = dummyItem.Name;
                        item.section = section;
                        system.debug(' @@@ ADDING ITEM ' + item);   
                        returnList.add(item);
                    
                    } 
                }
            }
        }
        
        
        return returnList;
    }
    
    private static map<string, string> getAllChildNodeValues(list<TG_XmlNode> nodeList, list<string> itemList){
        
        map<string, string> returnMap = new map<string, string>();
        map<string, string> optoutValuesExist = new map<string, string>();
        map<string, string> optoutValuesNeeded = new map<string, string>();
        
        // retrieve read only items required to be displayed from custom setting
        map<String, API_Customer_Read_Items__c> readOnlySettings = API_Customer_Read_Items__c.getAll();
system.debug('@@@@ readOnlySettings .. ' + readOnlySettings);      
        
system.debug(' @@@@@  itemList  ' + itemList);
        for(TG_XmlNode node :nodeList){    
            string value = node.textContent;            
            for (string key :node.attributes.keySet()){ //there will only be 1  {type}
                for (string itemName :itemList){ // loop through custom setting property attributes
                    if (itemName.containsIgnoreCase('OPTOUT')){
                        optoutValuesNeeded.put(itemName, itemName); // An OPTOUT attribute identified
                        if (itemName == node.attributes.get(key) ){ 
                            
                            if (value == '1')
                                value = 'No';
                            if (value == '0')
                                value = 'Yes';
                            if (string.isBlank(value))
                                value = 'Unknown';
                            optoutValuesExist.put(itemName, value);// Value has been returned for OPTOUT attribute
                                                        
                            returnMap.put(node.attributes.get(key), value);
                        
                            break;
                        }                        
                        
                    } else {
                        if (itemName == node.attributes.get(key) ){
                            if (value == '1')
                                value = 'Yes';
                            if (value == '0')
                                value = 'No';
                            
                            if(itemName == 'ISPRIVILEGE'){
                                optoutValuesExist.put(itemName, value); //put in opt-in section
                            }                                
                            
                            returnMap.put(node.attributes.get(key), value);
                        
                            break;
                        }
                    }
                }                
            }
        }
                
        map<string, string> optoutReturnMap = new map<string, string>();
        string display = '';
        for (string itemName :itemList){
            if (optoutValuesExist.containsKey(itemName)){
                display = itemName.replace('OPTOUT', 'OPT-IN ');
                optoutReturnMap.put(display, optoutValuesExist.get(itemName));
            }
            if (!optoutValuesExist.containsKey(itemName) && optoutValuesNeeded.containsKey(itemName)){
system.debug(' @@@@ opt out node not there ....     ' + itemName);                 
                display = itemName.replace('OPTOUT', 'OPT-IN ');
                optoutReturnMap.put(display, 'Unknown');
            }
            
            if (!returnMap.containsKey(itemName)){
                returnMap.put(itemName, '');
            }
        }        
        if (!optoutReturnMap.isEmpty()){
            returnMap = optoutReturnMap;
        }
        
system.debug(' @@@@ returnMap  ' + returnMap);        
        return returnMap;
    
    }   
    
    
    private static apiCustomerRead.cls_CustomerReadItem getItemProperties(string section){
        
        apiCustomerRead.cls_CustomerReadItem returnItem = new apiCustomerRead.cls_CustomerReadItem();
        
        // retrieve read only items required to be displayed from custom setting
        map<String, API_Customer_Read_Items__c> readOnlySettings = API_Customer_Read_Items__c.getAll();     
        
        for (API_Customer_Read_Items__c itemDef :readOnlySettings.values()){        

            string name = itemDef.Name;
            list<string> sectionId = name.split(' ');
            string sectionName;

            if (sectionId.size() > 1){
                sectionName = sectionId[1]; 
            }
            if (sectionName == section){
                returnItem.displayLabel = itemDef.Item_Label__c;
                returnItem.tableDisplay = itemDef.Display_as_Table__c;
                returnItem.name = itemDef.Name;
                if (string.isnotBlank(itemDef.Property_Items__c))
                    returnItem.itemList = itemDef.Property_Items__c.split(',');
                
                break;
            }

            
        }
        
        return returnItem;
        
    }     
}