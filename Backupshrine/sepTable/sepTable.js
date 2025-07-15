import { LightningElement,api } from 'lwc';
export default class SepTable extends LightningElement {
    @api tableData = [];
    @api variationTwo;
}