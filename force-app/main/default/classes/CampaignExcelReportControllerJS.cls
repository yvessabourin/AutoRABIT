global without sharing Class CampaignExcelReportControllerJS{

    Public CampaignExcelReportControllerJS(ApexPages.StandardController controller){ }

    @RemoteAction
    global static string readCampaigns(string inMarketingCampaignId){
        System.debug('Input inMarketingCampaignId: ' + inMarketingCampaignId);

        String returnHtml = '<b>There are no activites to show</b>';
        Id villageCampaignRTypeId = [SELECT Id FROM Recordtype where Name = 'Village Campaign' AND sObjectType = :SObjectType.Marketing_Campaign__c.getName()].Id;

        List<Marketing_Campaign__c> marketingCampaignChildListSOQL = new List<Marketing_Campaign__c>(
            [SELECT Id, name, village__c, village__r.name, Parent_Marketing_Campaign__r.name, Start_Date__c, End_Date__c
            FROM Marketing_Campaign__c
            WHERE Parent_Marketing_Campaign__c = :inMarketingCampaignId
            AND RecordtypeId = :villageCampaignRTypeId
            AND (Status__c = 'Approved' OR status__c = 'To be Approved')
            ORDER BY Name Desc]
        );
        System.debug('Get Campaigns by the parent campaign (' + inMarketingCampaignId + '): ' + marketingCampaignChildListSOQL.size());

        if (!marketingCampaignChildListSOQL.isEmpty()) {
            Map<Id, Marketing_Campaign__c> marketingCampaignMapGet = new Map<Id, Marketing_Campaign__c>(marketingCampaignChildListSOQL);
            System.debug('Campaigns: ' + marketingCampaignMapGet.keySet());

            List<Marketing_Activity__c> marketingActivityListSOQL = new List<Marketing_Activity__c>(
                    [SELECT Id, Name, Marketing_Campaign_Village__c, Channel__c, Marketing_Campaign__c, Marketing_Campaign__r.Name
                    FROM Marketing_Activity__c
                    WHERE Marketing_Campaign__c IN :marketingCampaignMapGet.keySet()
                    AND (Status__c = 'Approved' OR status__c = 'To be Approved')
                    ORDER BY Marketing_Campaign_Village__c ASC]
            );
            System.debug('Get Marketing Activity by campaigns: ' + marketingActivityListSOQL.size());

            if (!marketingCampaignChildListSOQL.isEmpty()) {

                List<string> channelList = new List<string>();
                List<string> marketingCampaignNameList = new List<string>();
                List<string> villageMarketingCampaignList = new List<string>();

                for(Marketing_Activity__c outMarketingActivity : marketingActivityListSOQL ){
                    String channelGet = outMarketingActivity.Channel__c;
                    String villageMarketingCampaignGet = outMarketingActivity.Marketing_Campaign_Village__c;

                    if(String.isNotBlank(channelGet) && !channelList.contains(outMarketingActivity.Channel__c) ){
                        channelList.add(channelGet);
                        marketingCampaignNameList.add(outMarketingActivity.Marketing_Campaign__r.name);
                    }

                    if(String.isNotBlank(villageMarketingCampaignGet) && !villageMarketingCampaignList.contains(outMarketingActivity.Marketing_Campaign_Village__c)){
                        villageMarketingCampaignList.add(villageMarketingCampaignGet);
                    }
                }
                System.debug('Get Channels: ' + channelList.size() + ' - ' + channelList);
                System.debug('Get Marketing Campaign Names: ' + marketingCampaignNameList.size() + ' - ' + marketingCampaignNameList);
                System.debug('Get Marketing Campaign Villages: ' + villageMarketingCampaignList.size() + ' - ' + villageMarketingCampaignList);

                if (!villageMarketingCampaignList.isEmpty() ) {
                    channelList.sort();
                    marketingCampaignNameList.sort();
                    villageMarketingCampaignList.sort();

                    returnHtml = createTableAssembler(villageMarketingCampaignList, marketingCampaignChildListSOQL, marketingActivityListSOQL, channelList);
                }
            }
        }

        return returnHtml;
    }

    private static String createTableAssembler (List<string> inVillageMarketingCampaignList, List<Marketing_Campaign__c> inMarketingCampaignChildList, List<Marketing_Activity__c> inMarketingActivityList, List<string> inChannelSet) {
        Map<String, String> villageColorsMap = new Map<String, String>{
            'Bicester' => '#d6f5d6',
            'La Roca' => '#ffc7b3',
            'Las Rozas' => '#ffeccc',
            'Kildare' => '#bef4f1',
            'Maasmechelen' => '#d3f8d3',
            'Fidenza' => 'LightCyan',
            'Ingolstadt' => '#b3b300',
            'La Vallée' => '#ffdacc',
            'La Vallee' => '#ffdacc',
            'Wertheim' => '#ffdacc'
        };
        String returnTableHtml = '';

        returnTableHtml = '<table id="my-table-id" border="1">';
        // Header Villages
        returnTableHtml += '<tr>';
        returnTableHtml += createTableAssemblerHeaderVillages(inVillageMarketingCampaignList, inMarketingCampaignChildList);
        returnTableHtml += '</tr>';

        // Header Marketing Campaigns
        returnTableHtml += '<tr>';
        returnTableHtml += '<td bgcolor="#cccccc"><b>Campaign Name</b></td>';
        returnTableHtml += createTableAssemblerHeaderMarketingCampaigns(inVillageMarketingCampaignList, inMarketingCampaignChildList, villageColorsMap);
        returnTableHtml += '</tr>';

        // Channels and Marketing Activities
        returnTableHtml += createTableAssemblerChannelsToActivities(inVillageMarketingCampaignList, inMarketingCampaignChildList, inMarketingActivityList, inChannelSet, villageColorsMap);

        returnTableHtml += '</table>';

        return returnTableHtml;
    }

    private static String createTableAssemblerHeaderVillages (List<string> inVillageMarketingCampaignList, List<Marketing_Campaign__c> inMarketingCampaignChildList) {
        String returnTableHtml = '';

        returnTableHtml += '<th bgcolor="#cccccc"><b>Marketing Campaigns</b></th>';

        for (Integer i = 0; i < inVillageMarketingCampaignList.size(); i++) {
            String villageNameGet = inVillageMarketingCampaignList[i];

            returnTableHtml +=
                '<td id="header' + i + '" colspan="' + getCountVillageName(villageNameGet, inMarketingCampaignChildList)+'" bgcolor="#cccccc" style="white-space: nowrap;">' +
                    '<b>' + villageNameGet + '</b>' +
                    '<br>' + getDateranges(villageNameGet, inMarketingCampaignChildList) +
                '</td>';
        }

        return  returnTableHtml;
    }

    private static String createTableAssemblerHeaderMarketingCampaigns (List<string> inVillageNameMarketingCampaignList, List<Marketing_Campaign__c> inMarketingCampaignChildList, Map<String, String> inVillageColorsMap) {
        String returnTableHtml = '';

        for(String outVillageName : inVillageNameMarketingCampaignList){

            for (Marketing_Campaign__c outMarketingCampaign : inMarketingCampaignChildList){
                if (outVillageName.equals(outMarketingCampaign.Village__r.Name)) {
                    String bgcolorGet = inVillageColorsMap.get(outVillageName);
                    returnTableHtml +=
                        '<td align="center" bgcolor="' + (String.isBlank(bgcolorGet) ? '#EEDD82' : bgcolorGet) + '">' +
                        '<b>' + outMarketingCampaign.Name + '' +
                        '</br>' + formateDate(outMarketingCampaign.Start_Date__C, outMarketingCampaign.end_date__c)+'</b>' +
                        '</td>';
                }
            }
        }

        return  returnTableHtml;
    }

    private static String createTableAssemblerChannelsToActivities (List<string> inVillageNameMarketingCampaignList, List<Marketing_Campaign__c> inMarketingCampaignChildList, List<Marketing_Activity__c> inMarketingActivityList, List<string> inChannelSet, Map<String, String> inVillageMap) {
        String returnTableHtml = '';

        for(string outChannel : inChannelSet){
            returnTableHtml +=
                '<tr align="center">' +
                '<td bgcolor="#cccccc">' +
                '<b>' + outChannel + '</b></td>';

            for(string outVillage : inVillageNameMarketingCampaignList){

                for (Marketing_Campaign__c outMarketingCampaign : inMarketingCampaignChildList ){
                    if(outVillage.equals(outMarketingCampaign.village__r.name)){
                        String bgcolorGet = inVillageMap.get(outVillage);
                        returnTableHtml +=
                            '<td valign="middle" style="white-space: nowrap;" align="center" bgcolor="' + (String.isBlank(bgcolorGet) ? '#EEDD82' : bgcolorGet) + '">' +
                            '<div>' + getActivities(outChannel, outVillage, inMarketingActivityList, outMarketingCampaign) + '</div>' +
                            '</td>';
                    }
                }
            }

            returnTableHtml += '</tr>';
        }

        return  returnTableHtml;
    }

    private static Integer getCountVillageName (String inVillageName, List<Marketing_Campaign__c> inMarketingCampaignChildList) {
        Integer count = 0;

        for(Marketing_Campaign__c outMarketingCampaign : inMarketingCampaignChildList){
            if (outMarketingCampaign.Village__c != null && inVillageName.equals(outMarketingCampaign.Village__r.Name)) {
                count++;
            }
        }

        return count;
    }

    private static string formateDate(Date inStartDate, Date inEndDate){
        return '<font size="1">' + inStartDate.format() + ' - ' + inEndDate.format() + '</font>';
    }

    public static string getActivities( string channel, string village,List<Marketing_Activity__c> theMAList, Marketing_Campaign__c MC  ){

        string returnvalue = '';
            for (Marketing_Activity__c MA : theMAList){
                if(MA.Channel__c == channel && MA.Marketing_Campaign_Village__c == village && MA.Marketing_Campaign__r.name == MC.name ){
                    returnvalue += MA.name.escapeHtml4()+'<br>';
                }
            }
    
        return returnvalue;
    }

    public static string getDateranges(string village, list<Marketing_Campaign__c> theVillageList){
        string daterange = '';
        list<Marketing_Campaign__c> thevillageMCs = new list<Marketing_Campaign__c>();
        set<date> theStartDates = new set<date>();
        set<date> theEndDates = new set<date>();
        list<date> theStartDatesList = new list<date>();
        list<date> theEndDatesList = new list<date>();

            for(Marketing_Campaign__c MC :theVillageList){
                if(MC.village__r.name == village){
                    thevillageMCs.add(MC);
                }
            }

            for (Marketing_Campaign__c MCamp : thevillageMCs ){
                if (!theStartDates.contains(MCamp.start_date__c)){
                    theStartDates.add(MCamp.start_date__c);
                }
                if (!theEndDates.contains(MCamp.end_date__c)){
                    theEndDates.add(MCamp.end_date__c);
                }
            }

        theStartDatesList.addall(theStartDates);
        theEndDatesList.addall(theEndDates);
        theStartDatesList.sort();
        theEndDatesList.sort();

        daterange += '<font size="2">'+theStartDatesList[0].format();

        daterange += ' - '+theEndDatesList[theEndDatesList.size()-1].format()+'</font>';

        return daterange;
    }

}