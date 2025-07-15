import { LightningElement, track, api } from 'lwc';
import fetchRightPaneResources from "@salesforce/apex/AccountDashboard.getRightPaneResources";
import { ComponentErrorLoging } from "c/formUtility";

export default class Ct_resources extends LightningElement {
    @track resources;
    @track rightResources;
   
    @api
    get componentname() {
      return this._componentname;
    }
    set componentname(value) {
      this._componentname = value;
    }
    
    connectedCallback() {
      fetchRightPaneResources({
        functionality: this.componentname,
        hasScholarsColumn: false
      })
      .then(result => {
        this.rightResources = result;
      })
      .catch(error => {
        ComponentErrorLoging(
          this.compName,
          "fetchResources",
          "",
          "",
          "Medium",
          error.message
        );
      });
    }
}