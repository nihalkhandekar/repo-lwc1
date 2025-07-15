import { LightningElement, track, api } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import unlinkCredential from "@salesforce/apex/AccountDashboard.unlinkCredential";
import businessProfile_unlink from "@salesforce/label/c.businessProfile_unlink";
import businessProfile_unlinkCredentials from "@salesforce/label/c.businessProfile_unlinkCredentials";
import businessProfile_unlinkCredentials1 from "@salesforce/label/c.businessProfile_unlinkCredentials1";
import businessProfile_unlinkCredentials2 from "@salesforce/label/c.businessProfile_unlinkCredentials2";
import businessProfile_credentialsExpires from "@salesforce/label/c.businessProfile_credentialsExpires";
import businessProfile_credentialsCode from "@salesforce/label/c.businessProfile_credentialsCode";
import businessProfile_credentialsType from "@salesforce/label/c.businessProfile_credentialsType";
import businessProfile_credentialsIssueDate from "@salesforce/label/c.businessProfile_credentialsIssueDate";
import businessProfile_credentialsAddress from "@salesforce/label/c.businessProfile_credentialsAddress";
import businessProfile_credentialsStatus from "@salesforce/label/c.businessProfile_credentialsStatus";
import businessProfile_credentialsStatusReason from "@salesforce/label/c.businessProfile_credentialsStatusReason";
import businessProfile_credentialsEffectiveDate from "@salesforce/label/c.businessProfile_credentialsEffectiveDate";
import businessProfile_load_more from "@salesforce/label/c.businessProfile_load_more";
import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";
import businessProfile_maddress from "@salesforce/label/c.businessProfile_maddress";
import businessProfile_credentialsPrimaryaddress from "@salesforce/label/c.businessProfile_credentialsPrimaryaddress";
import { ComponentErrorLoging } from "c/formUtility";

