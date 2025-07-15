import { LightningElement, track } from 'lwc';
import getIwantTolinks from "@salesforce/apex/DashboardlinkApex.getIwantTolinks";
import IWantToLabel from '@salesforce/label/c.IWantToLabel';
import { ComponentErrorLoging } from "c/formUtility";

export default class BosActionableItems extends LightningElement {
    @track actionsData = [];
    @track spinner = false;

    @track label = {
      IWantToLabel
    };

    connectedCallback() {
        try {
            this.spinner = true;
            getIwantTolinks()
              .then((data) => {
                this.actionsData = JSON.parse(data);
                this.spinner = false;
              })
              .catch((err) => {
                ComponentErrorLoging("bosActionableItems", "getIwantTolinks","", "", "High", err.message);
                this.spinner = false;
              });
          } catch (err) {
            ComponentErrorLoging("bosActionableItems", "getIwantTolinks","", "", "High", err.message);
              this.spinner = false;
          }
    }

}