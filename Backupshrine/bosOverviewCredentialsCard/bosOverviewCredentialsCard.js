import {
    LightningElement,
    api,
    track
} from 'lwc';

import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import unlinkCredential from "@salesforce/apex/AccountDashboard.unlinkProfessionalCredential";
import businessProfile_unlink from "@salesforce/label/c.businessProfile_unlink";
import businessProfile_unlinkCredentials from "@salesforce/label/c.businessProfile_unlinkCredentials";
import businessProfile_unlinkCredentials1 from "@salesforce/label/c.businessProfile_unlinkCredentials1";
import businessProfile_unlinkCredentials2 from "@salesforce/label/c.businessProfile_unlinkCredentials2";
import businessProfile_credentialsExpires from "@salesforce/label/c.businessProfile_credentialsExpires";
import businessProfile_linkLicense from "@salesforce/label/c.businessProfile_linkLicense";
import businessProfile_noLicenseContent from "@salesforce/label/c.businessProfile_noLicenseContent";
import businessProfile_credentialsCode from "@salesforce/label/c.businessProfile_credentialsCode";
import businessProfile_credentialsType from "@salesforce/label/c.businessProfile_credentialsType";
import businessProfile_credentialsIssueDate from "@salesforce/label/c.businessProfile_credentialsIssueDate";
import businessProfile_credentialsAddress from "@salesforce/label/c.businessProfile_credentialsAddress";
import businessProfile_credentialsStatus from "@salesforce/label/c.businessProfile_credentialsStatus";
import businessProfile_credentialsStatusReason from "@salesforce/label/c.businessProfile_credentialsStatusReason";
import businessProfile_credentialsEffectiveDate from "@salesforce/label/c.businessProfile_credentialsEffectiveDate";
import businessProfile_load_more from "@salesforce/label/c.businessProfile_load_more";
import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";
import linkBiz_UnlinkAccount from "@salesforce/label/c.linkBiz_UnlinkAccount";
import LinkCredentialLink from "@salesforce/label/c.LinkCredentialLink";
import businessProfile_maddress from "@salesforce/label/c.businessProfile_maddress";
import businessProfile_credentialsPrimaryaddress from "@salesforce/label/c.businessProfile_credentialsPrimaryaddress";
import { NavigationMixin } from 'lightning/navigation';
import { ComponentErrorLoging } from "c/formUtility";
import { isUndefinedOrNull } from "c/appUtility";

export default class BosOverviewCredentialsCard extends NavigationMixin(LightningElement) {
    @track itemData = [];
    @track showDetails = false;
    @track loadMoreBlock = false;
    @track dataLength = 2;
    @track showLess = false;
    @track showEllipsis = false;
    @track unlinkPopUp = false;
    @track modalopen = false;
    @track currentCredId = "";
    @track currentAccId = "";
    @track buildingGroup = assetFolder + "/icons/no_credentials_added.svg";
    @track ellipsisIcon = assetFolder + "/icons/ellipsis-vertical-outline.svg";
    @api section;
    @api currentId;
    @api
    get credcard() {
        return this._credcard;
    }

    set credcard(value) {
        this.itemData = JSON.parse(JSON.stringify(value));
        this.itemData.forEach(element => {
            if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "pending") {
                element.iconSrc = assetFolder + "/icons/yellow-pending-license.svg";
            } else {
                if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "active") {
                    element.iconSrc = assetFolder + "/icons/green-checkmark-license.svg";
                } else if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "inactive") {
                    element.iconSrc = assetFolder + "/icons/expired-license.png";
                }
            }
        });
        return this._credcard;
    }

    label = {
        businessProfile_credentialsExpires,
        businessProfile_linkLicense,
        businessProfile_noLicenseContent,
        businessProfile_unlink,
        businessProfile_unlinkCredentials,
        businessProfile_unlinkCredentials1,
        businessProfile_unlinkCredentials2,
        businessProfile_credentialsCode,
        businessProfile_credentialsType,
        businessProfile_credentialsIssueDate,
        businessProfile_credentialsAddress,
        businessProfile_credentialsStatus,
        businessProfile_credentialsStatusReason,
        businessProfile_credentialsEffectiveDate,
        businessProfile_load_more,
        businessProfile_show_less,
        linkBiz_UnlinkAccount,
        LinkCredentialLink,
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
        // this.showDetails = !this.showDetails;
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

    linkCredentials() {
        sessionStorage.setItem("businessid", this.currentId);
        this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
            pageName: 'linkcredentials'
          },
          state: {}
        });
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
        // var accId = this.businessId;
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

        if (this.itemData.length <= 5) {
            this.showLess = false;
            this.loadMoreBlock = false;
        }
        const changecred = new CustomEvent("credunlink", {
            detail: credId
        });
        this.dispatchEvent(changecred);
        unlinkCredential({
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