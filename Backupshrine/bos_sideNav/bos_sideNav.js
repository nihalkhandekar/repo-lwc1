/* eslint-disable no-else-return */
import {
  LightningElement,
  track,
  api
} from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import accountDashboard_ConnectMyBusiness from "@salesforce/label/c.accountDashboard_ConnectMyBusiness";
// import label_heading from "@salesforce/label/c.sideNav_heading";
// import sidenav_complete from "@salesforce/label/c.sidenav_complete";

export default class Sidenav extends LightningElement {
  @track pCompletedIcon = assetFolder + "/icons/SideNavIcons/parent-complete.svg";
  @track pCurrentIcon = assetFolder + "/icons/SideNavIcons/parent-current.svg";
  @track pLockedIcon = assetFolder + "/icons/SideNavIcons/parent-locked.svg";
  @track dropdownIcon = assetFolder + "/icons/SideNavIcons/parent-drop.svg";
  @track cCompletedIcon = assetFolder + "/icons/SideNavIcons/child-complete.svg";
  @track cCurrentIcon = assetFolder + "/icons/SideNavIcons/child-current.svg";
  @track cLockedIcon = assetFolder + "/icons/SideNavIcons/child-locked.svg";
  caretForward = assetFolder + '/icons/caret-forward-circle-outline-active.svg#carecircleforwardactive';
  caretDown = assetFolder + '/icons/caret-down-circle-outline.svg#carecircledownactive';

  @track tempObj = [];
  @track newObj = [];
  @track wiredContact = [];
  @track active = false;
  @track locked = false;
  @track completed = false;
  @track activeSection = "Renewal information"
  @api sidenavobj;
  @api gidataobj;
  @track progressLevel = 0;
  @track firstName = "John Smith";
  @track menuOpen = false;
  @track currentObjLocal = {};
  @api linkbusinesscomplete;
  @track checkifbos = true;




  @api get currentobj() {
    return this.currentObjLocal;
  };

  set currentobj(val) {
    this.currentObjLocal = val;
  }

  labels = {
  //   label_heading,
  //   sidenav_complete,
	   accountDashboard_ConnectMyBusiness
  }

  @api set progress(val) {
    if (val > -1) {
      this.progressLevel = val;
    }
  }

  get getCaretIcon() {
    return this.caretForward;
  }

  get svgClass() {
    return this.menuOpen ? "sidenav-mob-icon open" : "sidenav-mob-icon closed";
  }

  get progress() {
    return this.progressLevel;
  }

  get title() {
    if (this.sidenavobj) {
      return this.sidenavobj.flowName;
    }
    return '';
  }

  /*
  get progressLevel() {
    if (this.section) {
      if (this.section.status === "Completed") {
        return "100";
      } else {
        try {
          let total = this.section.totalNoOfSections;
          let completed = this.section.completedSections;
          if (completed > 0) {
            let percentage = ((completed / total) * 100).toFixed(0);
            return percentage;
          }
          return 0;
        } catch (err) {
          return 0;
        }
      }
    }
    return 0;
  }
  */
  // @api
  // get sideNavUpdate() {
  //   return this.sidenavobj;
  // }

  // set sideNavUpdate(sidenavObj) {
  //   if (sidenavObj && sidenavObj.sections) {
  //     sidenavObj.sections.forEach(section => {
  //       if (section.status === 'active') {
  //         section.locked = false;
  //         section.active = true;
  //         section.completed = false;
  //       } else if (section.status === 'locked') {
  //         section.locked = true;
  //         section.active = false;
  //         section.completed = false;
  //       } else if (section.status === "completed") {
  //         section.locked = false;
  //         section.active = false;
  //         section.completed = true;
  //       }
  //     });
  //   }
  //   this.sidenavobj = sidenavObj;
  // }

  // showMoreClick() {
  //   const ele = this.template.querySelector(".resultsContainer");
  //   ele.classList.remove("slds-hide").add("slds-show");
  // }
  // expandableLinkClick(event) {
  //   const ele = event.target;
  //   const divEle = ele.parentElement.parentElement
  //     .querySelector(".resultsContainer")
  //     .classList.toggle("slds-hide")
  //     .toggle("slds-show");
  // }

