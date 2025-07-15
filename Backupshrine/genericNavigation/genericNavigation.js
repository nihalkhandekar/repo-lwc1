import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class CtBosGenericNavigation extends NavigationMixin(
  LightningElement
) {
  navigateToPage(ref, pageName) {
    // Navigate to a URL
    ref[NavigationMixin.Navigate](
      {
        //type: "standard__webPage",
        type: "comm__namedPage",
        attributes: {
          //url: url,
          name: pageName
        }
      },
      true
    );
  }
  handleNext() {
    const selectedEvent = new CustomEvent("nextbuttonclick", {});

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }
  handleBack() {
    const selectedEvent = new CustomEvent("backbuttonclick", {});

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }
}

export const genericNavigation =
  CtBosGenericNavigation.prototype.navigateToPage;