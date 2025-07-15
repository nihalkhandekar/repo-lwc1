import { LightningElement, api, track } from "lwc";

// Import custom labels
//import label_descLine1 from "@salesforce/label/c.businessDetails_DescLine1";
import label_descLine2 from "@salesforce/label/c.businessDetails_DescLine2";
import label_descLine2_date from "@salesforce/label/c.businessDetails_DescLine2_date";
import label_descLine2_part2 from "@salesforce/label/c.businessDetails_DescLine2_part2";
import label_link1 from "@salesforce/label/c.businessDetails_Link1";
import businessName from "@salesforce/label/c.businessProfile_bname";
import bstatus from "@salesforce/label/c.businessProfile_bstatus";
import bdate from "@salesforce/label/c.businessProfile_bdate";
import bid from "@salesforce/label/c.businessProfile_bid";
import naics from "@salesforce/label/c.businessProfile_naics";
import citizenship from "@salesforce/label/c.businessProfile_citizenship";
import email from "@salesforce/label/c.businessProfile_email";
import naicsSub from "@salesforce/label/c.businessProfile_naicsSub";
import state from "@salesforce/label/c.businessProfile_state";
import baddress from "@salesforce/label/c.businessProfile_baddress";
import raddress from "@salesforce/label/c.businessProfile_raddress";
import maddress from "@salesforce/label/c.businessProfile_maddress";
// import agentName from "@salesforce/label/c.businessProfile_agentName";
import title from "@salesforce/label/c.businessProfile_title";
import name from "@salesforce/label/c.businessProfile_name";
import type from "@salesforce/label/c.businessProfile_type";
import generalInfo from "@salesforce/label/c.businessProfile_generalInfo";
import principal from "@salesforce/label/c.businessProfile_principal";
import businessProfile_agent from "@salesforce/label/c.businessProfile_agent";
import Agent from "@salesforce/label/c.Agent";
import label_desc from "@salesforce/label/c.businessDetails_Desc";
import BRS_businessinformation from "@salesforce/label/c.BRS_businessinformation";

export default class BosBusinessGeneralInfo extends LightningElement {
  @track agentData = [];
  @track showAgentData = false;
  @track localObj = [];
  @track principalData = [];
  @track generalData = [];
  @api
  get generalInfo() {
    return this._generalInfo;
  }

  set generalInfo(value) {
    this._generalInfo = JSON.parse(JSON.stringify(value));
    this.generalData = this._generalInfo;
    this.generalData.forEach(element => {
      if (element.dateOfFormation) {
        let dueDate = element.dateOfFormation;
        var todayTime = new Date(dueDate);
        var convDate = dueDate.split("-");
        var month = convDate[1];//todayTime.getMonth() + 1;
        var day = convDate[2];//todayTime.getDate();
        var year = convDate[0];//todayTime.getFullYear();
        let finalDate = month + "/" + day + "/" + year;
        element.dateOfFormation = finalDate;
      }
    })
    this.setVariables(this._generalInfo);
  }
  label = {
    label_link1,
    //label_descLine1,
    label_descLine2,
    label_descLine2_date,
    label_descLine2_part2,
    businessName,
    bstatus,
    bdate,
    bid,
    naics,
    citizenship,
    email,
    naicsSub,
    state,
    baddress,
    raddress,
    maddress,
    // agentName,
    title,
    name,
    type,
    generalInfo,
    principal,
    businessProfile_agent,
    Agent,
    label_desc,
	BRS_businessinformation
  };

  setVariables(businessdata) {
    businessdata.forEach(element => {
      if (element.contacts) {
        this.agentData = [];
        this.principalData = [];
        element.contacts.forEach(data => {
          if (data.contactType == this.label.Agent) {
            this.agentData.push(data);
          } else {
            this.principalData.push(data);
          }
        });
      } else {
        this.agentData = [];
        this.principalData = [];
      }
    });
    this.agentData = JSON.parse(JSON.stringify(this.agentData));
    this.principalData = JSON.parse(JSON.stringify(this.principalData));
  }
}