export default class BosCredentialsCard extends LightningElement {
  @track isPending = false;
  @track isActive = false;
  @track isInactive = false;
  @track activeIcon = assetFolder + "/icons/green-checkmark-license.svg";
  @track pendingIcon = assetFolder + "/icons/yellow-pending-license.svg";
  @track expiredIcon = assetFolder + "/icons/expired-license.png";
  @track ellipsisIcon = assetFolder + "/icons/ellipsis-vertical-outline.svg";
  @track buildingGroup = assetFolder + "/icons/no_credentials_added.svg";
  @track showDetails = false;
  @track loadMoreBlock = false;
  @track dataLength = 2;
  @track itemData = [];
  @track showLess = false;
  @track showEllipsis = false;
  @track unlinkPopUp = false;
  @track modalopen = false;
  @track currentCredId = "";
  @track currentAccId = "";
  @api businessId = "";
  @api category;
  @track showSuccessMsg = false;
  @track compName = "bosCredentialsCard";
  @track severity = "High";
  @api
  get carddata() {
    return this._carddata;
  }
  set carddata(value) {
    this._carddata = value;
    let tempArr = [];
    let count = 0;
    this.carddata.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
      } else {
        this.loadMoreBlock = true;
      }
    });
    this.itemData = tempArr;
  }

  label = {
    businessProfile_unlink,
    businessProfile_unlinkCredentials,
    businessProfile_unlinkCredentials1,
    businessProfile_unlinkCredentials2,
    businessProfile_credentialsExpires,
    businessProfile_credentialsCode,
    businessProfile_credentialsType,
    businessProfile_credentialsIssueDate,
    businessProfile_credentialsAddress,
    businessProfile_credentialsStatus,
    businessProfile_credentialsStatusReason,
    businessProfile_credentialsEffectiveDate,
    businessProfile_load_more,
    businessProfile_show_less,
    businessProfile_maddress,
    businessProfile_credentialsPrimaryaddress,
  };
  connectedCallback() {
    if (this.category == "pending") {
      this.isPending = true;
    } else if (this.category == "active") {
      this.isActive = true;
    } else if (this.category == "inactive") {
      this.isInactive = true;
    }
    this.itemData.forEach(element => {
      element.showDetails = false;
    });
  }
  handleAccordion(event) {
    let showdetailsFlag;
    let title = event.currentTarget.dataset.id;
    let activeClass = this.template.querySelector(`[data-name="${title}"]`);
    this.itemData.forEach(element => {
      if (element.eLicense_Credential_ID == title) {
        showdetailsFlag = element.showDetails;
        showdetailsFlag = !showdetailsFlag;
        element.showDetails = showdetailsFlag;
      }
    });
    if (showdetailsFlag) {
      // this.itemData.forEach(element => {
      //     if (element.Id == title) {
      //         element.showDetails = true;
      //     }
      // });
      activeClass.classList.add("show");
    } else {
      // this.itemData.forEach(element => {
      //     // element = JSON.parse(JSON.stringify(element));
      //     if (element.Id == title) {
      //         element.showDetails = false;
      //     }
      // });
      activeClass.classList.remove("show");
    }
  }
  handleAccordionKey(event) {
    if (event.keyCode == 13) {
      this.handleAccordion(event);
    }
  }
  handleLoadMore() {
    this.dataLength = this.dataLength + 2;
    let count = 0;
    let tempArr = [];

    this.carddata.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
        this.loadMoreBlock = false;
      } else {
        this.loadMoreBlock = true;
      }
    });
    this.itemData = tempArr;
    this.itemData = JSON.parse(JSON.stringify(this.itemData));
    let originalLength = this.carddata.length;
    let currentLength = this.itemData.length;
    if (originalLength === currentLength) {
      this.showLess = true;
      this.loadMoreBlock = false;
    }
  }
  handleShowLess() {
    this.showLess = false;
    this.loadMoreBlock = true;
    this.dataLength = 2;
    let count = 0;
    let tempArr = [];

    this.carddata.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
      }
    });
    this.itemData = tempArr;
    this.itemData = JSON.parse(JSON.stringify(this.itemData));
  }
  handleExpandEllipsis(event) {
    this.showEllipsis = !this.showEllipsis;
    let title = event.currentTarget.dataset.id;
    let activeClass = this.template.querySelector(`[data-name="${title}"]`);
    if (this.showEllipsis) {
      activeClass.classList.add("show");
    } else {
      activeClass.classList.remove("show");
    }
  }
  handleExpandEllipsisKey(event) {
    if (event.keyCode == 13) {
      this.handleExpandEllipsis(event);
    }
  }
  handleUnlink(event) {
    let currentId = event.currentTarget.dataset.id;
    this.currentCredId = currentId;
    this.unlinkPopUp = true;
    this.modalopen = true;
    let title = event.currentTarget.dataset.name;
    let activeClass = this.template.querySelector(`[data-name="${title}"]`);
    this.showEllipsis = !this.showEllipsis;
    if (this.showEllipsis) {
      activeClass.classList.add("show");
    } else {
      activeClass.classList.remove("show");
    }
  }
  handleUnlinkKey(event) {
    if (event.keyCode == 13) {
      this.handleUnlink(event);
    }
  }
  handleClose() {
    this.showSuccessMsg = false;
  }
  closeModal() {
    this.modalopen = false;
  }
  handleUnlinkButton() {
    this.closeModal();
    var accId = this.businessId;
    var credId = this.currentCredId;
    let tempArr = [];
    this.itemData.forEach(element => {
      if (element.eLicense_Credential_ID != credId) {
        tempArr.push(element);

      }
    });
    this.itemData = tempArr;
    this.itemData = JSON.parse(JSON.stringify(this.itemData));
    this.carddata = this.itemData;
    if (this.itemData.length <= 2) {
      this.showLess = false;
      this.loadMoreBlock = false;
    }
    const changecred = new CustomEvent("credunlink", {
      detail: credId
    });

    this.dispatchEvent(changecred);
    unlinkCredential({
      accId,
      credId
    })
      .then(result => {
        this.showSuccessMsg = true;
		location.reload();
        setTimeout(() => {
          this.showSuccessMsg = false;
        }, 5000);
      })
      .catch(error => {
        ComponentErrorLoging(
          this.compName,
          "unlinkCredential",
          "",
          "",
          this.severity,
          error.message
        );
      });
  }
}