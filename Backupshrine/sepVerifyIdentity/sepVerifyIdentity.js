import { LightningElement, api, track } from 'lwc';
import { fireEvent, registerListener, unregisterAllListeners } from "c/commonPubSub";
import field_is_mandatory from '@salesforce/label/c.field_is_mandatory';
import insertCaseRecord from '@salesforce/apex/SEP_IdProofingController.createCaseRecord';
import generateInitialPostRequestBody from '@salesforce/apex/SEP_VerifiyIdentityController.generateInitialPostRequestBody';
import generateInitialPutRequestBody from '@salesforce/apex/SEP_VerifiyIdentityController.generateInitialPutRequestBody';
import SEP_IdenityProofPageHeaderOne from '@salesforce/label/c.SEP_IdenityProofPageHeaderOne';
import SEP_IdenityProofPageHeaderTwo from '@salesforce/label/c.SEP_IdenityProofPageHeaderTwo';
import SEP_IDproofing_Redirection from '@salesforce/label/c.SEP_IDproofing_Redirection';
import SEP_IDproofing_RedirectionRemoval from '@salesforce/label/c.SEP_IDproofing_RedirectionRemoval';
import SEP_IDproofing_URL_params from '@salesforce/label/c.SEP_IDproofing_URL_params';
import SEP_IdenityProofPageHeader from '@salesforce/label/c.SEP_IdenityProofPageHeader';
import SEP_caseErrorMsg from '@salesforce/label/c.SEP_caseErrorMsg';
import { scrollToTop } from 'c/appUtility';


export default class SepVerifyIdentity extends LightningElement {

    @api consentObjectInfo;
    @api contactDetailObject;
    @api LexID = '';
    @api isRemovalFlow;
    @track hasDisambiguity = false;
    @track firstQueSet=true;
    @track spinner = false;
    @track required = true;
    @track value;
    @track primaryPhone;
    @track alternatePhone;
    @track idProofingError = 'Error';
    @track LexisNexisTechnicalError = 'Technical Error';
    @track idProofingTimeOut = 'ErrorTimeOut';
    @track idProofingBlock = 'userBlocked';
    @track lexId;
    @track SEP_IdenityProofPageHeaderOneEdited;
    @track SEP_IdenityProofPageHeaderTwoEdited;
    @track id_prodfing_redirection;
    @track caseRecordJSON = {
        LEXID__c: "",
        First_Name__c: "",
        Middle_Name__c: "",
        Last_Name__c: "",
        Date_Of_Birth__c: "",
        SSN_Tax_ID_Number__c: "",
        Current_Residential_Address__c: "",
        Unit_Apt_Number__c: "",
        City__c: "",
        State__c: "",
        Zip_Code__c: "",
        I_don_t_have_an_address__c: "",
        Minimum_Self_Exclusion_Period__c: "",
        Language_Preference__c: "",
        Primary_Email_Address__c: "",
        Unverified_Primary_Phone_Number__c: "",
        Unverified_Alternate_Phone_Number__c: "",
        Unverified_Alternate_Email_Address_1__c: "",
        Unverified_Alternate_Email_Address_2__c: "",
        Unverified_Alternate_Email_Address_3__c: "",
        Unverified_Alternate_Email_Address_4__c: "",
        Unverified_Alternate_Email_Address_5__c: "",
        Error_Message__c: "",
        Self_Exclusion_Registration_Source__c: "State Portal"
    };
    qResponse = {}
    qRequestBody = {
        "QuestionSetId": undefined,
        "Questions": []
    }
    conversationId = undefined;
    @track questions = [

    ]

