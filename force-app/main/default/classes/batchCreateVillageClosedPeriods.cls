Public Class batchCreateVillageClosedPeriods{

	private ApexPages.StandardController standardController;
	public Date startDate {get;set;}
	public Date endDate {get;set;}
	public string year {get;set;}
	public List<cVCP> cVCPList {get;set;} 
	public boolean showListSection {get;set;}
	public map<string, integer> DayMap = new map<string, integer>();
	public id vilId {get;set;}
	public string errormessage {get;set;}
	public boolean showerror {get;set;}



	public batchCreateVillageClosedPeriods(){
		setDayMap(); 
  		vilId = ApexPages.currentPage().getParameters().get('id');
		cVCPList = new List<cVCP>();
		year='';
		showListSection = false;
		showerror = false;
	}


	

 
	public void getYearStartDay(){
		date Jan1 = date.parse('01/01/'+year);
		Datetime dt = DateTime.newInstance(Jan1, Time.newInstance(0, 0, 0, 0));
		String dayOfWeek=dt.format('EEEE');	
		getSundayList(vilId,Jan1.addDays(DayMap.get(dayOfWeek)));
	}


	public void getSundayList(id villId, date dayAdjusted){

		date Jan1 = date.parse('01/01/'+year);
		date Dec31 = date.parse('31/12/'+year);
		set<Village_Closed_Period__c> VCPCreatedSet = new set<Village_Closed_Period__c>([SELECT Id, Name, From__c, To__c FROM Village_Closed_Period__c WHERE village__c =:vilid AND From__c >=:Jan1 AND To__c <=:Dec31]);
		set<Village_Closed_Period__c> VCPtoCompareSet = new set<Village_Closed_Period__c>();
		list<Village_Closed_Period__c> VCPListShow = new list<Village_Closed_Period__c>();


		date newday = dayAdjusted;
		WHILE(newday.year() < dayAdjusted.year()+1 ){

			Village_Closed_Period__c vc = new Village_Closed_Period__c();
			vc.Name = 'Sunday Closed';
			vc.Village__c = villId;
			vc.From__c = newday;
			vc.To__c = newday;
			vc.Active__c = true;

			system.debug('vc.From__c' + vc.From__c);
			system.debug('today1 ' + system.today());
			system.debug(system.today() < vc.From__c);
			system.debug(vc.From__c < system.today() );

			VCPtoCompareSet.add(vc);
			newday = newday.addDays(7);


			

		}

		for( Village_Closed_Period__c VCPtoAdd : VCPtoCompareSet ){
			if( VCPtoAdd.From__c < system.today() ){
				VCPtoCompareSet.remove(VCPtoAdd);
			}
        		for(Village_Closed_Period__c VCPCreated : VCPCreatedSet ){
        			IF((VCPtoAdd.From__c == VCPCreated.From__c && VCPtoAdd.to__c == VCPCreated.To__c) || (VCPtoAdd.From__c >= VCPCreated.From__c && VCPtoAdd.From__c  <= VCPCreated.To__c) || (VCPtoAdd.To__c >= VCPCreated.From__c && VCPtoAdd.To__c  <= VCPCreated.To__c) ){
        			VCPtoCompareSet.remove(VCPtoAdd);	
        			}

        		}   	
        }

        VCPListShow.addall(VCPtoCompareSet);

        for (Village_Closed_Period__c VCPer : VCPListShow){
        	cVCPList.add(new cVCP(VCPer));

        }

		if(cVCPList.size() > 0){
			showListSection = true;
			showerror = false;
		}
		else  {
			errormessage = 'There are no records to show';
			showerror = true;
		}
		
	}


	public pagereference save(){

		date Jan1 = date.parse('01/01/'+year);
		date Dec31 = date.parse('31/12/'+year);
		set<Village_Closed_Period__c> VCPCreatedSet = new set<Village_Closed_Period__c>([SELECT Id, Name, From__c, To__c FROM Village_Closed_Period__c WHERE village__c =:vilid AND From__c >=:Jan1 AND To__c <=:Dec31]);
		set<Village_Closed_Period__c> VCPtoCompareSet = new set<Village_Closed_Period__c>();
		list<Village_Closed_Period__c> VCPListtoAdd = new list<Village_Closed_Period__c>();

		for(cVCP VCPwrap: cVCPList) {
            if(VCPwrap.selected == true) {
            	VCPListtoAdd.add(VCPwrap.vcp);

            }
        }

        insert VCPListtoAdd;

        PageReference pg = new PageReference('/'+ vilid);
   
		return pg;
	}



	public pagereference cancel(){
		PageReference pg = new PageReference('/'+ vilid);
		return pg;
	}


    Public Pagereference selectAll() {
        for(cVCP VCPwrap : cVCPList){
            VCPwrap.selected = true;
     	}
     	return null;
 	}


 	Public Pagereference deselectAll() {
        for(cVCP VCPwrap : cVCPList){
            VCPwrap.selected = false;
     	}
     	return null;
 	}


 	public class cVCP{
        public Village_Closed_Period__c vcp {get; set;}
        public Boolean selected {get; set;}

        public cVCP(Village_Closed_Period__c thevcp) {
            vcp = thevcp;
            selected = false;

        }
    }


    public void setDayMap(){
        DayMap.put('Monday', 6);
        DayMap.put('Tuesday', 5);
        DayMap.put('Wednesday', 4);
        DayMap.put('Thursday', 3);
        DayMap.put('Friday', 2);
        DayMap.put('Saturday', 1);
        DayMap.put('Sunday', 0);      
    }

}