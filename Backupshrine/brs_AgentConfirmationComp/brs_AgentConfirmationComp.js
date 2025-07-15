import { LightningElement,track,api } from 'lwc';
import getAgentDetails from "@salesforce/apex/BRS_SendNotificationtoAgent.getAgentDetails";
import updateFiling from "@salesforce/apex/BRS_SendNotificationtoAgent.updateFiling";
import { ComponentErrorLoging } from "c/formUtility";
import checkboxLabel from "@salesforce/label/c.BRS_AgentConfirmCheckboxLabel";
import Agent_Confirmation_Heading from "@salesforce/label/c.Agent_Confirmation_Heading";
import Agent_Name from "@salesforce/label/c.Agent_Name";
import BRSLLCFirstScreen from "@salesforce/label/c.BRSLLCFirstScreen";
import Accepted from "@salesforce/label/c.Accepted";
import I_Accept from "@salesforce/label/c.I_Accept";
import I_Decline from "@salesforce/label/c.I_Decline";
import Declined_Confirmation from "@salesforce/label/c.Declined_Confirmation";
import Accepted_Confirmation from "@salesforce/label/c.Accepted_Confirmation";
import assetFolder from "@salesforce/resourceUrl/BRS_Assets";
import Enter_here_text from "@salesforce/label/c.Enter_here_text";
import name_electronic_signature from "@salesforce/label/c.name_electronic_signature";
import name_electronic_signature_required from "@salesforce/label/c.name_electronic_signature_required";
import Title_Required from "@salesforce/label/c.Title_Required";
import agent_appointment from "@salesforce/label/c.agent_appointment";
import Title from "@salesforce/label/c.Title";
import Decline_heading from "@salesforce/label/c.Decline_heading";
import Accepted_heading from "@salesforce/label/c.Accepted_heading";
import loading_brs from "@salesforce/label/c.loading_brs";
import Invalid_Page from "@salesforce/label/c.Invalid_Page";
export default class Brs_AgentConfirmationComp extends LightningElement {
    @track encryptedAgentId;
    @track encryptedAgentSelection;
    @track encryptedFilingId;
    @track accepted = false;
    @api agentRec;
    @track businessName;
    @track agentName;
    @track agentTitle;
    @track showTitle = false;
    @track nameSignature;
    @track title;
	  @track showConfirmation;
    @track isDisabled;
    @track confirmationMessage;
    @track isLoading;
    @track userIdIcon = assetFolder + "/icons/userIDproof.svg";
    @track personIcon = assetFolder + "/icons/person-outline.svg";
    @track calenderIcon = assetFolder + "/icons/calendar-outline.svg";
    @track acceptedIcon = assetFolder + "/icons/success-verification.svg";
    @track declinedIcon = assetFolder + "/icons/cross-circle-outline.svg";
    @track isLinkValid = true;
    
    label={
      checkboxLabel,
      Agent_Confirmation_Heading,
      Agent_Name,
      BRSLLCFirstScreen,
      Accepted,
      I_Accept,
      I_Decline,
      Declined_Confirmation,
      Accepted_Confirmation,
      Enter_here_text,
      name_electronic_signature,
      Title_Required,
      agent_appointment,
      name_electronic_signature_required,
      Title,
      Decline_heading,
      Accepted_heading,
      loading_brs,
      Invalid_Page
    }
    acceptCheckbox = [{ label: this.label.checkboxLabel, value: this.label.checkboxLabel, isDisabled: true, isChecked: true }];

    connectedCallback(){
        var url_string = document.location.href;
        var url = new URL(url_string);  
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
          var URLParams = url.searchParams;
          this.encryptedAgentId = URLParams.get('AgentId');
          this.encryptedAgentSelection = URLParams.get('Selection');
          this.encryptedFilingId = URLParams.get('FilingId');
          
          getAgentDetails({
            enAgentId: this.encryptedAgentId,
            enAgentSelection : this.encryptedAgentSelection,
			      enFilingId : this.encryptedFilingId
          })
          .then(result =>{
            this.isLinkValid = result.isLinkValid;
            if(result.isTempRec==true){
              this.agentRec = result.tempRec;
              if(this.agentRec.Temp_Type__c == 'Business'){
                this.showTitle = true;
              }
            }else{
              this.agentRec = result.agentRec;
              if(this.agentRec.Type__c == 'Business'){
                this.showTitle = true;
              }
            }
            this.businessName = this.agentRec.Business_ID__r.Name;
            var agentSelection = result.agentSelection;
			      var filingUpdated= result.filingUpdated;
            this.agentName = this.agentRec.Name__c;
			      if(filingUpdated){
              this.showConfirmation = true;
			        this.accepted = filingUpdated==this.label.Accepted;
              this.confirmationMessage = this.accepted ? this.label.Accepted_Confirmation :this.label.Declined_Confirmation;
            }
            else{
			  const isAccepted = agentSelection===this.label.Accepted
			  this.accepted =isAccepted ;
			  this.buttonTitle = isAccepted ? this.label.I_Accept: this.label.I_Decline
            }
          })
          .catch(error => {
            ComponentErrorLoging('brs_AgentConfirmationComp', 'getAgentDetails', '', '', 'High', error);
          });
        }
    }
    handleName(event){
      this.nameSignature = event.detail.value;
    }
    handleTitle(event){
      this.title = event.detail.value;
    }
    handleClick(event){
      this.clickedButtonLabel = event.currentTarget.dataset.id;
      const isValid =[...this.template.querySelectorAll('lightning-input')]
      .reduce((validSoFar, inputCmp) => {
                  inputCmp.reportValidity();
                  return validSoFar && inputCmp.checkValidity();
      }, true);
      if(isValid){
        this.handleFilingUpdate();
      }
    }

    handleFilingUpdate(){
      this.isLoading = true;
      const title = this.title ? this.title: '';
      let signName = this.nameSignature? this.nameSignature:''; 
      updateFiling({
        selection:this.clickedButtonLabel,
        enFilingId:this.encryptedFilingId,
        electronicSignature: signName,
        title: title
      })
      .then(result =>{
        this.showConfirmation = result;
        this.confirmationMessage = this.accepted ? this.label.Accepted_Confirmation :this.label.Declined_Confirmation; 
        this.isLoading = false;
      })
      .catch(error => {
        this.isLoading = false;
        ComponentErrorLoging('brs_AgentConfirmationComp', 'updateFiling', '', '', 'High', error);
      });
    }

    handleNameInputBlur(event){
      this.nameSignature = event.target.value.trim();
    }

    handleTitleInputBlur(event){
      this.title = event.target.value.trim();
    }
}