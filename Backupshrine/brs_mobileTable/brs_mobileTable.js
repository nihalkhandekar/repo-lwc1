import { LightningElement, api, track } from "lwc";

export default class Brs_mobileTable extends LightningElement {

  @api tableColumns;
  @api tableData;
  @track tableColumnValues = [];
  @track tableColumnKeys = [];
  @track finalTableData = [];
  connectedCallback() {
    var temp;
    let that = this;

    this.tableColumnKeys = this.tableColumns.map((item) => item.fieldName);
    this.tableColumnValues = this.tableColumns.map((item) => item.label);
    let tableIndex = 0;
    if(this.tableData){
      this.tableData.forEach((data) => {
        var tempTableData = [];
        this.tableColumnKeys.forEach((columnKey,i)=>{
          temp = {};
          if (columnKey in data) {
            temp.key = that.tableColumnValues[i];
            temp.value = data[columnKey];
          } else {
            temp.key = that.tableColumnValues[i];
            temp.value = "";
          }
          temp.showLink = that.tableColumns[i].type === "button";
          if(!(that.tableColumns[i].type === "button" && temp.value === "")) {
            tempTableData.push(temp);
          }
          
          
        });
        tempTableData = tempTableData.filter(value => Object.keys(value).length !== 0);
        this.finalTableData[tableIndex] = tempTableData;
        tableIndex++;
      });
    }
    
  }
  handleRowAction(event) {
    let selectedRowData = this.tableData[parseInt(event.target.dataset.index)];

    const selectedEvent = new CustomEvent("mobilerowaction", {
      detail: {
        row: selectedRowData
      }
    });
    this.dispatchEvent(selectedEvent);
  }
}