/*
	Customer API Lookup definition class
	Used for retrieving lookup values exposed
	by Customer API (Only XML payload supported)
	
	Created : 19/06/2015
	Author: Constantine Chimonides
	
	Modification History:
*/
public with sharing class apiLookup {
	
	// Method to extract xml values and populate SelectOptions list
	public static list<SelectOption> parseXML(string xmlLookup){
		

		/* Example string
		<Enumeration Type="Gender">
			<Item Key="0" Language="en-gb">Unknown</Item>
			<Item Key="1" Language="en-gb">Male</Item>
			<Item Key="2" Language="en-gb">Female</Item>
			<Item Key="0" Language="es-es">Desconocido</Item>
			<Item Key="1" Language="es-es">Hombre</Item>
			<Item Key="2" Language="es-es">Mujer</Item>
			<Item Key="0" Language="fr-fr">Inconnu</Item>
			<Item Key="1" Language="fr-fr">Homme</Item>
			<Item Key="2" Language="fr-fr">Femme</Item>
		</Enumeration>	
		*/		
		list<SelectOption> returnList = new list<SelectOption>();
        try {
            map<string, string> valueMap = getValuesFromXMLString(xmlLookup);
            
            if (!valueMap.isEmpty()){
                returnList.add(new SelectOption('', '-- Please Select --'));	
                
                for(string key :valueMap.keySet()){
                    string value = valueMap.get(key);
                    returnList.add(new SelectOption(key, value));				
                }
            
            }
        } catch (exception e){
			string errMsg = 'ERROR ... Internal Technical Error ' + e.getMessage() + ' : ' + e.getStackTraceString();
			system.debug(errMsg);				            
        }
		return returnList;
			
	}

	// parse xml to populate values in a map object
	private static map<string, string> getValuesFromXMLString(string xmlString){
	
		map<string, string> returnMap = new map<string, string>();

		TG_XmlDom dom = new TG_XmlDom(xmlString);
		TG_XmlNode root = dom.root;
		
		TG_XmlNode enumeration = root.getElementByTagName('Enumeration');
	
		list<TG_XmlNode> Items = enumeration.getElementsByTagName('Item');
		for (TG_XmlNode node :Items){
			string nodeType = node.getAttribute('Language'); //extract the English (en-gb) values only
			if (nodeType == 'en-gb' || string.isBlank(nodeType)){
				string key = node.getAttribute('Key');
				string value = node.nodeValue;
				returnMap.put(key, value);
			}

		}
		
system.debug (' @@@@@   VALUES RETURNED AND MAPPED ..  ' + returnMap);		
				
		return returnMap;
		
	}

}