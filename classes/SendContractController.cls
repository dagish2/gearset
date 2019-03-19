public with sharing class SendContractController {
	public Id OpportunityID {get; set;} {this.OpportunityID = ApexPages.currentPage().getParameters().get('id');}
	public SendContractController() {		
		
	}

	public PageReference goBack() {
		return this.OpportunityID != null ?
						new PageReference('/' + this.OpportunityID) :
						new PageReference('/006');
	}

	public PageReference sendContract() {
		try {
			//submit to core class service
			OpportunityServices.sendContract(this.OpportunityID);

			//set success message
			ApexPages.addMessage(
				new ApexPages.Message(
					ApexPages.Severity.Confirm,
					'Closing'
				)
			);

		}
		catch(Exception pEx) { 
			ApexPages.addMessages(pEx); 
		}
		
		return null;
	}

}