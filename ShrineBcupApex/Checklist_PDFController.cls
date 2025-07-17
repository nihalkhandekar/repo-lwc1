/******************************************************************************************************************************************
* NAME:  Checklist_PDFController
* DESCRIPTION: This class is a custom controller for checklist PDF generation VF page
*
* @AUTHOR: Piyush Jogdand
* @DATE: 29/05/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------------------------
* Piyush Jogdand                    29/05/2020                       Created the first version
***************************************************************************************************************************************************/
public without sharing class Checklist_PDFController {
	public String questionnaireId {get;set;}
    public String url {get;set;}
    public GenerateChecklist.Checklist checklist{get;set;}
    public List<String> Ids{get;set;}
    public String language {get;set;}
	public String checklistStaticText {get;set;}
    public String Created_date {get;set;}
    public String customBusinessChecklist {get;set;}
    public String checklistSteps {get;set;}
    
    public Checklist_PDFController() {
            questionnaireId  = ApexPages.CurrentPage().getparameters().get(System.Label.Id).escapeHtml4();
        	String urlLang = ApexPages.CurrentPage().getparameters().get(System.Label.Language);
        	language = urlLang != Null ? urlLang : userInfo.getLocale();
			List<Checklist_language_mapping__mdt> mappings = Wizard_Utlity.geChecklistLanguageMapping(questionnaireId);
        	for(Checklist_language_mapping__mdt mapping : mappings){
                if(mapping.MasterLabel == 'checklistStaticText'){
                    checklistStaticText = mapping.value__c;
                }
                if(mapping.MasterLabel == 'staticText_CreatedOn'){
                    Created_date = mapping.value__c;
                }
                if(mapping.MasterLabel == 'customBusinessLabel'){
                    customBusinessChecklist = mapping.value__c;
                }
                if(mapping.MasterLabel == 'checklistStepsLabel'){
                    checklistSteps = mapping.value__c;
                }
        	}
    }
    
    public PageReference getChecklist() {
        try{
            if(questionnaireId != Null){
                checklist = GenerateChecklist.generateChecklistItem(questionnaireId, language);
           }
        }
        catch(Exception e){
            BOS_Utility.ExceptionHandler('Checklist_PDFController','getChecklist',null,null,'High',e,null);
        }
        return null;
    }
    
}