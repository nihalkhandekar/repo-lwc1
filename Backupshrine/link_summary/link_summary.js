import {
  LightningElement,
  track,
  api,
  wire
} from 'lwc';
import {
  getRecord
} from 'lightning/uiRecordApi';
//import static resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
//Importing Custom Labels
import subText from '@salesforce/label/c.linkSummary_subText';
import summary_noCredLinkMsg from '@salesforce/label/c.summary_noCredLinkMsg';
import linkFindBiz_NoCredSelected from '@salesforce/label/c.linkFindBiz_NoCredSelected';
import linkFindBiz_EditSection from '@salesforce/label/c.linkFindBiz_EditSection';
import business from '@salesforce/label/c.business';
import linkFindBiz_Summary from '@salesforce/label/c.linkFindBiz_Summary';
import your_business_role from '@salesforce/label/c.your_business_role';
import statement_of_truth from '@salesforce/label/c.linkFindBiz_StatementOfTruth';
import summary_Creds from '@salesforce/label/c.summary_Creds';
import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError_Summary';
import confirmMsg1 from '@salesforce/label/c.linkFindBiz_Summary_ConfirmationMessage';
import confirmMsg2 from '@salesforce/label/c.linkFindBiz_Summary_ConfirmationMessage_Cntd';
import linkBiz_NotPrincipalMsg from '@salesforce/label/c.linkBiz_NotPrincipalMsg';
import linkBiz_NotPrincipalSubtext from '@salesforce/label/c.linkBiz_NotPrincipalSubtext';
import linkBiz_NotAgentMsg from '@salesforce/label/c.linkBiz_NotAgentMsg';
import linkBiz_NotAgentSubtext from '@salesforce/label/c.linkBiz_NotAgentSubtext';
import businesses from '@salesforce/label/c.businesses';
import linkBiz_listedAgent from '@salesforce/label/c.linkBiz_listedAgent';
import linkBiz_listedPrincipal from '@salesforce/label/c.linkBiz_listedPrincipal';
import summary_ProfCred from '@salesforce/label/c.summary_ProfCred';

import USER_ID from '@salesforce/user/Id'; // retreive the USER ID of current user.
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class Link_summary extends LightningElement {
  @api maindataobj;
  @api linkcredentials;
  @api showbizsummary = false;
  @track showCreds = true;
  @track sotChecked;
  @track value;
  @track editIcon = assetFolder + "/icons/edit.svg";
  @track buildingGroup = assetFolder + "/icons/no_credentials_added.svg";
  @track principalStatus = "LISTED PRINCIPAL";
  @track agentStatus = "LISTED AGENT";
  label = {
    subText,
    summary_noCredLinkMsg,
    linkFindBiz_NoCredSelected,
    linkFindBiz_EditSection,
    summary_Creds,
    your_business_role,
    statement_of_truth,
    business,
    linkFindBiz_Summary,
    validationMsg,
    confirmMsg1,
    confirmMsg2,
    businesses,
    linkBiz_listedAgent,
    linkBiz_listedPrincipal,
  };

  @track sot = this.label.confirmMsg1+' '+this.label.confirmMsg2;
  @track sotOptions = [];
  @track selectedBusiness = [];
  @track currentuser;
  @track hideCredSection = false;
  @track hideBizSection = false;
  @track error;
  @track updatedCredsList = [];
  @track business = [];

  noPrincipalData = {
    label: linkBiz_NotPrincipalMsg,
    sublabel: linkBiz_NotPrincipalSubtext
  };
  noAgentData = {
    label: linkBiz_NotAgentMsg,
    sublabel: linkBiz_NotAgentSubtext
  };

  @api //Code Review SP4
  get currentobj() {
    return this._currentobj;
  }

  set currentobj(value) {
    this._currentobj = value;
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  }) wireuser({
    error,
    data
  }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.currentuser = data.fields.Name.value;
      var tempObj = {
        label: this.currentuser.bold() + ', ' + this.label.confirmMsg1+' '+this.label.confirmMsg2.bold(),
        value: this.currentuser.bold() + ', ' + this.label.confirmMsg1+' '+this.label.confirmMsg2.bold()
      }
      this.sotOptions.push(tempObj);
    }
  }
  connectedCallback() {
    this.bizList = this.maindataobj.bizList;
    this.credsList = this.maindataobj.credsList;
    
    if(this.linkcredentials === true) {
      this.hideCredSection = true;
      if(!this.showbizsummary) {
        this.hideBizSection = true;
      }
    }
    var tempObject;
    this.maindataobj.bizList.forEach(element => {
      tempObject = {
        "id": element.id,
        "bizname": element.businessName
      };
      this.business.push(tempObject);
    });
    
    var result;
    var obj = this.maindataobj.credsList,
    result = obj.reduce(function (r, a) {
        r[a.businessRecordID] = r[a.businessRecordID] || [];
        r[a.businessRecordID].push(a);
        return r;
    }, Object.create(null));
    var tempData = result;
    for(var i in tempData) {
      var bname;
      if(i !== "null" && i !== null) {
        this.business.forEach(element => {
          if(element.id === i) {
            bname = element.bizname;
          }
        });
      } else {
        bname = summary_ProfCred;
      }
      let temp = {key:bname, value: tempData[i]};
      this.updatedCredsList.push(temp);
    }
    if(this.updatedCredsList.length) {
      var arr = this.updatedCredsList
      arr.sort((a, b) => {
        if (a.key < b.key) return -1
        return a.key > b.key ? 1 : 0
      });
      var index1 = arr.findIndex(p => p.key == "Professional credentials")
      var newItem = arr.splice(index1,1)
      arr.push(newItem[0])
    }
  }

  /**
   * @function pageRedirect - method written to redirect to specific pages for Edit
   * @param none
   */
  pageRedirect(event) {
    let businessID = event.currentTarget.dataset.id;
    if (!businessID) {
      businessID = false;
    }
    let pageName = event.target.name;
    // if (pageName === "matchcred") {
    //   if (!this.credsList.length) {
    //     pageName = "credsearch";
    //   }
    // }
    
    const editEvent = new CustomEvent('editevent', {
      detail: {
        pageName: pageName,
        bizid: businessID
      }
    });
    this.dispatchEvent(editEvent);
  }

  handleSot(event) {
    if (event.detail.result[0]) {
      this.sotChecked = true;
    }
	else{
      this.sotChecked = false;
    }
  }

  /**
   * @function validateScreen - method written to handle validation particular to this component
   * @param none
   */
  @api
  validateScreen() {
    return true;
  }


  /**
   * @function validationMessage - method written to set validation error message particular to this component
   * @param none
   */
  @api
  validationMessage() {
    return this.label.validationMsg;
  }
}