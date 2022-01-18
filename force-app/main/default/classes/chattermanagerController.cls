public with sharing class chattermanagerController {



    public string tabOpt {get;set;}
    public string selectedUserId{get; set;}
    public string selectedGroupId{get; set;}
    public string selectedFrequency{get;set;}

    // Multiselect controller variables        
    public SelectOption[] selectedUsers { get; set; }
    public SelectOption[] usersAvailable { get; set; }
     
    public list<CollaborationGroupMember> CGMs {get; set;}
    
    public list<CollaborationGroupMember> selectedCGMs {get; set;}
    
    
    public chattermanagerController(){
        
        tabOpt = 'userAndGroups';
        selectedUsers = new List<SelectOption>();
        selectedFrequency = 'N';
        usersAvailable = this.getUsers();
        
    }
    
    public pagereference refreshTable(){
        queryCollaborationGroupMembers();
        return null;
    }
    
    // refresh list of users associated with selected group
    public pagereference refreshUsers(){
        this.selectedusers = new list<SelectOption>();
        usersAvailable = this.getUsers();
        queryCollaborationGroup();
        return null;
    }   
    
    private void queryCollaborationGroup(){
        
        // retrieve list of group members
        selectedCGMs = [SELECT CollaborationGroupId,CollaborationRole, MemberId, Member.name, member.profile.name, member.userrole.name, NotificationFrequency, CollaborationGroup.name 
                                    FROM CollaborationGroupMember 
                                    where CollaborationGroupId = :selectedGroupId
                                    and NotificationFrequency = :selectedFrequency
                                    ORDER BY member.profile.name, Member.name];
    
        list<integer> removeIndexList = new list<integer>();
        
        // add associated members to selected users list
        for (CollaborationGroupMember cgm :selectedCGMs){                                           
            selectedUsers.add(new SelectOption(cgm.MemberId, '(' + cgm.member.profile.name + ') ' + cgm.member.Name + ' - ' + cgm.member.UserRole.name));
            //cgm.Member.name
            
            integer index = 0;
            for (SelectOption o :usersAvailable){ // note user for later removal from available users list
                if (o.getValue() != 'none'){
                    if (o.getValue() == cgm.MemberId){                  
                        removeIndexList.add(index);
                        break;
                    }
                }
                index ++;
            }    
        }
        // remove users already associated with group from available users list
        if (!removeIndexList.isEmpty()){
            integer itemsRemoved = 0;
            for (integer i :removeIndexList){                                       
                usersAvailable.remove( i - itemsRemoved);
                itemsRemoved ++;
            }
        }
 
    }
    
    public list<CollaborationGroupMember> queryCollaborationGroupMembers()
    {        
        
        CGMs = [SELECT CollaborationGroupId,CollaborationRole,Member.name,NotificationFrequency, CollaborationGroup.name 
                                    FROM CollaborationGroupMember 
                                    where MemberId = :selectedUserId
                                    ORDER BY Member.name];
                                                               
        Return CGMs;
    }
    
    public list<SelectOption> getUsers(){
        
        List<SelectOption> options = new List<SelectOption>();
        List<User> userList = [select Id, Name, UserRole.name, profile.name from User where isActive = true order by profile.name, Name];
        
        options.add(new SelectOption('none', '-- Select User --'));
        for(User u :userList){
            SelectOption o = new SelectOption(u.Id, '(' + u.profile.name + ') ' + u.Name + ' - ' + u.UserRole.name);
            options.add(o);      
        }
        
        return options;
    
    }
    
     public list<SelectOption> getChatterGroups(){
        
        List<SelectOption> groupoptions = new List<SelectOption>();
        List<collaborationgroup> collaborationgroupList = [select Id, Name from collaborationgroup order by Name];
        
        groupoptions.add(new SelectOption(' -- Select Group --', '-- Select Group--'));
        for(collaborationgroup g :collaborationgroupList){
            SelectOption o = new SelectOption(g.Id, g.Name);
            groupoptions.add(o);        
        }
        
        return groupoptions;
    
    }
    
    public List<SelectOption> getFrequencies() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('N','Never'));
        options.add(new SelectOption('D','Daily'));
        options.add(new SelectOption('P','Every Post'));
        options.add(new SelectOption('W','Weekly'));
        return options;
    }
        
    
    public PageReference SaveChanges() {
        
        try{
            Upsert CGMs;
        }
        catch(exception e){
            system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Saving records. Technical Details: ' + e.getMessage()));
            return null; 
        }
        
        return null;
    }
    
    public PageReference addMember() {
        CollaborationGroupMember cm = new CollaborationGroupMember(MemberId=selectedUserId, NotificationFrequency='N', CollaborationRole='Standard');
        CGMs.add(cm);
       
        return null;
    }

    // Apply user selection changes to group membership
    public pageReference saveGroup(){

        if (this.selectedCGMs == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                    'No group selected, please validate before continuing'));
            return null;                                        
        }
                
        list<CollaborationGroupMember> deleteList = new list<CollaborationGroupMember>();
        list<CollaborationGroupMember> insertList = new list<CollaborationGroupMember>();
        
        // Compare selected users with list of members already associated with group to
        // determine which users are required to be inserted as group members
        boolean found = false;
        for (SelectOption o :this.selectedusers){
            if (o.getValue() != 'none'){
                found = false;
                for (CollaborationGroupMember cgm :selectedCGMs){
                    if (cgm.MemberId == o.getValue()){
                        found = true;
                        break;
                    }
                }
                if (!found){ // create list of new group membership records to add
                    insertList.add(new CollaborationGroupMember(MemberId= o.getValue(), 
                                                                NotificationFrequency= selectedFrequency, 
                                                                CollaborationRole='Standard',
                                                                CollaborationGroupId = selectedGroupId)); 
                } 
            }
        }       

        // Compare members currently associated with group with selected users to determine
        // which users to remove from group
        for (CollaborationGroupMember cgm :selectedCGMs){
            found = false;
            for (SelectOption o :this.selectedusers){
                if (cgm.MemberId == o.getValue()){
                    found = true;
                    break;
                }
            }
            if (!found){ // create list of group membership records to remove
                deleteList.add(cgm); 
            } 
        }    
        
        try {   // Perform DML operations on Group Mmembership records         
            Database.UpsertResult[] upsertResultList = null;
            Database.DeleteResult[] deleteResultList = null;
            
            if (deleteList.size() > 0){
                deleteResultList = Database.delete(deleteList, false);
                for (Database.DeleteResult r : deleteResultList){  // Examine DML errors
                    if (!r.isSuccess()){  
                        for (Database.Error e : r.getErrors()){  
                            // errors here
                            StatusCode status = e.getStatusCode();
                            string errMsg = e.getMessage();
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                'Error Saving record. Technical Details: ' + status +  ' : ' + errMsg + ' : ' + r.getId())); 
                        }
                    }
                }               
            }
            
            if (insertList.size() > 0){
                upsertResultList = Database.upsert(insertList, false);
                for (Database.UpsertResult r : upsertResultList){  // Examine DML errors
                    if (!r.isSuccess()){  
                        for (Database.Error e : r.getErrors()){  
                            // errors here
                            StatusCode status = e.getStatusCode();
                            string errMsg = e.getMessage();
                            if (status == StatusCode.DUPLICATE_VALUE){                              
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                    'Error Saving record. You are attempting to insert at least one user who is already a member of this group.'
                                    + '\r\n Please ensure all users are not already a group member with a different frequency setting'));                           
                            } else {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                    'Error Saving record. Technical Details: ' + r.getId() + ' : ' + status +  ' : ' + errMsg + ' : ' + e.getFields()));
                            } 
                        }
                    }
                }  
            }
            
            refreshUsers();
        
        }
        catch(exception e){
            system.debug('ERROR ...ERROR ... ERROR ' + e.getMessage() + ' : ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Saving records. Technical Details: ' + e.getMessage()));
            return null; 
        }
        
        return null;
    }

    
}