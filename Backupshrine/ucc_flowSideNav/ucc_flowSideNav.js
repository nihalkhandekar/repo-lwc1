import {
  LightningElement,
  track,
  api
} from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import label_heading from "@salesforce/label/c.sideNav_heading";
import sidenav_complete from "@salesforce/label/c.sidenav_complete";
import Business_Formation_Flow from "@salesforce/label/c.Business_Formation_Flow";
import First_Annual_Report_Flow from "@salesforce/label/c.First_Annual_Report_Flow";
import Change_Naics_Report from '@salesforce/label/c.Change_Naics_Report';
import Change_Address_Report from '@salesforce/label/c.Change_Address_Report';
import BRS_Select_Certificate_Report from '@salesforce/label/c.BRS_Select_Certificate_Report';
import BRS_Change_Email_Report from '@salesforce/label/c.BRS_Change_Email_Report';
import UCC3_Flow from '@salesforce/label/c.UCC3_Flow';
import BusinessNameReservation_sideNav from '@salesforce/label/c.BusinessNameReservation_sideNav';
import Copy_Flow from "@salesforce/label/c.Copy_Flow";
import Dasboard_Url from "@salesforce/label/c.AccountDashboard_comparable";
import { NavigationMixin } from 'lightning/navigation';
import { ComponentErrorLoging } from "c/formUtility";
import deleteFiling from '@salesforce/apex/brs_myFilingsClass.deleteFiling';
import save_or_discard_filing from "@salesforce/label/c.save_or_discard_filing";
import exit_filing from "@salesforce/label/c.exit_filing";
import discard from "@salesforce/label/c.discard";
import save from "@salesforce/label/c.save";
import exitLabel from "@salesforce/label/c.exitLabel";
import Foreign_Investigation_Flow_Comparable from "@salesforce/label/c.Foreign_Investigation_Flow_Comparable";
import Obtain_Certificate_Flow_Comparable from "@salesforce/label/c.Obtain_Certificate_Flow_Comparable";
import Online_Intake_Category_Comparable from "@salesforce/label/c.Online_Intake_Category_Comparable";
import exit_modal_description from "@salesforce/label/c.exit_modal_description";

export default class Ucc_flowSideNav extends NavigationMixin(LightningElement) {

  @track checkGreyIcon = assetFolder + "/icons/SideNavIcons/subsection-complete.svg";
  @track checkBlueIcon = assetFolder + "/icons/SideNavIcons/section-complete.svg";
  @track playGreyIcon = assetFolder + "/icons/SideNavIcons/subsection-active.svg";
  @track playBlueIcon = assetFolder + "/icons/SideNavIcons/section-active.svg";
  @track childLockClosedIcon = assetFolder + "/icons/SideNavIcons/subsection-locked.svg";
  @track parentLockClosedIcon = assetFolder + "/icons/SideNavIcons/section-locked.svg";
  @track exitIcon = assetFolder + "/icons/SideNavIcons/log-out-outline.svg";

  caretForward = assetFolder + '/icons/caret-forward-circle-outline-active.svg#carecircleforwardactive';
  caretDown = assetFolder + '/icons/caret-down-circle-outline.svg#carecircledownactive';

  @track tempObj = [];
  @track newObj = [];
  @track wiredContact = [];
  @track active = false;
  @track locked = false;
  @track sideNavObjCopy;
  @track completed = false;
  @track showConfirmModal = false;
  @track modalSize = ' ';
  @track flowName;
  _sidenavobj;
  _filingId;
  @api gidataobj;
  _title;
  _progress = 0;

  @track menuOpen = false;
  _currentobj;
  @api serviceTypeChanged;
  exitFilingModalDesc;
  exitButtonText;
  hideSaveButton = false;

  labels = {
    label_heading,
    sidenav_complete,
    Business_Formation_Flow,
    First_Annual_Report_Flow,
    Change_Naics_Report,
    Change_Address_Report,
    BRS_Select_Certificate_Report,
    BRS_Change_Email_Report,
    UCC3_Flow,
    BusinessNameReservation_sideNav,
    Copy_Flow,
    Dasboard_Url,
    save_or_discard_filing,
    exit_filing,
    save,
    discard,
    exitLabel,
    Foreign_Investigation_Flow_Comparable,
    Obtain_Certificate_Flow_Comparable,
    Online_Intake_Category_Comparable,
    exit_modal_description
  }

  @api set progress(val) {
    debugger;
    this._progress = val;
    return this._progress;
  }

  get progress() {
    return this._progress;
  }
  get getProgressLevel() {
    if (this._progress && this._progress > 0) {
      return `${this._progress.toFixed(0)}% ${this.labels.sidenav_complete}`;
    }
    return '';
  }


  get getCaretIcon() {
    return this.menuOpen ? this.caretForward : this.caretForward;
  }

  get svgClass() {
    return this.menuOpen ? "sidenav-mob-icon open" : "sidenav-mob-icon closed";
  }

  @api set title(val) {
    this._title = val;
    return this._title;
  }

  get title() {
    return this._title;
  }

  @api set firstName(val) {
    this._firstName = val;
    return this._firstName;
  }

  get firstName() {
    return this._firstName;
  }

  @api set filingId(val) {
    this._filingId = val;
    return this._filingId;
  }

  get filingId() {
    return this._filingId;
  }

