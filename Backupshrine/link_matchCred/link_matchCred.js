import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import linkFindBiz_Remove from '@salesforce/label/c.linkFindBiz_Remove';
import linkFinBiz_unlinkAlertMsg from '@salesforce/label/c.linkFinBiz_unlinkAlertMsg';
import linkFindBiz_AddBusinessMsg from '@salesforce/label/c.linkFindBiz_AddBusinessMsg';
import linkFindBiz_RemoveBusinessMsg from "@salesforce/label/c.linkFindBiz_RemoveBusinessMsg";
import linkFindBiz_RemoveBusiness from '@salesforce/label/c.linkFindBiz_RemoveBusiness';
import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError_Cred';
import USER_ID from '@salesforce/user/Id'; // retreive the USER ID of current user.
import NAME_FIELD from '@salesforce/schema/User.Name';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import currentUserData from "@salesforce/apex/BusinessSearchController.getCurrentUserData";
import checkCredential from "@salesforce/apex/BusinessSearchController.getLinkedCredentials";
import linkFindBiz_linkCredMsg from '@salesforce/label/c.linkFindBiz_linkCredMsg';
import linkFindBiz_NoCredSelected from '@salesforce/label/c.linkFindBiz_NoCredSelected';
import bizDashboard_MatchCreds from '@salesforce/label/c.bizDashboard_MatchCreds';
import linkFindCred_bizCredLinkMsg from '@salesforce/label/c.linkFindCred_bizCredLinkMsg';
import linkCred_ProfCredFor from '@salesforce/label/c.linkCred_ProfCredFor';
import linkBiz_selectRole from '@salesforce/label/c.linkBiz_selectRole';
import linkCred_AlreadyLinkedError from '@salesforce/label/c.linkCred_AlreadyLinkedError';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { ComponentErrorLoging } from "c/formUtility";

export default class Link_matchCred extends LightningElement {
    @api maindataobj;
    @track bizList;
    @track credsList;
    @track tempArr = [];
    @track removeId;
    @track unlinkPopUp = false;
    @track modalopen = false;
    @track currentuser;
    @track currentContactId;
    @track validationValue;
    @track credAlreadyLinked = false;
    @track buildingGroup = assetFolder + "/icons/no_credentials_added.svg";
    @track remove = linkFindBiz_Remove
    @track hasDropdown = true;
    @track dropDownValue;
    @track pagename;
    @track isNextClicked = false;
    label = {
        linkFinBiz_unlinkAlertMsg,
        linkFindBiz_AddBusinessMsg,
        linkFindBiz_RemoveBusinessMsg,
        linkFindBiz_RemoveBusiness,
        validationMsg,
        linkFindBiz_linkCredMsg,
        linkFindBiz_NoCredSelected,
        linkFindCred_bizCredLinkMsg,
        bizDashboard_MatchCreds,
        linkBiz_selectRole,
        linkCred_AlreadyLinkedError,
    };

    connectedCallback() {
        sessionStorage.removeItem('businessid');
        this.credsList = this.maindataobj.credsList;
        this.bizList = this.maindataobj.bizList;
        currentUserData()
        .then(result =>{
            var userdata = result;
            this.currentContactId = userdata.ContactId;
            this.currentuser = userdata.Name;
            let tempCredArray = [];
            this.bizList.forEach(element => {
                tempCredArray.push({
                    id: element.id,
                    label: element.businessName,
                    value: element.id
                })
            });
            tempCredArray.push({
                id: "PC",
                label: linkCred_ProfCredFor + ' ' + this.currentuser,
                value: 'PC',
            })
            this.dropDownValue = tempCredArray;
        }).catch(error =>{
            ComponentErrorLoging("link_matchCred", 'currentUserData', '', '', 'High', error.message);
        });

        checkCredential()
        .then(result =>{
            this.credMap = result;
        })
        .catch(error =>{
            ComponentErrorLoging("link_matchCred", 'checkCredential', '', '', 'High', error.message);
        });
    }