  connectedCallback() {
    //this.updatestatus(this.currentObjLocal.compRef, this.currentObjLocal.status, this.currentObjLocal.prevStatus);

    // this.sidenavobj = {
    //   "sections": [{
    //       "subSection": [{
    //           "subSectionName": "Find your business",
    //           "subComponentName": "c-link_find-your-biz",
    //           "status": "active",
    //           "pageNameRef": "findyourbiz",
    //           "show": true
    //         },
    //         {
    //           "subSectionName": "Confirm selection",
    //           "subComponentName": "c-link_biz-confirm",
    //           "status": "locked",
    //           "pageNameRef": "bizconfirm",
    //           "show": true
    //         }
    //       ],
    //       "status": "active",
    //       "sectionName": "Find your business",
    //       "pageNameRef": null,
    //       "componentName": null
    //     },
    //     {
    //       "subSection": [{
    //           "subSectionName": "Find your credentials",
    //           "subComponentName": "c-link_find-your-cred",
    //           "status": "locked",
    //           "pageNameRef": "findyourcred",
    //           "show": true
    //         },
    //         {
    //           "subSectionName": "Confirm selection",
    //           "subComponentName": "c-link_cred-confirm",
    //           "status": "locked",
    //           "pageNameRef": "credconfirm",
    //           "show": true
    //         }
    //       ],
    //       "status": "locked",
    //       "sectionName": "Link credentials",
    //       "pageNameRef": "linkcred",
    //       "componentName": "c-link_cred-link"
    //     },
    //     {
    //       "subSection": [],
    //       "status": "locked",
    //       "sectionName": "Summary",
    //       "pageNameRef": "summaryReview",
    //       "componentName": "c-dmv_summary"
    //     }
    //   ],
    //   "flowName": "Driver's license renewal",
    //   "firstName": ""
    // };

    // this.firstName = this.gidataobj.DMV_First_Name__c.toUpperCase();
    // window.addEventListener("LWC-triggered-event", function () {
    // });

    // // this.sidenavobj.sections.forEach(element => {
    // //     element.selected = true;
    // // }); 

    // //this.wiredContact = Object.assign({}, this.sidenavobj.sections);
    // //this.wiredContact = {...};
    // this.tempObj = this.sidenavobj.sections;
    // this.tempObj.forEach((element) => {
    //   if(element.status == 'Active') {
    //     const tempObj = {
    //       pageNameRef: element.pageNameRef,
    //       isActive: true,
    //       sectionName: element.sectionName
    //     }
    //     this.newObj.push(tempObj);
    //   } else if(element.status == 'Locked') {
    //     const tempObj = {
    //       pageNameRef: element.pageNameRef,
    //       isLocked: true,
    //       sectionName: element.sectionName
    //     }
    //     this.newObj.push(tempObj);
    //   }

    // });
    // if(this.wiredContact){
    // this.wiredContact.forEach((element) => {
    //     element.test = "test";
    //   // if(element.status === 'Active') {
    //   //     element.status = true;
    //   //   } else if(element.status === 'Locked') {
    //   //     this.tempObj[index].locked = true;
    //   //   } else if(element.status === 'Completed') {
    //   //     this.tempObj[index].completed = true;
    //   //   } 
    //   });
    // }
  }

  renderedCallback() {
    this.updatestatus(this.currentObjLocal.compRef, this.currentObjLocal.status, this.currentObjLocal.prevStatus);
  }

  get getProgressLevel() {
    if (this.progressLevel && this.progressLevel > 0) {
      return `${this.progressLevel.toFixed(0)}% `;
    }
    return '';
  }

  @api
  updatestatus(compRef, status, prevStatus) {
    var queryParam = "[data-id='" + compRef + "']";
    var subSection = this.template.querySelector(queryParam);
    if (subSection) {
      if (status && status !== "") {
        subSection.classList.add(status);
      }
      if (prevStatus && prevStatus !== "") {
        subSection.classList.remove(prevStatus);
      }
    }
    this.updateMainSection();
  }

  handleMenuToggle(event) {
    var navElem = this.template.querySelector("nav");
    //var iconElem = this.template.querySelector("lightning-icon");
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

  updateMainSection() {
    var sidenavobj = this.sidenavobj;
    sidenavobj.sections.forEach(section => {
      if (section.subSection && section.subSection.length > 0) {
        var elem = this.template.querySelector("[data-type='" + section.sectionName + "']");
        var statusArray = [];
        section.subSection.forEach(sub => {
          if (sub.show) {
            statusArray.push(sub.status);
          }
        });
        if (elem) {
          elem.classList.remove("active");
          elem.classList.remove("locked");
          elem.classList.remove("completed");
          if (this.linkbusinesscomplete) {
            if (section.pageNameRef === "linkcred") {
              elem.classList.add(section.status);
            }
          } else {
            if (statusArray.includes("active") || section.status === "active") {
              this.activeSection = section.sectionName;
              elem.classList.add("active");
            } else if (statusArray.includes("locked") || section.status === "locked") {
              elem.classList.add("locked");
            } else if (statusArray.includes("completed") && section.status === "completed") {
              elem.classList.add("completed");
            }
          }
        }
      } else {
        if (section.status === "active") {
          this.activeSection = section.sectionName;
        }
      }
    });
  }
}