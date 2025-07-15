import { LightningElement,api,track} from 'lwc';
import {
    NavigationMixin
  } from 'lightning/navigation';
import SEP_IDproofing_Redirection from '@salesforce/label/c.SEP_IDproofing_Redirection';
import SEP_IDproofing_URL_params from '@salesforce/label/c.SEP_IDproofing_URL_params';
import SEP_IDproofing_RedirectionRemoval from '@salesforce/label/c.SEP_IDproofing_RedirectionRemoval';

export default class SepPageNavigator extends NavigationMixin(LightningElement) {

@api pageVariant;
@api ConsentRegistrationNumber;
@api Operation;
@api IsRemovalFlow;
@track isLoading = true;
@track label = {
    SEP_IDproofing_Redirection,
    SEP_IDproofing_URL_params,
    SEP_IDproofing_RedirectionRemoval
}
    connectedCallback() {
        try{
             window.location.href = this.label.SEP_IDproofing_Redirection + this.pageVariant+ '&ConsentRegistrationNumber='+this.ConsentRegistrationNumber+'&Operation='+this.Operation;
            if(this.IsRemovalFlow == true){
             window.location.href = this.label.SEP_IDproofing_RedirectionRemoval + this.pageVariant+ '&ConsentRegistrationNumber='+this.ConsentRegistrationNumber+'&Operation='+this.Operation+'&isRemoval='+this.IsRemovalFlow;
            }
            // setTimeout(() => {
            //     this[NavigationMixin.Navigate]({
            //         type: 'comm__namedPage', //type: 'comm__namedPage'//standard__namedPage
            //         attributes: {
            //             name: 'ConfirmationPage__c' //name: 'COS_Dashboard__c'
            //         }, state: {
            //             pageVariant: this.pageVariant,
            //             ConsentRegistrationNumber : this.ConsentRegistrationNumber
            //         }
            //     });
            // }, 1000);
           
        }catch(objExp){
         console.log('objExp',objExp);
        }
    }
}