    label = {
        field_is_mandatory,
        Indentity_Subheader: SEP_IdenityProofPageHeader,
        //Indentity_helpttext: "For added security, and to protect your identity - we would like to ask you a couple of questions. ",
        SEP_IdenityProofPageHeaderOne,
        SEP_IdenityProofPageHeaderTwo,
        maxTimeSpentPerQuestion: '60',
        id_prodfing_redirection : this.isRemovalFlow ? SEP_IDproofing_RedirectionRemoval : SEP_IDproofing_Redirection,
        SEP_IDproofing_URL_params,
        SEP_caseErrorMsg
    }
    saveAnswer(selecteddQues, selVal) {
        let ansMatch = false;
        let newAns = {
            "QuestionId": selecteddQues,
            "Choices":
                [
                    {
                        "Choice": selVal,
                    }
                ]
        }
        this.qRequestBody.Questions.forEach((q, i) => {
            if (q.QuestionId == selecteddQues) {
                q.Choices.Choice = selVal;
                ansMatch = true;
            }
        })


        !ansMatch && this.qRequestBody.Questions.push(newAns);
    }
    handleDisambiguity(){
        this.hasDisambiguity = true;
    }
    connectedCallback() {
        registerListener('SummaryValidation', this.handleValidation, this);
        this.spinner = true;
        let consentObj = JSON.parse(JSON.stringify(this.consentObjectInfo));
        if(!this.isRemovalFlow){
        this.populateEmailPhoneData();
        }else {
            this.primaryPhone = '';
            this.alternatePhone = '';
            consentObj.Address_Not_Provided__c = true;
        }      
        generateInitialPostRequestBody({
            objExclusion: consentObj,
            sPrimaryPhone: this.primaryPhone,
            sAlternatePhone: this.alternatePhone
        })
            .then(result => {
                if(result == 'Failure'){
                    window.location.href = this.id_prodfing_redirection + this.LexisNexisTechnicalError + this.label.SEP_IDproofing_URL_params;
                    return;
                }
                let wholeObject = JSON.parse(result);
                this.LexID = wholeObject && wholeObject.Status.LexID ? wholeObject.Status.LexID : '';
                if(wholeObject && wholeObject.Status.TransactionStatus == 'failed' && wholeObject.Status.TransactionReasonCode) { // authentication failed case
                    wholeObject.Status.TransactionReasonCode.Code == 'Mulesoft Down' ?  
                    window.location.href = this.id_prodfing_redirection + this.LexisNexisTechnicalError + this.label.SEP_IDproofing_URL_params :
                    this.createCaseRecord(wholeObject.Status.TransactionReasonCode.Code, wholeObject.Status.LexID);
                } else if(wholeObject && wholeObject.Status.TransactionStatus == 'pending' && !wholeObject.Status.LexID){
                    this.handleDisambiguity();
                    this.refineData(wholeObject);
                    this.spinner = false;
                } else {  
                    this.refineData(wholeObject);
                    this.spinner = false;
                }
                
            })
            .catch(error => {
                window.location.href = this.id_prodfing_redirection + this.LexisNexisTechnicalError + this.label.SEP_IDproofing_URL_params;
            })
    }
    renderedCallback(){
        this.id_prodfing_redirection =  this.isRemovalFlow ? SEP_IDproofing_RedirectionRemoval : SEP_IDproofing_Redirection;
    }
    handleValidation() {
        let invalidQ = [];
        this.questions.map((q, i) => {
            if (!q.value) {
                invalidQ.push(i);
                q.hasError = true;
            } else {
                q.hasError = false;
            }
        });
        if (!invalidQ.length) {               // all fields are valid
            this.spinner = true;
            generateInitialPutRequestBody({
                objReqBody: JSON.stringify(this.qRequestBody),
                sConversationId: this.conversationId
            }).then(result => {
                if(result == 'Failure'){
                    window.location.href = this.id_prodfing_redirection + this.LexisNexisTechnicalError + this.label.SEP_IDproofing_URL_params;
                    return;
                }
                this.qRequestBody={
                    "QuestionSetId": undefined,
                    "Questions": []
                }
                let wholeObject = JSON.parse(result);
                if (wholeObject && wholeObject.Status.TransactionStatus == 'pending') {  // authentication pending case
                    this.refineData(wholeObject);
                    scrollToTop();
                    this.firstQueSet= false;
                    this.spinner = false;
                } else if (wholeObject && wholeObject.Status.TransactionStatus == 'passed'){  // authentication success case
                    this.spinner = false;
                    fireEvent(this.pageRef, "sendnavigationresp", {
                        detail: {
                            isValid: false
                        }
                    });
                } else if(wholeObject && wholeObject.Status.TransactionStatus == 'failed') { // authentication failed case
                    this.questions = [];
                    if(wholeObject.Status.TransactionReasonCode.Code == 'individual_not_found'){
                        this.createCaseRecord('individual_not_found',this.lexId);
                    }
                    if(wholeObject.Status.TransactionReasonCode.Code == "denial_iauth_failed_too_recently"){
                        this.createCaseRecord('denial_iauth_failed_too_recently',this.lexId);
                    }
                    if(wholeObject.Status.TransactionReasonCode.Code == "insufficient_info_for_questions"){
                        this.createCaseRecord("insufficient_info_for_questions",this.lexId);
                    }
                    wholeObject.Status.TransactionReasonCode.Code == 'Mulesoft Down' ?  
                    window.location.href = this.id_prodfing_redirection + this.LexisNexisTechnicalError + this.label.SEP_IDproofing_URL_params :
                    wholeObject.Products.forEach(p => {
                        if(p.ProductType == "IIDQA"){
                            this.createCaseRecord(p.ProductStatus,this.lexId);
                        }
                    })
                    
                } else if(wholeObject && wholeObject.Status.TransactionStatus == 'error'){    // authentication error case
                    this.questions = [];
                    wholeObject.Products.forEach(p => {
                        if(p.ProductType == "IIDQA"){
                            this.createCaseRecord(p.ProductStatus,this.lexId);
                        }
                    })
                }
            })
                .catch(error => {
                    this.spinner = false;
                });
        } else {                            // some fields are invalid
            // this.createCaseRecord();
        }
    }
    refineData(wholeObject){
        let optionsArray = [];
        this.conversationId = wholeObject.Status.ConversationId;
        this.lexId = wholeObject.Status.LexID;
        wholeObject.Products.map(p => {
            if (p.ProductType == "IIDQA" && !this.hasDisambiguity) {
                this.qResponse = {
                    QuestionSet: p.QuestionSet
                }
                this.qRequestBody.QuestionSetId = p.QuestionSet.QuestionSetId;
            } else if (this.hasDisambiguity && p.ProductType == "Discovery"){
                this.qResponse = {
                    QuestionSet: p.QuestionSet
                }
                this.qRequestBody.QuestionSetId = p.QuestionSet.QuestionSetId;
                this.hasDisambiguity = false;
            }
        })
        this.qResponse.QuestionSet.Questions.forEach((q, i) => {
            q.Choices.forEach((c, j) => {
                optionsArray.push({
                    "label": c.Text.Statement,
                    "value": c.ChoiceId,
                    "id": `${c.ChoiceId}-${j}`
                })
            })
            q.options = [...optionsArray];
            q.hasError = false;
            optionsArray = [];
        })
        this.questions = this.qResponse.QuestionSet.Questions;
        let maxTimeAllowed = this.questions.length * parseInt(this.label.maxTimeSpentPerQuestion);
        this.SEP_IdenityProofPageHeaderOneEdited = this.label.SEP_IdenityProofPageHeaderOne.replace('&&', maxTimeAllowed);
        this.SEP_IdenityProofPageHeaderTwoEdited = this.label.SEP_IdenityProofPageHeaderTwo.replace('&&', maxTimeAllowed);
    }

