import { api, track, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BRS_Certificate_Maintainence from "@salesforce/label/c.BRS_Certificate_Maintainence";
import Certificate_Title from "@salesforce/label/c.Certificate_Title";
import verify_Certificate_Success from "@salesforce/label/c.verify_Certificate_Success";
import cert_Unable_view from "@salesforce/label/c.cert_Unable_view";
import Download_Certificate_Text from "@salesforce/label/c.Download_Certificate_Text";
import Preview_Certificate_Label from "@salesforce/label/c.Preview_Certificate_Label";
import Preview_Certificate_Label1 from "@salesforce/label/c.Preview_Certificate_Label1";
import Preview_Certificate_Label2 from "@salesforce/label/c.Preview_Certificate_Label2";
import Certificate_Footer_Title from "@salesforce/label/c.Certificate_Footer_Title";
import Certificate_Footer_SubTitle from "@salesforce/label/c.Certificate_Footer_SubTitle";
import Certificate_Footer_Button1 from "@salesforce/label/c.Certificate_Footer_Button1";
import Certificate_Footer_Button2 from "@salesforce/label/c.Certificate_Footer_Button2";
import Certificate_Or_Text from "@salesforce/label/c.Certificate_Or_Text";
import BRS_businessinformation from "@salesforce/label/c.BRS_businessinformation";
import BRS_Verify_Certificate from "@salesforce/label/c.BRS_Verify_Certificate";
import home from "@salesforce/label/c.home";
import search_and_verify from "@salesforce/label/c.search_and_verify";
import certificate from "@salesforce/label/c.certificate";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Brs_CertificateDownload extends NavigationMixin(LightningElement) {
  downloadIcon = assetFolder + "/icons/download-blue.svg";
  label = {
    BRS_Certificate_Maintainence,
    Certificate_Title,
    verify_Certificate_Success,
    cert_Unable_view,
    Download_Certificate_Text,
    Preview_Certificate_Label,
    Preview_Certificate_Label1,
    Preview_Certificate_Label2,
    Certificate_Footer_Title,
    Certificate_Footer_SubTitle,
    Certificate_Footer_Button1,
    Certificate_Footer_Button2,
    Certificate_Or_Text,
    BRS_businessinformation,
    BRS_Verify_Certificate
  }
  @api downloadLink;
  @api previewLink;
  @track isLoading = true;
  @track breadcrumbList = [home, search_and_verify, certificate]

  connectedCallback() {
    const toastevent = new ShowToastEvent({
      message: this.label.verify_Certificate_Success,
      variant: "info"
    });
    this.dispatchEvent(toastevent);
  }

  onBusinessMaintenenceHandler() {
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
        pageName: this.label.BRS_businessinformation,
      },
    });
  }

  onHomeHandler() {
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
        pageName: this.label.BRS_Certificate_Maintainence
      },
    });
  }

  onBreadCrumbClick(event) {
    const selected = event.detail.name;
    if (selected.includes(home)) {
      this.onHomeHandler();
    } else if (selected.includes(search_and_verify)) {
      this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
          pageName: this.label.BRS_Verify_Certificate,
        },
      });
    }
  }
}