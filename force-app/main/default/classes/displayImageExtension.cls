Public Class displayImageExtension {

    String recId;
    
    public displayImageExtension(ApexPages.StandardController controller) {
        recId = controller.getId();    
    }
    
    public List<String> getFileIds() {
        List<String> fileIds = new list<string>();
        List<Attachment> attachedFiles = [SELECT Id, name FROM Attachment WHERE parentId =:recId order By LastModifiedDate ASC];
        
        if( attachedFiles != null && attachedFiles.size() > 0 ) {
            for(Attachment afile : attachedFiles)
            {
                IF (afile.Name.right(3) == 'jpg' || afile.Name.right(3) == 'png')
                {
                        fileIds.add(afile.Id);
                }
            }
        }
        return fileIds;    
    }
}