    handleRadioSelect(event) {
        const selecteddQues = event.currentTarget.dataset.id;
        const selectedIndex = this.questions.findIndex(element => element.QuestionId == selecteddQues);
        this.questions[selectedIndex].value = event.detail.value;
        this.questions[selectedIndex].hasError = false;
        this.saveAnswer(selecteddQues, event.detail.value);
    }

    @api
    validate() {
        var isValid = true;
        fireEvent(this.pageRef, "flowvalidation", {
            detail: { isValid: true }
        });
        return {
            isValid: true,
            errorMessage: ""
        };
    }

    createCaseRecord(ProductStatus,lexId) {
        this.spinner = true;
        if (this.consentObjectInfo != null) {
            this.caseRecordJSON.LEXID__c = lexId // TO populate
            this.caseRecordJSON.First_Name__c = this.consentObjectInfo.First_Name__c;
            this.caseRecordJSON.Middle_Name__c = this.consentObjectInfo.Middle_Name__c ? this.consentObjectInfo.Middle_Name__c : '';
            this.caseRecordJSON.Last_Name__c = this.consentObjectInfo.Last_Name__c;
            this.caseRecordJSON.Date_Of_Birth__c = this.consentObjectInfo.Date_Of_Birth__c;
            this.caseRecordJSON.SSN_Tax_ID_Number__c = this.consentObjectInfo.Unique_Identifier_Number__c;
            this.caseRecordJSON.Current_Residential_Address__c = this.consentObjectInfo.Address__c ? this.consentObjectInfo.Address__c : '';
            this.caseRecordJSON.Unit_Apt_Number__c = this.consentObjectInfo.Unit_Apt__c ? this.consentObjectInfo.Unit_Apt__c : '';
            this.caseRecordJSON.City__c = this.consentObjectInfo.City__c ? this.consentObjectInfo.City__c : '';
            this.caseRecordJSON.State__c = this.consentObjectInfo.State__c ? this.consentObjectInfo.State__c : '';
            this.caseRecordJSON.Zip_Code__c = this.consentObjectInfo.Zip_Code__c ? this.consentObjectInfo.Zip_Code__c : '';
            this.caseRecordJSON.I_don_t_have_an_address__c = this.consentObjectInfo.Address_Not_Provided__c ? JSON.stringify(this.consentObjectInfo.Address_Not_Provided__c) : '';
            this.caseRecordJSON.Minimum_Self_Exclusion_Period__c = this.consentObjectInfo.Minimum_Self_Exclusion_Period__c;
            this.caseRecordJSON.Language_Preference__c = this.consentObjectInfo.Language_Preference__c;
            this.caseRecordJSON.Error_Message__c = this.label.SEP_caseErrorMsg + (ProductStatus || 'Id proofing failed');
        }
        insertCaseRecord({
            objCase: this.caseRecordJSON
        })
            .then(result => {
                if(ProductStatus == 'timed_out'){
                    window.location.href =  this.id_prodfing_redirection + this.idProofingTimeOut + this.label.SEP_IDproofing_URL_params;
                } else if(ProductStatus == "denial_iauth_failed_too_recently"){
                    window.location.href =  this.id_prodfing_redirection + this.idProofingBlock + this.label.SEP_IDproofing_URL_params;
                } else if (ProductStatus == "insufficient_info_for_questions"){
                    window.location.href = this.id_prodfing_redirection + this.idProofingError + this.label.SEP_IDproofing_URL_params;
                }   
                else{
                    window.location.href = this.id_prodfing_redirection + this.idProofingError + this.label.SEP_IDproofing_URL_params;
                } 
            })
            .catch(error => {
                window.location.href = this.id_prodfing_redirection + this.LexisNexisTechnicalError + this.label.SEP_IDproofing_URL_params;
            })
    }

