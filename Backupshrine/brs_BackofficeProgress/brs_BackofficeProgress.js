import { LightningElement,api,track } from 'lwc';
import {
    isUndefinedOrNull
  } from "c/appUtility";

export default class Brs_BackofficeProgress extends LightningElement {

  @api  progressections;
  @api  currentSection;
@api options=[];
  connectedCallback(){
if(!isUndefinedOrNull(this.progressections)){
    var steps=  this.progressections.split(',');
    for(var step of steps){
        var singleObj = {label:step,value:step};
        this.options.push(singleObj);
    }
}
  }
}