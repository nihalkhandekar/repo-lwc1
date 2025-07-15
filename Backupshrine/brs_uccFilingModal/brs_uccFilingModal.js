import { LightningElement,api,track } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import checkFilingNo from '@salesforce/apex/BRS_ReqCopyController.checkFilingNo';
import {
  ComponentErrorLoging
} from "c/formUtility";

import UCC_CopyReq_AddFile from "@salesforce/label/c.UCC_CopyReq_AddFile";
import UCC_CopyReq_FileNo from "@salesforce/label/c.UCC_CopyReq_FileNo";
import UCC_CopyReq_AddFile_modalDesc from "@salesforce/label/c.UCC_CopyReq_AddFile_modalDesc";
import Next from "@salesforce/label/c.Next";
import Generic_Input_Error_Message from "@salesforce/label/c.Generic_Input_Error_Message";
import Brs_ALEI_Placeholder from "@salesforce/label/c.Brs_ALEI_Placeholder";
import loading_brs from "@salesforce/label/c.loading_brs";
import Invalid_Filing_number from "@salesforce/label/c.Invalid_Filing_number"; 
import Expedite_copy from "@salesforce/label/c.Expedite_copy";
import Duplicate_Filing_Number_Error from "@salesforce/label/c.Duplicate_Filing_Number_Error";

export default class Brs_uccFilingModal extends LightningElement {
    @api isModalOpen;
    @api copytype;
    @api amount;
    @api filingDataList;
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track isLoading = false;
    @track isExpediteCopy = false;
    @track expediteCopyCheckboxOptions = [{
      label: Expedite_copy,
      value: Expedite_copy,
    }];
    @track labels={
      UCC_CopyReq_AddFile_modalDesc,
      UCC_CopyReq_FileNo,
      UCC_CopyReq_AddFile,
      Next,
      Generic_Input_Error_Message,
      Brs_ALEI_Placeholder,
    loading_brs,
    Invalid_Filing_number,
    Duplicate_Filing_Number_Error
    }
    closeModal() {
        const closeEvent = new CustomEvent("closemodal", {
            detail: true
          });
          this.dispatchEvent(closeEvent);
    }
  handleValidateKey(event){
    if(event.keyCode===13){
      this.validateFilingNumber();
    }
  }
    validateFilingNumber(){
      let inputElement = this.template.querySelector(".inputBox");
        if (this.filingNumber) {
          if(this.filingDataList && inputElement){
              let found = this.filingDataList.find(filing => filing.filingNo === this.filingNumber);
              if(!found){
                inputElement.setCustomValidity('');
                inputElement.reportValidity();
                this.validateUCCFiling(this.filingNumber);
              } else {
                inputElement.setCustomValidity(this.labels.Duplicate_Filing_Number_Error);
                inputElement.reportValidity();
              }
            }      
        }else {
          if(inputElement){
            inputElement.setCustomValidity(Generic_Input_Error_Message);
            inputElement.reportValidity();
          }
        }
        }
    handleFilingNumber(event){
        this.filingNumber = event.target.value;
        let inputElement = this.template.querySelector(".inputBox");
        inputElement.setCustomValidity("");
        inputElement.reportValidity();
    }
  handleBlur(event){
    this.filingNumber = event.target.value.trim();
  }

  onExpediteCopyCheck(){
   this.isExpediteCopy = !this.isExpediteCopy;
  }

  validateUCCFiling(filingNo){
    this.isLoading = true;
    checkFilingNo({
      filingNo : filingNo,
      copyType : this.copytype,
      amount : this.amount
    })
    .then(result => {
    if (result && result.filingDataList && result.filingDataList.length) {
          result = {
            ...result,
            isExpediteCopy: this.isExpediteCopy
          }
          const validFileNo = new CustomEvent("addfileno", {
              detail: result
            });
            this.dispatchEvent(validFileNo);
        }else{
          let inputElement = this.template.querySelector(".inputBox");
          inputElement.setCustomValidity(Invalid_Filing_number);
              inputElement.reportValidity();
            }
            this.isLoading = false;
    }).catch(error => {
      this.isLoading = false;
      ComponentErrorLoging("brs_uccFilingModal", "checkFilingNo", "", "", "Medium", error.message);
  });
  }
}