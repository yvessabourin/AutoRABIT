<aura:application access="GLOBAL" extends="ltng:outApp" >
    
    <ltng:require styles="/resource/slds090/assets/styles/salesforce-lightning-design-system.min.css"/>
    
    <div class="slds">
        <div class="slds-page-header">
          <div class="slds-grid">
            <div class="slds-col slds-has-flexi-truncate">
              <p class="slds-text-heading--label"></p>
              <div class="slds-grid">
                <div class="slds-grid slds-type-focus slds-no-space">
                    <h1 class="slds-text-heading--medium slds-truncate" title="My Expenses"></h1>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="slds-col--padded slds-p-top--large">
    	<c:shareCompVisit/>
    	</div>
        
           </div>
	
</aura:application>