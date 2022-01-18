/*
	Enumerator definition class
	
	Created : 28/05/2015
	Author: Constantine Chimonides
	
	Modification History:
*/
public with sharing class apiEnum {

	public cls_Navigation Navigation;
	public class cls_Navigation {
		public cls_Navigation[] Navigation;
		public String x_Type;	//offer
		public cls_Property[] Property;
	}
	public class cls_Property {
		public String x_key;	//VillageId
		public String y_text;	//BV
	}
	public static apiEnum.cls_Navigation parse(String json){
		return (apiEnum.cls_Navigation) System.JSON.deserialize(json, apiEnum.cls_Navigation.class);
	}
}