    handlecredmatch(event) {
        let credid = event.detail.credid;
        let bname = event.detail.bname;
        let tempcred = [];
        let tempElement;
        this.credsList = JSON.parse(JSON.stringify(this.credsList));
        this.credsList.forEach(element => {
            element.credAlreadyLinked = false;
            if (element.eLicense_Credential_ID === credid) {
                if (bname === 'PC') {
                    element.businessRecordID = null;
                    element.isContactCred = true;
                    element.errorMsg = "";
                } else {
                    element.businessRecordID = bname;
                    element.isContactCred = false;
                    element.errorMsg = "";
                }
                tempElement = element;
            }
        });
        tempElement = JSON.parse(JSON.stringify(tempElement));
        this.tempArr.push(tempElement);
        this.tempArr = JSON.parse(JSON.stringify(this.tempArr));
        let array = this.tempArr;
        const result = [];
        const map = new Map();
        //filtering unique values in the array
        for (const val of array) {
            if (!map.has(val.eLicense_Credential_ID)) {
                map.set(val.eLicense_Credential_ID, true); // set any value to Map
                result.push(val);
            }
        }
        this.tempArr = result;
        this.tempArr = JSON.parse(JSON.stringify(this.tempArr));
        const credmatch = new CustomEvent("updatecredmatch", {
            detail: this.credsList
        });
        this.dispatchEvent(credmatch);
        this.getValidationValue();
    }

    handleRemove(event) {
        this.removeId = event.detail;
        this.handleUnlinkButton();
    }

    handleUnlinkButton() {
        var accId = this.removeId;
        let tempData = [];
        this.credsList.forEach(element => {
            if (element.eLicense_Credential_ID != accId) {
                tempData.push(element);
            }
        });
        this.credsList = JSON.parse(JSON.stringify(tempData));
        const removeBusiness = new CustomEvent("aftercredremove", {
            detail: this.credsList
        });
        this.dispatchEvent(removeBusiness);
    }

    /**
     * @function validateScreen - method written to handle validation particular to this component
     * @param none
     */
    @api
    validateScreen() {
        this.isNextClicked = true;
         if(this.credsList.length!=0){
            var validateValue = this.getValidationValue();
            if(validateValue === true) {
                this.noErrorDispatch();
            }
            return validateValue;
        }
        else{
            this.noErrorDispatch();
             return true;
        }
    }

    getValidationValue(){
        this.credsList = JSON.parse(JSON.stringify(this.credsList));
        this.credsList.forEach(element => {
            var externalId = element.eLicense_Credential_ID+'-'+element.eLicense_Contact_ID;
            if(Object.keys(this.credMap).length!=0){
                var credExternalId = this.credMap[externalId];
                if(credExternalId) {
                    var conId = this.currentContactId;
                    if(element.isContactCred==true && credExternalId.includes(conId)){
                        element.credAlreadyLinked = true;
                        element.errorMsg = this.label.linkCred_AlreadyLinkedError;
                        //already linked error to be shown
                    }
                    else if(element.businessRecordID!=null && credExternalId.includes(element.businessRecordID)){
                        element.credAlreadyLinked = true;
                        element.errorMsg = this.label.linkCred_AlreadyLinkedError;
                        //already linked
                    }
                }
            }
            
            if(element.isContactCred==null && element.businessRecordID==null){
                element.linkValueNotSelected = true;
                if(this.isNextClicked) {
                    element.errorMsg = this.label.linkBiz_selectRole;
                }
                // No selection made error to be displayed here
            } else {
                element.linkValueNotSelected = false;
                if(!element.errorMsg) {
                    element.errorMsg = "";
                }
            }
        });
        var validationValue = this.credsList.every(function(listelement){
            if(listelement.credAlreadyLinked || listelement.linkValueNotSelected){
                this.credAlreadyLinked = true;
                return false;
            }
            return true;
        }, this);
        this.validationValue = validationValue;
        return validationValue;
    }

    /**
    * @function validationMessage - method written to set validation error message particular to this component
    * @param none
    */
    @api
    validationMessage(){
       return this.label.validationMsg;
    }

    /**
    * @function noErrorDispatch - method written to dispatch an event to parent inorder to remove the error tooltip on selection
    * @param none
    */
    noErrorDispatch() {
        const noErrorEvent = new CustomEvent('noerror');
        this.dispatchEvent(noErrorEvent);
    }
}