    populateEmailPhoneData(){
        let alternateEmailsArray = [];
        if(this.contactDetailObject.length){
            for(let i = 0;i < this.contactDetailObject.length; i++){
                if(this.contactDetailObject[i].IsPrimary__c == true && this.contactDetailObject[i].Email_Address__c != null && this.contactDetailObject[i].Phone_number__c == null){
                    this.caseRecordJSON.Primary_Email_Address__c = this.contactDetailObject[i].Email_Address__c;
                }
                else if(this.contactDetailObject[i].IsPrimary__c == true && this.contactDetailObject[i].Phone_number__c != null){
                    this.caseRecordJSON.Unverified_Primary_Phone_Number__c = this.contactDetailObject[i].Phone_number__c;
                    this.primaryPhone = this.contactDetailObject[i].Phone_number__c;
                }
                else if(this.contactDetailObject[i].IsPrimary__c == false && this.contactDetailObject[i].Phone_number__c != null){
                    this.caseRecordJSON.Unverified_Alternate_Phone_Number__c = this.contactDetailObject[i].Phone_number__c;
                    this.alternatePhone = this.contactDetailObject[i].Phone_number__c;
                }
                else if(this.contactDetailObject[i].IsPrimary__c == false && this.contactDetailObject[i].Email_Address__c != null){
                    alternateEmailsArray.push(this.contactDetailObject[i].Email_Address__c); //This Array will contain all alternate emails
                }
            } 
            if (alternateEmailsArray.length) {
                [this.caseRecordJSON.Unverified_Alternate_Email_Address_1__c, this.caseRecordJSON.Unverified_Alternate_Email_Address_2__c, this.caseRecordJSON.Unverified_Alternate_Email_Address_3__c, this.caseRecordJSON.Unverified_Alternate_Email_Address_4__c, this.caseRecordJSON.Unverified_Alternate_Email_Address_5__c] = [...alternateEmailsArray];
            }
        }
    }
    checkInputValidity() {
        this.template.querySelectorAll('[data-id="inputfields"]').forEach((element) => {
            if ((element.required && !element.value)) {
                element.setCustomValidity(Please_provide_the_required_information);
            } else {
                element.setCustomValidity("");
            }
            element.reportValidity();
        });
    }

}