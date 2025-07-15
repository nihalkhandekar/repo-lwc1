import { LightningElement, api, track } from "lwc";
import ReviewPage_updates from "@salesforce/label/c.ReviewPage_updates";
import ReviewPage_noChanges from "@salesforce/label/c.ReviewPage_noChanges";
import ReviewPage_nothingToShow from "@salesforce/label/c.ReviewPage_nothingToShow";
import ReviewPage_deletionsAdditions from "@salesforce/label/c.ReviewPage_deletionsAdditions";
import Deleted from "@salesforce/label/c.Deleted";
import Added from "@salesforce/label/c.Added";
import Previous from "@salesforce/label/c.Previous";
import Updated from "@salesforce/label/c.Updated";
import Changes from "@salesforce/label/c.Changes";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class Brs_tabsetModal extends LightningElement {
  @api showPopup = false;
  @api createdData;
  @api deletedData;
  @api changedData;
  @api tableColumns;
  @track hasNoChanges = true;
  @track showIndex = true;
  @track modalSize = "medium";
  @track tabsetTableColumns;
  @track noDataDeleted = false;
  @track noDeletionsAdditions = false;
  label = {
    ReviewPage_updates,
    ReviewPage_noChanges,
    ReviewPage_nothingToShow,
    ReviewPage_deletionsAdditions,
    Deleted,
    Added,
    Previous,
    Updated,
    Changes
  };
  noChangesIcon = assetFolder + "/icons/ReviewPageIcons/no-changes-icon.svg";
  closePopup() {
    this.showPopup = false;
    const evt = new CustomEvent("modalclose");
    this.dispatchEvent(evt);
  }
  connectedCallback() {
    if (!this.createdData && !this.deletedData) {
      this.noDeletionsAdditions = true;
    } else if (!this.deletedData) {
      this.noDataDeleted = true;
    }
    if(this.changedData && this.changedData.length){
      this.hasNoChanges = false;
  }
  }
}