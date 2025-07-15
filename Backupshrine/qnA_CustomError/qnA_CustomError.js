import { LightningElement } from 'lwc';
import ssoErrorMessage from "@salesforce/label/c.ssoErrorMessage";
export default class qnA_CustomError extends LightningElement {
  /**
   * custom label variables
   */
  label = {
	  ssoErrorMessage
  };
}