  @api
  get sidenavobj() {
    return this._sidenavobj;
  }
  set sidenavobj(value) {
    //this.setAttribute('sidenavobj', value);
    const [{ flowName }] = value;
    this.flowName = flowName;
    const flowNamesArray = [
      this.labels.Business_Formation_Flow.toLowerCase(),
      this.labels.First_Annual_Report_Flow.toLowerCase(),
      this.labels.Change_Naics_Report.toLowerCase(),
      this.labels.Change_Address_Report.toLowerCase(),
      this.labels.BRS_Select_Certificate_Report.toLowerCase(),
      this.labels.BRS_Change_Email_Report.toLowerCase(),
      this.labels.UCC3_Flow.toLowerCase(),
      this.labels.BusinessNameReservation_sideNav.toLowerCase(),
      this.labels.Copy_Flow.toLowerCase(),
      this.labels.Online_Intake_Category_Comparable.toLowerCase()
    ]
    if (flowNamesArray.includes(flowName.toLowerCase())) {
      this._sidenavobj = value;
    } else {
      const activeSections = value.filter((section, index) => {
        return section.status === 'active' && index === 0;
      })
      if (activeSections.length === 1) {
        this._sidenavobj = activeSections;
      } else {
        this._sidenavobj = value;
      }
    }
  }

  @api
  get currentobj() {

    return this._currentobj;
  }
  set currentobj(value) {
    this._currentobj = value;
  }

  showMoreClick() {
    const ele = this.template.querySelector(".resultsContainer");
    ele.classList.remove("slds-hide").add("slds-show");
  }
  expandCollapseSideNav(event) {
    const index = event.currentTarget.accessKey;
    var sidenavobj = JSON.parse(JSON.stringify(this.sidenavobj));
    for (let i = 0; i < sidenavobj.length; i++) {
      if (sidenavobj[i].pageNameRef == index) {
        sidenavobj[i].IsActive = !sidenavobj[i].IsActive;
        break;
      }
    }
    this.sidenavobj = [...sidenavobj];
  }
  renderedCallback() {
    this.updatestatus();
  }

  @api
  updatestatus() {
    this.updateMainSection();
  }

  updateMainSection() {
    var sidenavobj = this._sidenavobj;
    if (sidenavobj)
      sidenavobj.forEach(section => {
        if (section.show) {
          const secElement = this.template.querySelector("[data-id='" + section.pageNameRef + "']");
          if (secElement) {
            secElement.classList.remove('completed', 'active', 'locked');
            secElement.classList.add(section.status.toLowerCase());
          }
        }
        if (section.IsActive && section.subsections && section.subsections.length > 0) {
          section.subsections.forEach(sub => {
            if (sub.show) {
              const subSecElement = this.template.querySelector("[data-id='" + sub.pageNameRef + "']");
              if (subSecElement) {
                subSecElement.classList.remove('completed', 'active', 'locked');
                subSecElement.classList.add(sub.status.toLowerCase());
              }
            }
          })
        } else {
          if (section.status === "active") {
            this.activeSection = section.label;
          }
        }
      });
  }

  /**
   * handleMenuToggle - opens sidensv for mobile and Ipad view
   * @param  event 
   */
  handleMenuToggle(event) {
    var navElem = this.template.querySelector("nav");
    var iconElem = this.template.querySelector("lightning-icon");
    if (navElem.className.includes("nav-open")) {
      navElem.classList.remove("nav-open");
      this.menuOpen = false;
    } else {
      navElem.classList.add("nav-open");
      this.menuOpen = true;
    }
    const toggleEvent = new CustomEvent('menutoggle', {
      detail: this.menuOpen
    });
    this.dispatchEvent(toggleEvent);
  }

  closeConfirmModal() {
    this.showConfirmModal = false;
  }

  openConfirmModal() {
    if ([this.labels.First_Annual_Report_Flow.toLowerCase(),
    this.labels.Foreign_Investigation_Flow_Comparable.toLowerCase(),
    this.labels.BRS_Select_Certificate_Report.toLowerCase()].includes(this.flowName.toLowerCase())) {
      this.goToAccountDashboard();
    } else if ([this.labels.Copy_Flow.toLowerCase(),
    this.labels.Obtain_Certificate_Flow_Comparable.toLowerCase()].includes(this.flowName.toLowerCase())) {
      this.deleteFiling(this.filingId);
    } else {
      this.getExitModalText();
      this.showConfirmModal = true;
    }
  }

  handleNext() {
    this.goToAccountDashboard();
  }

  handleExit() {
    this.deleteFiling(this.filingId);
  }

  goToAccountDashboard() {
    let showBusinessCentre = true;
    const pageName = `/${this.labels.Dasboard_Url}?gotoBusinessCentre=${showBusinessCentre}`;
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: pageName,
        target: '_self'
      }
    }, true);

  }


  deleteFiling(filingId) {
    this.isLoading = true;
    deleteFiling({ recordId: filingId })
      .then(result => {
        this.isLoading = false;
        this.goToAccountDashboard();
      }).catch((error) => {
        this.isLoading = false;
        ComponentErrorLoging(
          'ucc_flowSideNav',
          "deleteFiling",
          "",
          "",
          "Medium",
          error.message
        );
      });

  }

  @api
  updateFilingId(filingID) {
    if (filingID !== null && filingID !== undefined) {
      this.filingId = filingID;
      this.connectedCallback();
    }
  }

  getExitModalText() {
    if (this.flowName === this.labels.Online_Intake_Category_Comparable) {
      this.exitFilingModalDesc = this.labels.exit_modal_description;
      this.exitButtonText = this.labels.exitLabel;
      this.hideSaveButton = true;
    } else {
      this.exitFilingModalDesc = this.labels.save_or_discard_filing;
      this.exitButtonText = this.labels.discard;
    }
  }
}